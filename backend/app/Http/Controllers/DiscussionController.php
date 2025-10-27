<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DiscussionRoom;
use Illuminate\Support\Facades\DB;
use App\Models\DiscussionGroup;

class DiscussionController extends Controller
{
    // GET /api/discussions
    // optional query: ?class_id=123
    public function index(Request $request)
    {
        $classId = $request->query('class_id');

        $query = DiscussionRoom::query();

        if ($classId) {
            $query->where('fk_id_class', $classId);
        }

        $rooms = $query->orderBy('created_at', 'desc')->get();

        // Normalize to a simple array for frontend
        $data = $rooms->map(function ($r) {
            // If explicit columns are absent (null) try to compute from discussion_groups relation
            $numGroups = $r->num_groups ?? null;
            $studentsPerGroup = $r->students_per_group ?? null;
            if (($numGroups === null || $studentsPerGroup === null) && DB::getSchemaBuilder()->hasTable('discussion_groups')) {
                try {
                    $groups = DiscussionGroup::where('fk_id_chatroomai', function($q) use ($r) {
                        $q->select('id_chatroomai')->from('chat_room_ai')->where('fk_id_discussionroom', $r->id_discussionroom)->limit(1);
                    })->get();
                    if ($groups->isNotEmpty()) {
                        $numGroups = $groups->pluck('group_no')->unique()->count();
                        // average members per group (rounded down)
                        $totalMembers = $groups->count();
                        $studentsPerGroup = $numGroups > 0 ? intdiv($totalMembers, $numGroups) : $totalMembers;
                    }
                } catch (\Throwable $_) {
                    // ignore
                }
            }
            return [
                'idDiscussionRoom' => (string) $r->id_discussionroom,
                'title' => $r->title,
                'description' => $r->description,
                'tag' => $r->tag,
                'numGroups' => $numGroups ?? null,
                'studentsPerGroup' => $studentsPerGroup ?? null,
                'status' => $r->status,
                'createdBy' => (string) $r->created_by,
                'fkIdClass' => (string) $r->fk_id_class,
                'createdAt' => $r->created_at ? $r->created_at->toDateTimeString() : null,
                'updatedAt' => $r->updated_at ? $r->updated_at->toDateTimeString() : null,
            ];
        });

        return response()->json(['data' => $data]);
    }

