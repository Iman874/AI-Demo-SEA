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
        return response()->json(['data' => $items]);
    }

    // GET /api/discussion-understandings?summary_id=...
    public function understandings(Request $request)
    {
        $summaryId = $request->query('summary_id');
        if (!class_exists('\App\Models\ResultUnderstanding')) {
            return response()->json(['data' => []]);
        }
        $query = \App\Models\ResultUnderstanding::query();
        if ($summaryId) $query->where('fk_id_summarydiscussion', $summaryId);
        $items = $query->get();
        return response()->json(['data' => $items]);
    }
}
