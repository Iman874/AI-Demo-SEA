<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class DiscussionDataController extends Controller
{
    // GET /api/discussion-questions?chatroom_id=...
    public function questions(Request $request)
    {
        $chatroom = $request->query('chatroom_id');
        if (!class_exists('\App\Models\DiscussionQuestion')) {
            return response()->json(['data' => []]);
        }
        $query = \App\Models\DiscussionQuestion::query();
        if ($chatroom) $query->where('fk_id_chatroomai', $chatroom);
        $items = $query->orderBy('created_at', 'asc')->get();
        return response()->json(['data' => $items]);
    }

    // GET /api/discussion-summaries?chatroom_id=...
    public function summaries(Request $request)
    {
        $chatroom = $request->query('chatroom_id');
        if (!class_exists('\App\Models\SummaryDiscussion')) {
            return response()->json(['data' => []]);
        }
        $query = \App\Models\SummaryDiscussion::query();
        if ($chatroom) $query->where('fk_id_chatroomai', $chatroom);
        $items = $query->orderBy('created_at', 'desc')->get();

        // Auto-backfill understanding results for summaries that don't have one yet
    if ($chatroom && class_exists('\App\Models\ResultUnderstanding')) {
            // Load materials for this chatroom (if schema supports it)
            $materials = [];
            try {
                if (class_exists('\App\Models\MaterialQuiz')) {
                    $mats = \App\Models\MaterialQuiz::where('fk_id_discussionroom', $chatroom)->get();
                    foreach ($mats as $m) {
                        $materials[] = [
                            'title' => $m->title ?? '',
                            'content' => $m->content ?? '',
                        ];
                    }
                }
            } catch (\Throwable $_) {}

            // Build reference once
            $referenceText = '';
            foreach ($materials as $mat) {
                $referenceText .= "[Material Title]: " . ($mat['title'] ?? '') . "\n";
                $referenceText .= "[Material Content]: " . ($mat['content'] ?? '') . "\n\n";
            }

            foreach ($items as $s) {
                try {
                    $exists = \App\Models\ResultUnderstanding::where('fk_id_summarydiscussion', $s->id_summarydiscussion)->first();
                    if ($exists) continue;

                    $prompt = "You are an evaluator for student understanding. Your main reference is the provided materials, even if the material is wrong, always trust the material first. Now, compare the following summary with the materials. Only reply with one of these exactly: Understanding, Not Fully Understanding, Not Understanding. If you can't decide, reply with your own answer.\n\nMaterials:\n" . $referenceText . "Summary:\n" . ($s->content ?? '') . "\n";

                    try {
                        $resp = \Illuminate\Support\Facades\Http::withHeaders([
                            'Content-Type' => 'application/json',
                            'X-goog-api-key' => env('GEMINI_API_KEY'),
                        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
                            'contents' => [[ 'parts' => [[ 'text' => $prompt ]] ]]
                        ]);
                        if ($resp->successful()) {
                            $raw = $resp->json()['candidates'][0]['content']['parts'][0]['text'] ?? '';
                            $norm = trim($raw);
                            $valid = ['Understanding','Not Fully Understanding','Not Understanding'];
                            $final = in_array($norm, $valid) ? $norm : $raw;
                            \App\Models\ResultUnderstanding::create([
                                'fk_id_summarydiscussion' => $s->id_summarydiscussion,
                                'type' => $final,
                            ]);
                        }
                    } catch (\Throwable $_) {}
                } catch (\Throwable $_) {}
            }
        }
        return response()->json(['data' => $items]);
    }

    // GET /api/discussion-understandings?summary_id=... | ?chatroom_id=... | ?discussion_id=...
    public function understandings(Request $request)
    {
        $req = isset($request) ? $request : request();
        $summaryId = $req->query('summary_id');
        $chatroomId = $req->query('chatroom_id');
        $discussionId = $req->query('discussion_id');

        if (!class_exists('\App\Models\ResultUnderstanding')) {
            return response()->json(['data' => []]);
        }

        // Case 1: filter by a single summary id
        if ($summaryId) {
            $items = \App\Models\ResultUnderstanding::where('fk_id_summarydiscussion', $summaryId)->get();
            return response()->json(['data' => $items]);
        }

        // Case 2: filter by chatroom id (all summaries within that chatroom)
        if ($chatroomId && class_exists('\App\Models\SummaryDiscussion')) {
            $sumIds = \App\Models\SummaryDiscussion::where('fk_id_chatroomai', $chatroomId)
                ->pluck('id_summarydiscussion')
                ->all();
            if (empty($sumIds)) return response()->json(['data' => []]);
            $items = \App\Models\ResultUnderstanding::whereIn('fk_id_summarydiscussion', $sumIds)->get();
            return response()->json(['data' => $items]);
        }

        // Case 3: filter by discussion id (aggregate across all chatrooms under the discussion)
        if ($discussionId && class_exists('\App\Models\ChatRoomAI') && class_exists('\App\Models\SummaryDiscussion')) {
            $chatIds = \App\Models\ChatRoomAI::where('fk_id_discussionroom', $discussionId)
                ->pluck('id_chatroomai')
                ->all();
            if (empty($chatIds)) return response()->json(['data' => []]);
            $sumIds = \App\Models\SummaryDiscussion::whereIn('fk_id_chatroomai', $chatIds)
                ->pluck('id_summarydiscussion')
                ->all();
            if (empty($sumIds)) return response()->json(['data' => []]);
            $items = \App\Models\ResultUnderstanding::whereIn('fk_id_summarydiscussion', $sumIds)->get();
            return response()->json(['data' => $items]);
        }

        // Default: return all (not recommended for large datasets, but maintains backwards compatibility)
        $items = \App\Models\ResultUnderstanding::all();
        return response()->json(['data' => $items]);
    }
}