    /**
     * Create a discussion room and chatroom (backend persistence performed here).
     * Expected payload: { title, description, tag, fk_id_class, created_by, students: [{id_user, name}, ...] }
     */
    public function store(Request $request)
    {
    $data = $request->only(['title','description','tag','fk_id_class','created_by','students','numGroups','studentsPerGroup']);
        try {
            $disc = DiscussionRoom::create([
                'title' => $data['title'] ?? 'Discussion',
                'description' => $data['description'] ?? '',
                'tag' => $data['tag'] ?? null,
                'num_groups' => isset($data['numGroups']) ? intval($data['numGroups']) : null,
                'students_per_group' => isset($data['studentsPerGroup']) ? intval($data['studentsPerGroup']) : null,
                'status' => 'open',
                'created_by' => $data['created_by'] ?? null,
                'fk_id_class' => $data['fk_id_class'] ?? null,
            ]);

            // create ChatRoomAI
            $chat = \App\Models\ChatRoomAI::create([
                'fk_id_discussionroom' => $disc->id_discussionroom,
                'title' => ($disc->title ?? 'AI Room'),
                'description' => ($disc->description ?? ''),
                'status' => 'active',
                'ai_model' => 'gemini-2.0-flash',
                'created_by' => $data['created_by'] ?? null,
                'fk_id_class' => $data['fk_id_class'] ?? null,
            ]);

            // insert discussion students if provided
            if (!empty($data['students']) && is_array($data['students'])) {
                foreach ($data['students'] as $s) {
                    try {
                        \App\Models\DiscussionStudent::firstOrCreate([
                            'fk_id_chatroomai' => $chat->id_chatroomai,
                            'fk_id_user' => $s['id_user'] ?? $s['id'] ?? null,
                        ], [
                            'fk_id_chatroomai' => $chat->id_chatroomai,
                            'fk_id_user' => $s['id_user'] ?? $s['id'] ?? null,
                        ]);
                    } catch (\Throwable $_) {}
                }
            }

            return response()->json(['data' => ['discussion' => $disc, 'chat' => $chat]], 201);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Could not create discussion', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Update an existing discussion room and related chatroom.
     * Expected payload: { title?, description?, tag?, status?, chatroom_active?, students?: [{id_user, name}, ...], materials?: [...] }
     */
    public function update(Request $request, $id)
    {
        $data = $request->only(['title','description','tag','status','chatroom_active','students','materials']);
        try {
            $disc = DiscussionRoom::find($id);
            if (!$disc) {
                return response()->json(['message' => 'Discussion not found'], 404);
            }

            // Update basic fields
            $disc->title = $data['title'] ?? $disc->title;
            $disc->description = $data['description'] ?? $disc->description;
            $disc->tag = $data['tag'] ?? $disc->tag;
            if (array_key_exists('numGroups', $data)) {
                $disc->num_groups = $data['numGroups'] !== null ? intval($data['numGroups']) : null;
            }
            if (array_key_exists('studentsPerGroup', $data)) {
                $disc->students_per_group = $data['studentsPerGroup'] !== null ? intval($data['studentsPerGroup']) : null;
            }
            $disc->status = $data['status'] ?? $disc->status;
            $disc->save();

            // Update ChatRoomAI active flag if provided
            $chat = \App\Models\ChatRoomAI::where('fk_id_discussionroom', $disc->id_discussionroom)->first();
            if ($chat) {
                if (array_key_exists('chatroom_active', $data)) {
                    // Accept boolean or string 'active'/'inactive'
                    $active = $data['chatroom_active'];
                    if (is_bool($active)) {
                        $chat->status = $active ? 'active' : 'inactive';
                    } else if (is_string($active)) {
                        $chat->status = strtolower($active) === 'active' ? 'active' : 'inactive';
                    }
                }
                $chat->title = $disc->title;
                $chat->description = $disc->description;
                $chat->save();
            }

            // If chatroom was turned inactive, mark the discussion as closed/completed
            if ($chat && ($chat->status === 'inactive' || ($data['chatroom_active'] ?? null) === false)) {
                $disc->status = 'closed';
                $disc->save();
            }

            // Optionally update discussion students: if provided, replace memberships for this chatroom
            if (!empty($data['students']) && is_array($data['students']) && $chat) {
                // Delete existing discussion students for this chat
                \App\Models\DiscussionStudent::where('fk_id_chatroomai', $chat->id_chatroomai)->delete();
                foreach ($data['students'] as $s) {
                    try {
                        $uid = $s['id_user'] ?? $s['id'] ?? null;
                        if ($uid) {
                            \App\Models\DiscussionStudent::firstOrCreate([
                                'fk_id_chatroomai' => $chat->id_chatroomai,
                                'fk_id_user' => $uid,
                            ], [
                                'fk_id_chatroomai' => $chat->id_chatroomai,
                                'fk_id_user' => $uid,
                            ]);
                        }
                    } catch (\Throwable $_) {}
                }
            }

            // Note: materials handling is intentionally left minimal - create new materials if provided
            if (!empty($data['materials']) && is_array($data['materials'])) {
                foreach ($data['materials'] as $m) {
                    try {
                        \App\Models\MaterialQuiz::create([
                            'title' => $m['title'] ?? '',
                            'content' => $m['content'] ?? '',
                            'type' => $m['type'] ?? 'text',
                            'fk_id_discussionroom' => $disc->id_discussionroom,
                            'fk_id_quiz' => $m['fk_id_quiz'] ?? null,
                        ]);
                    } catch (\Throwable $_) {}
                }
            }

            return response()->json(['data' => ['discussion' => $disc, 'chat' => $chat]]);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Could not update discussion', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Show a single discussion with chatroom and materials.
     */
    public function show($id)
    {
        $disc = DiscussionRoom::find($id);
        if (!$disc) return response()->json(['message' => 'Not found'], 404);

        $chat = \App\Models\ChatRoomAI::where('fk_id_discussionroom', $disc->id_discussionroom)->first();
        $materials = [];
        if (class_exists('\App\Models\MaterialQuiz')) {
            $materials = \App\Models\MaterialQuiz::where('fk_id_discussionroom', $disc->id_discussionroom)->get();
        }

        // compute derived group stats if explicit columns are null
        $numGroups = $disc->num_groups ?? null;
        $studentsPerGroup = $disc->students_per_group ?? null;
        try {
            if (($numGroups === null || $studentsPerGroup === null) && \Illuminate\Support\Facades\DB::getSchemaBuilder()->hasTable('discussion_groups')) {
                $chatId = $chat ? $chat->id_chatroomai : null;
                if ($chatId) {
                    $groups = \App\Models\DiscussionGroup::where('fk_id_chatroomai', $chatId)->get();
                    if ($groups->isNotEmpty()) {
                        $numGroups = $groups->pluck('group_no')->unique()->count();
                        $totalMembers = $groups->count();
                        $studentsPerGroup = $numGroups > 0 ? intdiv($totalMembers, $numGroups) : $totalMembers;
                    }
                }
            }
        } catch (\Throwable $_) {}

        // fallback: if still null, try discussion_students count as single group
        if (($numGroups === null || $studentsPerGroup === null) && \Illuminate\Support\Facades\DB::getSchemaBuilder()->hasTable('discussion_students')) {
            try {
                $chatId = $chat ? $chat->id_chatroomai : null;
                if ($chatId) {
                    $members = \App\Models\DiscussionStudent::where('fk_id_chatroomai', $chatId)->get();
                    $memberCount = $members->count();
                    if ($numGroups === null) $numGroups = $memberCount > 0 ? 1 : 0;
                    if ($studentsPerGroup === null) $studentsPerGroup = $memberCount;
                }
            } catch (\Throwable $_) {}
        }

        // prepare normalized discussion payload
        $discussionOut = [
            'idDiscussionRoom' => (string) $disc->id_discussionroom,
            'title' => $disc->title,
            'description' => $disc->description,
            'tag' => $disc->tag,
            'numGroups' => $numGroups ?? null,
            'studentsPerGroup' => $studentsPerGroup ?? null,
            'status' => $disc->status,
            'createdBy' => (string) $disc->created_by,
            'fkIdClass' => (string) $disc->fk_id_class,
            'createdAt' => $disc->created_at ? $disc->created_at->toDateTimeString() : null,
            'updatedAt' => $disc->updated_at ? $disc->updated_at->toDateTimeString() : null,
            'chatroomId' => $chat ? (string)$chat->id_chatroomai : null,
        ];

        return response()->json(['data' => [
            'discussion' => $discussionOut,
            'chat' => $chat,
            'materials' => $materials,
        ]]);
    }
}
