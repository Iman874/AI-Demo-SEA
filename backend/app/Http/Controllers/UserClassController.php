<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SchoolClass;
use App\Models\User;
use App\Models\UserClass;
use App\Models\ApiToken;
use Illuminate\Support\Facades\DB;

class UserClassController extends Controller
{
    /**
     * Join a class using a class code. Identification is via Bearer token
     * or an explicit user_id in the request body (development convenience).
     *
     * POST /api/join-class { code_class: string, user_id?: string }
     */
    public function join(Request $request)
    {
        $code = $request->input('code_class');
        if (empty($code)) {
            return response()->json(['message' => 'Missing code_class'], 422);
        }

        // Try to identify user from Authorization header first
        $user = null;
        $header = $request->header('Authorization');
        if ($header && str_starts_with($header, 'Bearer ')) {
            $token = substr($header, 7);
            $record = ApiToken::where('token', $token)->first();
            if ($record) {
                $user = User::where('id_user', $record->user_id)->first();
            }
        }

        // Fallback: allow passing user_id in body for local/dev usage
        if (!$user && $request->filled('user_id')) {
            $user = User::where('id_user', $request->input('user_id'))->first();
        }

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated or user not found'], 401);
        }

        if (($user->role ?? '') !== 'student') {
            return response()->json(['message' => 'Only students are allowed to join classes'], 403);
        }

        $cls = SchoolClass::where('code_class', $code)->first();
        if (!$cls) {
            return response()->json(['message' => 'Class code not found'], 404);
        }

        $exists = UserClass::where('fk_id_user', $user->id_user)
            ->where('fk_id_class', $cls->id_class)
            ->exists();

        if ($exists) {
            return response()->json(['message' => 'Already joined this class', 'data' => $cls], 200);
        }

        $uc = UserClass::create([
            'fk_id_user' => $user->id_user,
            'fk_id_class' => $cls->id_class,
            'role' => 'student',
            'joined_at' => now(),
        ]);

        return response()->json(['message' => "Successfully joined class '{$cls->name}'", 'data' => $cls], 201);
    }

    /**
     * Return classes that the authenticated student has joined.
     * GET /api/my-classes
     */
    public function myClasses(Request $request)
    {
        // Identify user via Authorization header first
        $user = null;
        $header = $request->header('Authorization');
        if ($header && str_starts_with($header, 'Bearer ')) {
            $token = substr($header, 7);
            $record = ApiToken::where('token', $token)->first();
            if ($record) {
                $user = User::where('id_user', $record->user_id)->first();
            }
        }

        // Fallback for development: allow user_id in query
        if (!$user && $request->filled('user_id')) {
            $user = User::where('id_user', $request->input('user_id'))->first();
        }

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated or user not found'], 401);
        }

        // fetch classes joined by the user via user_classes table
        $classes = SchoolClass::join('user_classes', 'school_classes.id_class', '=', 'user_classes.fk_id_class')
            ->where('user_classes.fk_id_user', $user->id_user)
            ->select(['school_classes.id_class','school_classes.code_class','school_classes.name','school_classes.description','school_classes.semester','school_classes.created_by','school_classes.created_at','school_classes.updated_at'])
            ->get();

        return response()->json(['data' => $classes], 200);
    }

    /**
     * Return only class ids (fk_id_class) joined by the authenticated student.
     * GET /api/user-class-ids
     */
    public function userClassIds(Request $request)
    {
        // Identify user via Authorization header first
        $user = null;
        $header = $request->header('Authorization');
        if ($header && str_starts_with($header, 'Bearer ')) {
            $token = substr($header, 7);
            $record = ApiToken::where('token', $token)->first();
            if ($record) {
                $user = User::where('id_user', $record->user_id)->first();
            }
        }

        // Fallback for development: allow user_id in query
        if (!$user && $request->filled('user_id')) {
            $user = User::where('id_user', $request->input('user_id'))->first();
        }

        if (!$user) {
            return response()->json(['message' => 'Unauthenticated or user not found'], 401);
        }

        $ids = UserClass::where('fk_id_user', $user->id_user)->pluck('fk_id_class')->toArray();
        return response()->json(['data' => $ids], 200);
    }

    /**
     * GET /api/class-members?class_id=xxx
     * Return users that belong to a given class.
     */
    public function classMembers(Request $request)
    {
        $classId = $request->query('class_id');
        if (!$classId) return response()->json(['data' => []], 200);

    $rows = DB::table('user_classes')
            ->where('fk_id_class', $classId)
            ->join('users', 'users.id_user', '=', 'user_classes.fk_id_user')
            ->select('users.id_user as id_user', 'users.name', 'users.email', 'users.role')
            ->get();

        return response()->json(['data' => $rows], 200);
    }
}
