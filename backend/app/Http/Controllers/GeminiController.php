<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class GeminiController extends Controller
{
    public function askGemini(Request $request)
    {
        $prompt = $request->input('prompt');

        // call API Gemini
        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'), // simpan API key di .env
        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ]
        ]);

        // ambil text dari response
        $result = $response->json();

        if (isset($result['candidates'][0]['content']['parts'][0]['text'])) {
            return response()->json([
                'answer' => $result['candidates'][0]['content']['parts'][0]['text']
            ]);
        }

        return response()->json([
            'error' => 'No response from Gemini API',
            'raw' => $result
        ], 500);
    }

     public function echoRequest(Request $request)
    {
        // langsung balikin data yang dikirim client
        return response()->json([
            'received' => $request->all()
        ]);
    }

   public function chatStudent(Request $request)
   {
       $history = $request->input('history', []);
        $materials = $request->input('materials', []);
        $chatroomId = $request->input('chatroom_id');
        $senderId = $request->input('sender_id');

        // Gabungkan semua judul dan konten dari materials
        $referenceText = '';
        foreach ($materials as $mat) {
            $referenceText .= "[Material Title]: " . ($mat['title'] ?? '') . "\n";
            $referenceText .= "[Material Content]: " . ($mat['content'] ?? '') . "\n\n";
        }

        // Ambil pesan terbaru dari user
        $lastUserMsg = null;
        for ($i = count($history) - 1; $i >= 0; $i--) {
            if ($history[$i]['role'] === 'student') {
                $lastUserMsg = $history[$i]['content'];
                break;
            }
        }

        // Gabungkan prompt
        $prompt = "[Take reference from Material Content if there is any related even if it is wrong].\n"
            . $referenceText
            . "History:\n";
        foreach ($history as $msg) {
            $prompt .= "[" . ($msg['role'] ?? '') . "]: " . ($msg['content'] ?? '') . "\n";
        }
        $prompt .= "\nUser Question:\n" . ($lastUserMsg ?? '');

        // Persist last student message (if chatroom + sender provided)
        try {
            if ($chatroomId && $senderId && $lastUserMsg) {
                \App\Models\DiscussionMessage::create([
                    'fk_id_chatroomai' => $chatroomId,
                    'fk_id_user' => $senderId,
                    'role' => 'student',
                    'content' => $lastUserMsg,
                    'content_type' => 'text',
                    'status' => 'sent',
                ]);
            }
        } catch (\Throwable $e) {
            // ignore persistence errors, still attempt AI call
        }

        // Panggil API Gemini
        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'),
        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ]
        ]);

        if ($response->successful()) {
            $aiText = $response->json()['candidates'][0]['content']['parts'][0]['text'];

            // save AI reply if chatroom available
            try {
                if ($chatroomId) {
                    \App\Models\DiscussionMessage::create([
                        'fk_id_chatroomai' => $chatroomId,
                        'fk_id_user' => null,
                        'role' => 'ai',
                        'content' => $aiText,
                        'content_type' => 'text',
                        'status' => 'sent',
                        'response_meta' => json_encode(['model' => env('GEMINI_API_KEY') ? 'gemini' : 'unknown']),
                    ]);
                }
            } catch (\Throwable $e) {
                // ignore persistence errors
            }

            return response()->json([
                'answer' => $aiText
            ]);
        }

        return response()->json([
            'error' => 'No response from Gemini API',
            'raw' => $response->json()
        ], 500);
    }

    public function check_understanding(Request $request)
    {
        $materials = $request->input('materials', []);
        $summary = $request->input('summary', '');

        // Gabungkan semua data untuk prompt
        $referenceText = '';
        foreach ($materials as $mat) {
            $referenceText .= "[Material Title]: " . ($mat['title'] ?? '') . "\n";
            $referenceText .= "[Material Content]: " . ($mat['content'] ?? '') . "\n\n";
        }

        $prompt = "You are an evaluator for student understanding. Your main reference is the provided materials, even if the material is wrong, always trust the material first. Now, compare the following summary with the materials. Is the summary relevant and matches the materials? Only reply with one of these: Understanding, Not Fully Understanding, Not Understanding. If you can't decide, reply with your own answer.\n\n"
            . "Materials:\n" . $referenceText
            . "Summary:\n" . $summary . "\n";

        // Call Gemini API
        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'),
        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ]
        ]);

        $result = $response->json();
        $answer = $result['candidates'][0]['content']['parts'][0]['text'] ?? '';

        $validAnswers = [
            'Understanding',
            'Not Fully Understanding',
            'Not Understanding'
        ];

        $normalized = trim($answer);
        if (in_array($normalized, $validAnswers)) {
            return response()->json(['result' => $normalized]);
        } else {
            return response()->json(['result' => $answer]);
        }
    }

    public function generateQuestions(Request $request)
    {
        $materials = $request->input('materials', []);

        // Build reference text from materials
        $referenceText = '';
        foreach ($materials as $mat) {
            $referenceText .= "Material Title: " . ($mat['title'] ?? '') . "\n";
            $referenceText .= "Material Content: " . ($mat['content'] ?? '') . "\n\n";
        }

        // English prompt per user's spec
        $prompt = "Create exam-style questions from the provided reference materials. For each question, assign a point value and include the related material title. Each material can have multiple questions. Ensure a mix of difficulty levels: very easy (5), easy (10), medium (15), hard (20). Provide output in a clear numbered format. Example output format (use similar structure):\n\n";
        $prompt .= "For each question include: number, question text, point, related_material_title, and 3-4 choices with one marked as correct.\n\n";
        $prompt .= "Materials:\n" . $referenceText;
        $prompt .= "\nGenerate questions now.";

        // Call Gemini API
        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'),
        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ]
        ]);

        if ($response->successful()) {
            $raw = $response->json();
            $text = $raw['candidates'][0]['content']['parts'][0]['text'] ?? '';
            return response()->json(['result' => $text]);
        }

        return response()->json(['error' => 'No response from Gemini API', 'raw' => $response->json()], 500);
    }

    public function generateGroups(Request $request)
    {
        $classId = $request->input('class_id');
        $groupCount = $request->input('group_count');
        $perGroup = $request->input('per_group');
        $quizId = $request->input('quiz_id');

        // build student list from class if class_id provided
        $students = [];
        try {
                if ($classId && Schema::hasTable('user_classes')) {
                $rows = DB::table('user_classes')->where('fk_id_class', $classId)->get();
                $userIds = $rows->pluck('fk_id_user')->toArray();
                $users = \App\Models\User::whereIn('id_user', $userIds)->get();
                foreach ($users as $u) {
                    $students[] = ['id' => $u->id_user ?? $u->id ?? null, 'name' => $u->name ?? ''];
                }
            }
        } catch (\Throwable $e) {
            // ignore and fallback to empty student list
        }

        // if no students found, allow passing students list directly
        $inputStudents = $request->input('students', []);
        if (empty($students) && is_array($inputStudents) && count($inputStudents) > 0) {
            foreach ($inputStudents as $s) {
                $students[] = ['id' => $s['id'] ?? $s['fk_id_user'] ?? null, 'name' => $s['name'] ?? ''];
            }
        }

        // fetch quiz results if quiz_id provided
        $quizResultsText = '';
        if ($quizId) {
            try {
                    if (Schema::hasTable('result_quiz')) {
                    $results = DB::table('result_quiz')->where('fk_id_quiz', $quizId)->get();
                    foreach ($results as $r) {
                        $uid = $r->fk_id_user ?? $r->user_id ?? null;
                        $user = \App\Models\User::find($uid);
                        $name = $user ? ($user->name ?? '') : ($r->name ?? '');
                        $points = $r->point ?? $r->score ?? $r->total ?? 0;
                        $quizResultsText .= "{$uid} - {$name} : {$points}\n";
                    }
                }
            } catch (\Throwable $e) {
                // ignore
            }
        }

        $studentCount = count($students);

        // build prompt for Gemini
        $prompt = "Create discussion groups for {$studentCount} students." . "\n";
        if ($groupCount) $prompt .= "Requested group count: {$groupCount}.\n";
        if ($perGroup) $prompt .= "Requested per-group size: {$perGroup}.\n";

        $prompt .= "Students:\n";
        foreach ($students as $s) {
            $prompt .= ($s['id'] ?? '') . ' - ' . ($s['name'] ?? '') . "\n";
        }

        if (!empty($quizResultsText)) {
            $prompt .= "\nQuiz Results (id_user - name : points):\n" . $quizResultsText . "\n";
            $prompt .= "Produce group assignments taking into account quiz results.\n";
        } else {
            $prompt .= "\nNo quiz results provided. Randomize groups.\n";
        }

    // Strongly instruct the model to ONLY output lines in the exact required format.
    $prompt .= "\nIMPORTANT: The output MUST contain ONLY group assignment lines, one group per line, and NOTHING else.\n";
    $prompt .= "Every student must be assigned to exactly one group. Do not leave anyone out or duplicate students.\n";
    $prompt .= "Distribute students evenly: compute base = floor(total_students / requested_group_count) and assign exactly base students to each group.\n";
    $prompt .= "If there are leftover students (remainder), randomly assign each leftover student to one of the existing groups (do NOT create new groups).\n";
    $prompt .= "Each line must be exactly in the format: <group_number>, (id_user, name), (id_user, name), ...\n";
    $prompt .= "Group numbers must be integers 1..{$groupCount}. Use the requested group count and do not output groups outside this range.\n";
    $prompt .= "Do NOT include any explanation, headers, numbering, bullets, or extra text. Do not wrap output in code blocks.\n";
    $prompt .= "Example output (must follow precisely):\n1, (123, John Doe), (124, Jane Doe)\n2, (125, Bob), (126, Alice)\n";

        // call Gemini API
        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
            'X-goog-api-key' => env('GEMINI_API_KEY'),
        ])->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent', [
            'contents' => [
                [
                    'parts' => [
                        ['text' => $prompt]
                    ]
                ]
            ]
        ]);

        if ($response->successful()) {
            $raw = $response->json();
            $text = $raw['candidates'][0]['content']['parts'][0]['text'] ?? '';

            // Post-process: extract lines that match the new format: "no_grup, (id, name), (id, name), ..."
            preg_match_all('/^\s*([0-9A-Za-z_-]+)\s*,\s*(\(.*\))\s*$/m', $text, $matches, PREG_SET_ORDER);

            // helper: collect all student ids from AI output lines
            $aiAssignedIds = [];
            $filteredLines = [];
            if (!empty($matches)) {
                foreach ($matches as $m) {
                    $line = trim($m[0]);
                    // extract all (id, name) pairs within the second capture
                    $pairsText = $m[2];
                    preg_match_all('/\(([^,\)]+)\s*,\s*([^\)]+)\)/', $pairsText, $pairs, PREG_SET_ORDER);
                    foreach ($pairs as $p) {
                        $idPart = trim($p[1]);
                        if ($idPart !== '') $aiAssignedIds[$idPart] = true;
                    }
                    $filteredLines[] = $line;
                }
            }

            // verify all students are present in AI output
            $allAssigned = true;
            if (count($students) > 0) {
                foreach ($students as $s) {
                    $sid = (string)($s['id'] ?? $s['id_user'] ?? $s['id'] ?? '');
                    if ($sid === '') continue;
                    if (!isset($aiAssignedIds[$sid])) { $allAssigned = false; break; }
                }
            } else {
                $allAssigned = false; // no students known, treat as not complete
            }

            if ($allAssigned && !empty($filteredLines)) {
                // AI provided valid assignments that include all students
                $filtered = implode("\n", $filteredLines);
                return response()->json(['result' => $filtered], 200);
            }

            // Fallback: AI output missing students or malformed. Build server-side grouping deterministically.
            // Shuffle students and assign base size then randomly assign remainders to existing groups.
            try {
                // prepare a simple array of students with id and name
                $pool = [];
                foreach ($students as $s) {
                    $pool[] = ['id' => (string)($s['id'] ?? $s['id_user'] ?? ''), 'name' => ($s['name'] ?? '')];
                }
                // shuffle for randomness
                shuffle($pool);
                $total = count($pool);
                $base = ($groupCount > 0) ? intdiv($total, $groupCount) : $total;
                if ($base < 1) $base = 1;
                $remainder = $total - ($base * $groupCount);

                // initialize groups
                $groups = [];
                for ($g = 1; $g <= $groupCount; $g++) $groups[$g] = [];

                $index = 0;
                // assign base members
                for ($g = 1; $g <= $groupCount; $g++) {
                    for ($k = 0; $k < $base && $index < $total; $k++) {
                        $groups[$g][] = $pool[$index++];
                    }
                }

                // assign remainder randomly to existing groups
                if ($remainder > 0) {
                    // pick random group numbers with replacement
                    for ($r = 0; $r < $remainder && $index < $total; $r++) {
                        $randGroup = rand(1, max(1, $groupCount));
                        $groups[$randGroup][] = $pool[$index++];
                    }
                }

                // format output lines
                $outLines = [];
                foreach ($groups as $gno => $members) {
                    $parts = [];
                    foreach ($members as $memb) {
                        $parts[] = '(' . ($memb['id'] ?? '') . ', ' . ($memb['name'] ?? '') . ')';
                    }
                    $outLines[] = $gno . ', ' . implode(', ', $parts);
                }

                $filtered = implode("\n", $outLines);
                return response()->json(['result' => $filtered, 'note' => 'fallback: server-distributed'], 200);
            } catch (\Throwable $_) {
                // final fallback: return raw text
                return response()->json(['result' => $text], 200);
            }

            // fallback: return raw text if no structured lines could be parsed
            return response()->json(['result' => $text], 200);
        }

        return response()->json(['error' => 'No response from Gemini API', 'raw' => $response->json()], 500);
    }

    public function deleteAllDiscussionMessages(Request $request)
    {
        $chatroomId = $request->input('chatroom_id');
        if (!$chatroomId) {
            return response()->json(['message' => 'chatroom_id required'], 422);
        }
        try {
            \App\Models\DiscussionMessage::where('fk_id_chatroomai', $chatroomId)->delete();
            return response()->json(['message' => 'deleted'], 200);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'error deleting'], 500);
        }
    }

    /**
     * GET discussion messages for a chatroom
     * Query param: chatroom_id
     */
    public function getDiscussionMessages(Request $request)
    {
        $chatroomId = $request->query('chatroom_id');
        if (!$chatroomId) {
            return response()->json(['message' => 'chatroom_id required'], 422);
        }

        try {
            $msgs = \App\Models\DiscussionMessage::where('fk_id_chatroomai', $chatroomId)
                ->orderBy('created_at', 'asc')
                ->get();

            return response()->json(['data' => $msgs], 200);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'error fetching messages', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * GET summaries for a chatroom
     * Query param: chatroom_id
     */
    public function getDiscussionSummaries(Request $request)
    {
        $chatroomId = $request->query('chatroom_id');
        if (!$chatroomId) {
            return response()->json(['message' => 'chatroom_id required'], 422);
        }

        try {
            $summaries = \App\Models\SummaryDiscussion::where('fk_id_chatroomai', $chatroomId)
                ->orderBy('created_at', 'asc')
                ->get();

            return response()->json(['data' => $summaries], 200);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'error fetching summaries', 'error' => $e->getMessage()], 500);
        }
    }

    public function submitDiscussionSummary(Request $request)
    {
        $chatroomId = $request->input('chatroom_id');
        $userId = $request->input('user_id');
        $content = $request->input('content');

        if (!$chatroomId || !$userId || !$content) {
            return response()->json(['message' => 'chatroom_id, user_id and content required'], 422);
        }

        try {
            // create summary
            $summary = \App\Models\SummaryDiscussion::create([
                'fk_id_chatroomai' => $chatroomId,
                'fk_id_user' => $userId,
                'content' => $content,
            ]);

            // mark discussion_students row as completed (if table exists)
            if (Schema::hasTable('discussion_students')) {
                \App\Models\DiscussionStudent::updateOrCreate(
                    ['fk_id_chatroomai' => $chatroomId, 'fk_id_user' => $userId],
                    ['updated_at' => now()]
                );
            }

            return response()->json(['message' => 'ok', 'summary' => $summary], 200);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'error saving summary', 'error' => $e->getMessage()], 500);
        }
    }

}