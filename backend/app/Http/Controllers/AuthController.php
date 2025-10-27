<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\ApiToken;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $data = $request->only(['name', 'email', 'password', 'role']);
        // minimal validation
        if (empty($data['name']) || empty($data['email']) || empty($data['password']) || empty($data['role'])) {
            return response()->json(['message' => 'Missing fields'], 422);
        }

        if (!in_array($data['role'], ['student', 'teacher'])) {
            return response()->json(['message' => 'Invalid role'], 422);
        }

        if (User::where('email', $data['email'])->exists()) {
            return response()->json(['message' => 'Email already taken'], 422);
        }

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => $data['role'],
        ]);

        return response()->json(['message' => 'User created', 'user' => $user], 201);
    }

    public function login(Request $request)
    {
        $email = $request->input('email');
        $password = $request->input('password');

        $user = User::where('email', $email)->first();
        if (!$user) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // Only allow teacher and student
        if (!in_array($user->role, ['teacher', 'student'])) {
            return response()->json(['message' => 'Role not allowed to login'], 403);
        }

        if (!Hash::check($password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        // create token
        $token = hash('sha256', Str::random(40));
        ApiToken::create([
            'user_id' => $user->id_user,
            'token' => $token,
        ]);

        return response()->json(['token' => $token, 'user' => $user], 200);
    }

    public function user(Request $request)
    {
        $header = $request->header('Authorization');
        if (!$header || !str_starts_with($header, 'Bearer ')) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }
        $token = substr($header, 7);
        $record = ApiToken::where('token', $token)->first();
        if (!$record) {
            return response()->json(['message' => 'Invalid token'], 401);
        }
        $user = User::where('id_user', $record->user_id)->first();
        if (!$user) return response()->json(['message' => 'User not found'], 404);
        return response()->json(['user' => $user], 200);
    }
}
