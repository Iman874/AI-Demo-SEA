<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use App\Models\DiscussionRoom;
use App\Models\ChatRoomAI;
use App\Models\DiscussionStudent;
use App\Models\SummaryDiscussion;
use App\Models\ResultUnderstanding;
use App\Models\DiscussionMessage;
use App\Models\AIMessage;
use App\Models\MaterialQuiz;
use App\Models\User;

class DiscussionResultSeeder extends Seeder
{
    /**
     * Seed summaries, understanding results, and minimal chat history for a discussion.
     */
    public function run(): void
    {
        // 1) Locate a target discussion room - prefer one named like 'Diskusi1'
        $discussion = DiscussionRoom::query()
            ->where('title', 'Discussion 1')
            ->first();
        if (!$discussion) {
            $discussion = DiscussionRoom::query()
                ->whereRaw('LOWER(title) LIKE ?', ['%discussion%'])
                ->orderBy('id_discussionroom')
                ->first();
        }

        if (!$discussion) {
            // Nothing to do if no discussion rooms exist
            return;
        }

        // 2) Get all chat rooms for this discussion and their students
        $chatrooms = ChatRoomAI::query()
            ->where('fk_id_discussionroom', $discussion->id_discussionroom)
            ->get();
        if ($chatrooms->isEmpty()) {
            return; // nothing to seed
        }

        // Fetch teacher id(s) to exclude from student summaries
        $teacherIds = User::query()->where('role', 'teacher')->pluck('id_user')->filter()->all();

        // 3) Collect all student memberships across chatrooms
        $memberships = DiscussionStudent::query()
            ->whereIn('fk_id_chatroomai', $chatrooms->pluck('id_chatroomai')->all())
            ->get();

        // Ensure we only consider student users (exclude teachers)
        $studentMemberships = $memberships->filter(function ($m) use ($teacherIds) {
            $uid = $m->fk_id_user;
            return $uid && !in_array($uid, $teacherIds ?? [], true);
        })->values();

        if ($studentMemberships->isEmpty()) {
            return;
        }

        // 4) Prepare materials summary text (use titles joined)
        $materialTitles = [];
        try {
            if (Schema::hasTable('material_quiz')) {
                $mats = MaterialQuiz::query()
                    ->where('fk_id_discussionroom', $discussion->id_discussionroom)
                    ->get();
                if ($mats->isEmpty()) {
                    // fallback: all materials
                    $mats = MaterialQuiz::all();
                }
                $materialTitles = $mats->pluck('title')->filter()->values()->all();
            }
        } catch (\Throwable $_) {}
        $materialsNote = empty($materialTitles) ? 'the provided class materials' : implode(', ', array_slice($materialTitles, 0, 3));

        // 5) Define target distribution for understanding results
        $distribution = array_merge(
            array_fill(0, 16, 'Understanding'),
            array_fill(0, 4, 'Not Fully Understanding'),
            array_fill(0, 10, 'Not Understanding'),
        );

        // Make deterministic order by user id then chatroom id
        $studentMemberships = $studentMemberships->sortBy(function ($m) {
            return sprintf('%06d-%06d', (int)($m->fk_id_user ?? 0), (int)($m->fk_id_chatroomai ?? 0));
        })->values();

        // 6) Iterate memberships and seed summary + understanding + minimal chat
        $i = 0;
        foreach ($studentMemberships as $m) {
            $uid = $m->fk_id_user;
            $cid = $m->fk_id_chatroomai;
            if (!$uid || !$cid) continue;

            // a) Summary (idempotent)
            $summary = SummaryDiscussion::firstOrCreate([
                'fk_id_user' => $uid,
                'fk_id_chatroomai' => $cid,
            ], [
                'content' => "I've started to understand some topics about $materialsNote.",
            ]);

            // b) Understanding result upsert with target type
            $type = $distribution[min($i, count($distribution) - 1)];
            $existingRU = ResultUnderstanding::where('fk_id_summarydiscussion', $summary->id_summarydiscussion)->first();
            if ($existingRU) {
                if ($existingRU->type !== $type) {
                    $existingRU->type = $type;
                    $existingRU->save();
                }
            } else {
                ResultUnderstanding::create([
                    'fk_id_summarydiscussion' => $summary->id_summarydiscussion,
                    'type' => $type,
                ]);
            }

            // c) Minimal chat: one student message + one AI reply (idempotent-ish)
            try {
                DiscussionMessage::firstOrCreate([
                    'fk_id_chatroomai' => $cid,
                    'fk_id_user' => $uid,
                    'role' => 'student',
                    'content' => "Question about $materialsNote: can you clarify one key point?",
                ], [
                    'content_type' => 'text',
                    'status' => 'sent',
                    'response_meta' => null,
                ]);
            } catch (\Throwable $_) {}

            try {
                AIMessage::firstOrCreate([
                    'fk_id_chatroomai' => $cid,
                    'role' => 'ai',
                    'content' => "AI: Here's a brief explanation based on $materialsNote.",
                ], [
                    'content_type' => 'text',
                    'status' => 'sent',
                    'response_meta' => null,
                ]);
            } catch (\Throwable $_) {}

            $i++;
        }

        // 7) Mark these chatrooms as inactive to indicate prior activity
        foreach ($chatrooms as $cr) {
            if ($cr->status !== 'inactive') {
                $cr->status = 'inactive';
                $cr->save();
            }
        }
    }
}
