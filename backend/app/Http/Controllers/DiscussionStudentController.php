<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DiscussionStudent;
use App\Models\DiscussionGroup;
use App\Models\ChatRoomAI;
use App\Models\User;

class DiscussionStudentController extends Controller
{
    /**
     * GET /api/discussion-members
     * Supported queries:
     *  - ?discussion_id=XXX [optional user_id for group scoping]
     *  - ?chatroom_id=YYY [optional user_id for group scoping]
     * Behavior:
     *  - If user_id is provided and a DiscussionGroup mapping exists, return ONLY the members
     *    in the same group_no as that user for the targeted discussion/chatroom.
     *  - Otherwise, return all members of the targeted discussion/chatroom.
     */
    public function members(Request $request)
    {
        $discussionId = $request->query('discussion_id');
        $chatroomId   = $request->query('chatroom_id');
        $userId       = $request->query('user_id');

        // Helper to map User collection to payload
        $mapUsers = function($users) {
            return $users->map(function ($u) {
                if ($u) {
                    return [
                        'id_user' => $u->id_user ?? '',
                        'name'    => $u->name ?? '',
                        'email'   => $u->email ?? '',
                        'role'    => $u->role ?? '',
                    ];
                }
                return null;
            })->filter()->values();
        };

        // Group-scoped lookup if user_id provided
        if ($userId && ($discussionId || $chatroomId)) {
            // Resolve target chatroom ids for the discussion or the single chatroom id
            $chatroomIds = [];
            if ($discussionId) {
                $chatroomIds = ChatRoomAI::where('fk_id_discussionroom', $discussionId)->pluck('id_chatroomai')->toArray();
            } else if ($chatroomId) {
                $chatroomIds = [$chatroomId];
            }

            if (!empty($chatroomIds)) {
                // Find the user's group mapping in these chatrooms
                $ug = DiscussionGroup::whereIn('fk_id_chatroomai', $chatroomIds)
                    ->where('fk_id_user', $userId)
                    ->first();
                if ($ug) {
                    $groupMembersIds = DiscussionGroup::where('fk_id_chatroomai', $ug->fk_id_chatroomai)
                        ->where('group_no', $ug->group_no)
                        ->pluck('fk_id_user')
                        ->toArray();
                    if (!empty($groupMembersIds)) {
                        $users = User::whereIn('id_user', $groupMembersIds)->get();
                        return response()->json(['data' => $mapUsers($users)], 200);
                    }
                    // If group empty fallback to generic list for safety
                }
            }
        }

        // Fallbacks: original behavior returning all members
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
