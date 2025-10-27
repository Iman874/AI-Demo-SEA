<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DiscussionStudent;
use App\Models\ChatRoomAI;
use App\Models\User;

class DiscussionStudentController extends Controller
{
    /**
     * GET /api/discussion-members?discussion_id=xxx OR ?chatroom_id=yyy
     * Returns an array of user objects participating in the chat room.
     */
    public function members(Request $request)
    {
        $discussionId = $request->query('discussion_id');
        $chatroomId = $request->query('chatroom_id');

        // If discussion_id was provided, find corresponding chat_room_ai entries
        if ($discussionId) {
            $chatrooms = ChatRoomAI::where('fk_id_discussionroom', $discussionId)->pluck('id_chatroomai')->toArray();
            if (empty($chatrooms)) {
                return response()->json(['data' => []], 200);
            }
            $members = DiscussionStudent::whereIn('fk_id_chatroomai', $chatrooms)->with('user')->get();
        } elseif ($chatroomId) {
            $members = DiscussionStudent::where('fk_id_chatroomai', $chatroomId)->with('user')->get();
        } else {
            return response()->json(['message' => 'discussion_id or chatroom_id required'], 422);
        }

        // Map to user payloads
        $users = $members->map(function ($ds) {
            if ($ds->user) {
                return [
                    'id_user' => $ds->user->id_user ?? '',
                    'name' => $ds->user->name ?? '',
                    'email' => $ds->user->email ?? '',
                    'role' => $ds->user->role ?? '',
                ];
            }
            return null;
        })->filter()->values();

        return response()->json(['data' => $users], 200);
    }
}
