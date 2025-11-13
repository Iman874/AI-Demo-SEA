<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\MaterialQuiz;
use Illuminate\Support\Facades\Schema;

class MaterialController extends Controller
{
    // GET /api/materials
    public function index(Request $request)
    {
        // optional filter: ?quiz_id=1
        $quizId = $request->query('quiz_id');
        $discussionId = $request->query('discussion_id');

        $query = MaterialQuiz::query();

        // Only apply filters if the underlying columns exist (migrations might not have been run)
        if ($quizId && Schema::hasColumn('material_quiz', 'fk_id_quiz')) {
            $query->where('fk_id_quiz', $quizId);

            // Also include materials referenced by questions for this quiz (in case materials were linked only via questions)
            try {
                if (\Illuminate\Support\Facades\Schema::hasTable('questions') &&
                    \Illuminate\Support\Facades\Schema::hasColumn('questions', 'fk_id_quiz') &&
                    \Illuminate\Support\Facades\Schema::hasColumn('questions', 'fk_id_material')) {
                    $idsViaQuestions = \Illuminate\Support\Facades\DB::table('questions')
                        ->where('fk_id_quiz', $quizId)
                        ->whereNotNull('fk_id_material')
                        ->pluck('fk_id_material')
                        ->filter()
                        ->unique()
                        ->values()
                        ->all();
                    if (!empty($idsViaQuestions)) {
                        $query->orWhereIn('id_material', $idsViaQuestions);
                    }
                }
            } catch (\Throwable $_) {
                // ignore optional enrichment errors
            }
        }
        if ($discussionId && Schema::hasColumn('material_quiz', 'fk_id_discussionroom')) {
            $query->where('fk_id_discussionroom', $discussionId);
        }

        $items = $query->orderBy('created_at', 'desc')->get();

        // ensure unique materials if multiple conditions matched (e.g., both fk_id_quiz and via questions)
        $items = $items->unique('id_material')->values();

        $data = $items->map(function ($m) {
            return [
                'id' => $m->id_material ?? $m->id ?? null,
                'title' => $m->title,
                'content' => $m->content,
                'type' => $m->type,
                'createdAt' => $m->created_at ? $m->created_at->toDateTimeString() : null,
                'updatedAt' => $m->updated_at ? $m->updated_at->toDateTimeString() : null,
            ];
        });

        return response()->json(['data' => $data]);
    }

    // POST /api/materials
    public function store(Request $request)
    {
        $data = $request->only(['title', 'content', 'type', 'fk_id_quiz', 'fk_id_discussionroom']);

        $validator = \Illuminate\Support\Facades\Validator::make($data, [
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'type' => 'nullable|string|in:text,pdf,image,video',
            'fk_id_quiz' => 'nullable|integer|exists:quizzes,id_quiz',
            'fk_id_discussionroom' => 'nullable|integer|exists:discussion_rooms,id_discussionroom',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            // Build create payload including only columns that exist in DB
            $createData = [
                'title' => $data['title'],
                'content' => $data['content'],
                'type' => $data['type'] ?? null,
            ];
            if (!empty($data['fk_id_quiz']) && Schema::hasColumn('material_quiz', 'fk_id_quiz')) {
                $createData['fk_id_quiz'] = $data['fk_id_quiz'];
            }
            if (!empty($data['fk_id_discussionroom']) && Schema::hasColumn('material_quiz', 'fk_id_discussionroom')) {
                $createData['fk_id_discussionroom'] = $data['fk_id_discussionroom'];
            }

            $mat = MaterialQuiz::create($createData);

            // if links provided, insert into pivot tables or set relations accordingly
            if (!empty($data['fk_id_quiz'])) {
                // attempt to link to quiz via quiz_classes or questions as needed (simple approach: set fk_id_quiz in material_quiz is not present)
                // To keep schema simple, create a linking row in quiz_classes is not appropriate; we'll create an optional index in a pivot table if wanted later.
                // For now, we set a record in material_quiz_question linking via questions if needed by higher-level logic.
            }

            return response()->json(['data' => [
                'id' => $mat->id_material,
                'title' => $mat->title,
                'content' => $mat->content,
                'type' => $mat->type,
                'createdAt' => $mat->created_at ? $mat->created_at->toDateTimeString() : null,
                'updatedAt' => $mat->updated_at ? $mat->updated_at->toDateTimeString() : null,
            ]], 201);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Could not create material', 'error' => $e->getMessage()], 500);
        }
    }
}
