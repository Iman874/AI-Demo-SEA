<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Quiz;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Log;
use App\Models\ResultQuiz;

class QuizController extends Controller
{
    /**
     * Parse a duration value which may be an integer or a human string like "1 Hour 30 Minute"
     * Returns integer minutes or null when not parseable.
     */
    private function parseDuration($duration)
    {
        if ($duration === null) return null;
        // if already numeric, return int
        if (is_numeric($duration)) return (int)$duration;

        // try to parse patterns like '1 Hour 30 Minute' or '2 Hours' or '45 Minute'
        $hours = 0;
        $minutes = 0;
        // normalize
        $d = trim(strtolower((string)$duration));

        // match hours
        if (preg_match('/(\d+)\s*hour/', $d, $m)) {
            $hours = (int)$m[1];
        }
        // match minutes
        if (preg_match('/(\d+)\s*minute/', $d, $m2)) {
            $minutes = (int)$m2[1];
        }
        // if we matched something, return total minutes
        if ($hours > 0 || $minutes > 0) {
            return $hours * 60 + $minutes;
        }

        // fallback: try to extract any integer inside string
        if (preg_match('/(\d+)/', $d, $m3)) {
            return (int)$m3[1];
        }

        return null;
    }
    public function store(Request $request)
    {
        $data = $request->only(['title', 'duration', 'created_by', 'class_ids']);

        $validator = Validator::make($data, [
            'title' => 'required|string|max:255',
            'duration' => 'nullable|string|max:100',
            'created_by' => 'nullable|integer',
            'class_ids' => 'nullable|array',
            'class_ids.*' => 'integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        DB::beginTransaction();
        try {
            $quiz = Quiz::create([
                'title' => $data['title'],
                'duration' => $this->parseDuration($data['duration'] ?? null),
                'created_by' => $data['created_by'] ?? null,
            ]);

            // if class_ids provided, insert into quiz_classes
            if (!empty($data['class_ids']) && is_array($data['class_ids'])) {
                foreach ($data['class_ids'] as $cid) {
                    DB::table('quiz_classes')->insert([
                        'fk_id_quiz' => $quiz->id_quiz,
                        'fk_id_class' => $cid,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }

            DB::commit();
            return response()->json(['id' => $quiz->id_quiz, 'quiz' => $quiz], 201);
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json(['message' => 'Could not create quiz', 'error' => $e->getMessage()], 500);
        }
    }

    public function index(Request $request)
    {
        $classId = $request->query('class_id');

        if ($classId) {
            // join with quiz_classes to filter by class
            $quizzes = Quiz::select('quizzes.*')
                ->join('quiz_classes', 'quiz_classes.fk_id_quiz', '=', 'quizzes.id_quiz')
                ->where('quiz_classes.fk_id_class', $classId)
                ->distinct()
                ->get();
        } else {
            $quizzes = Quiz::all();
        }

        return response()->json(['data' => $quizzes], 200);
    }

    /**
     * Store full quiz payload including materials and questions
     * Expected payload keys: title, duration, created_by, class_ids (array), materials (array), questions (array)
     */
    public function storeFull(Request $request)
    {
    $data = $request->only(['quiz_id', 'title', 'duration', 'created_by', 'class_ids', 'materials', 'questions']);

        // Log incoming payload for debugging (development only)
        try {
            Log::info('QuizController@storeFull called', ['payload' => $data]);
        } catch (\Throwable $logEx) {
            // ignore logging errors
        }

        $validator = Validator::make($data, [
            'quiz_id' => 'nullable|integer',
            'title' => 'required|string|max:255',
            'duration' => 'nullable|string|max:100',
            'created_by' => 'nullable|integer',
            'class_ids' => 'nullable|array',
            'class_ids.*' => 'integer',
            'materials' => 'nullable|array',
            'questions' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        DB::beginTransaction();
        try {
            // Create or update quiz
            if (!empty($data['quiz_id'])) {
                $quiz = Quiz::find($data['quiz_id']);
                if (!$quiz) {
                    return response()->json(['message' => 'Quiz not found'], 404);
                }
                $quiz->title = $data['title'];
                $parsed = $this->parseDuration($data['duration'] ?? null);
                if ($parsed !== null) {
                    $quiz->duration = $parsed;
                }
                if (!empty($data['created_by'])) $quiz->created_by = $data['created_by'];
                $quiz->save();
            } else {
                $quiz = Quiz::create([
                    'title' => $data['title'],
                    'duration' => $this->parseDuration($data['duration'] ?? null),
                    'created_by' => $data['created_by'] ?? null,
                ]);
            }

            // link classes (only if table/column exist)
            if (!empty($data['class_ids']) && is_array($data['class_ids']) && Schema::hasTable('quiz_classes')) {
                $hasFkQuizCol = Schema::hasColumn('quiz_classes', 'fk_id_quiz');
                $hasFkClassCol = Schema::hasColumn('quiz_classes', 'fk_id_class');
                foreach ($data['class_ids'] as $cid) {
                    $row = [
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                    if ($hasFkQuizCol) $row['fk_id_quiz'] = $quiz->id_quiz;
                    if ($hasFkClassCol) $row['fk_id_class'] = $cid;
                    DB::table('quiz_classes')->insert($row);
                }
            }

            // create materials and collect mapping from client temporary id to created id
            $materialMap = [];
            if (!empty($data['materials']) && is_array($data['materials'])) {
                // only attempt to insert fk_id_quiz if the column exists
                $hasFkQuiz = Schema::hasColumn('material_quiz', 'fk_id_quiz');
                foreach ($data['materials'] as $m) {
                    // client may send temporary 'tmp_id' to reference in questions
                    $tmpId = $m['tmp_id'] ?? null;
                    $insert = [
                        'title' => $m['title'] ?? '',
                        'content' => $m['content'] ?? '',
                        'type' => $m['type'] ?? 'text',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                    if ($hasFkQuiz) {
                        $insert['fk_id_quiz'] = $quiz->id_quiz;
                    }
                    // if the table uses a non-default PK, we try to use 'id_material' else let insertGetId use default
                    $pk = Schema::hasColumn('material_quiz', 'id_material') ? 'id_material' : null;
                    $mat = $pk ? DB::table('material_quiz')->insertGetId($insert, $pk) : DB::table('material_quiz')->insertGetId($insert);
                    if ($tmpId !== null) $materialMap[$tmpId] = $mat;
                }
            }

            // create questions and choices
            if (!empty($data['questions']) && is_array($data['questions'])) {
                $questionsTableExists = Schema::hasTable('questions');
                $answerChoicesTableExists = Schema::hasTable('answer_choices');
                $questionAnswerChoicesTableExists = Schema::hasTable('question_answer_choices');
                $questionPk = Schema::hasColumn('questions', 'id_question') ? 'id_question' : null;
                $answerPk = Schema::hasColumn('answer_choices', 'id_answerchoice') ? 'id_answerchoice' : null;
                foreach ($data['questions'] as $q) {
                    $fkMat = null;
                    if (!empty($q['fk_id_material'])) {
                        // if client provided tmp id mapping
                        $fkMat = $materialMap[$q['fk_id_material']] ?? $q['fk_id_material'];
                    }
                    if (!$questionsTableExists) {
                        throw new \Exception('questions table does not exist');
                    }
                    $qInsert = [
                        'fk_id_quiz' => $quiz->id_quiz,
                        'number' => $q['number'] ?? 0,
                        'question_text' => $q['question_text'] ?? '',
                        'point' => $q['point'] ?? 0,
                        'fk_id_material' => $fkMat,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                    $question = $questionPk ? DB::table('questions')->insertGetId($qInsert, $questionPk) : DB::table('questions')->insertGetId($qInsert);

                    if (!empty($q['choices']) && is_array($q['choices'])) {
                        foreach ($q['choices'] as $choice) {
                            // create answer choice
                            if (!$answerChoicesTableExists) {
                                throw new \Exception('answer_choices table does not exist');
                            }
                            $choiceInsert = [
                                'content' => $choice['content'] ?? '',
                                'is_correct' => !empty($choice['is_correct']) ? 1 : 0,
                                'created_at' => now(),
                                'updated_at' => now(),
                            ];
                            $choiceId = $answerPk ? DB::table('answer_choices')->insertGetId($choiceInsert, $answerPk) : DB::table('answer_choices')->insertGetId($choiceInsert);
                            // link question_answer_choices
                            if (!$questionAnswerChoicesTableExists) {
                                throw new \Exception('question_answer_choices table does not exist');
                            }
                            DB::table('question_answer_choices')->insert([
                                'fk_id_question' => $question,
                                'fk_id_answerchoice' => $choiceId,
                                'is_correct' => !empty($choice['is_correct']) ? 1 : 0,
                                'created_at' => now(),
                                'updated_at' => now(),
                            ]);
                        }
                    }
                }
            }

            DB::commit();
            return response()->json(['id' => $quiz->id_quiz, 'quiz' => $quiz], 201);
        } catch (\Throwable $e) {
            DB::rollBack();
            // Log full exception for debugging
            try {
                Log::error('QuizController@storeFull failed: ' . $e->getMessage() . '\n' . $e->getTraceAsString());
            } catch (\Throwable $logEx) {
                // ignore logging errors
            }
            return response()->json(['message' => 'Could not create quiz', 'error' => $e->getMessage()], 500);
        }
    }

    // GET /api/quiz-questions?quiz_id=1
    public function questions(Request $request)
    {
        $quizId = $request->query('quiz_id');
        if (!$quizId) {
            return response()->json(['data' => []], 200);
        }

        // Attempt to read from questions, answer_choices and join via question_answer_choices
        try {
            $questions = DB::table('questions')
                ->where('fk_id_quiz', $quizId)
                ->orderBy('number')
                ->get();

            $data = [];
            foreach ($questions as $q) {
                $choices = [];
                if (Schema::hasTable('question_answer_choices')) {
                        $joins = DB::table('question_answer_choices')
                            ->where('fk_id_question', $q->id_question)
                            ->join('answer_choices', 'answer_choices.id_answerchoice', '=', 'question_answer_choices.fk_id_answerchoice')
                            ->select('answer_choices.id_answerchoice as id', 'answer_choices.content')
                            ->get();
                        foreach ($joins as $c) {
                            // NOTE: do NOT include is_correct here to prevent leaking answers to clients
                            $choices[] = ['id' => $c->id, 'content' => $c->content];
                        }
                }
                $data[] = [
                    'id_question' => $q->id_question ?? $q->id ?? null,
                    'number' => $q->number ?? 0,
                    'question_text' => $q->question_text ?? $q->question ?? '',
                    'point' => $q->point ?? $q->poin ?? 0,
                    'fk_id_material' => $q->fk_id_material ?? null,
                    'choices' => $choices,
                ];
            }

            return response()->json(['data' => $data], 200);
        } catch (\Throwable $e) {
            return response()->json(['data' => [], 'error' => $e->getMessage()], 500);
        }
    }

    // POST /api/result-quiz
    // Expected payload: { fk_id_quiz, fk_id_user, answers: { question_id: choice_id, ... }, started_at, finished_at }
    public function submitResult(Request $request)
    {
        $fkQuiz = $request->input('fk_id_quiz');
        $fkUser = $request->input('fk_id_user');
        $answers = $request->input('answers', []);
        $startedAt = $request->input('started_at');
        $finishedAt = $request->input('finished_at');

        try {
            $fkQuizInt = is_numeric($fkQuiz) ? (int)$fkQuiz : null;
            $fkUserInt = is_numeric($fkUser) ? (int)$fkUser : null;

            // Fetch correct answers and question points for the quiz from DB
            $questions = DB::table('questions')
                ->where('fk_id_quiz', $fkQuizInt)
                ->get()
                ->keyBy('id_question');

            // map question_id => correct_choice_id
            $correctMap = [];
            if (Schema::hasTable('question_answer_choices')) {
                $questionIds = array_map(function($v) { return (int)$v; }, array_keys((array)$questions->toArray()));
                if (count($questionIds) > 0) {
                    $corrects = DB::table('question_answer_choices')
                        ->where('question_answer_choices.is_correct', 1)
                        ->join('answer_choices', 'answer_choices.id_answerchoice', '=', 'question_answer_choices.fk_id_answerchoice')
                        ->select('question_answer_choices.fk_id_question as question_id', 'answer_choices.id_answerchoice as choice_id')
                        ->whereIn('question_answer_choices.fk_id_question', $questionIds)
                        ->get();
                    foreach ($corrects as $c) {
                        $correctMap[(string)$c->question_id] = (string)$c->choice_id;
                    }
                }
            }

            $totalPoints = 0;
            $earnedPoints = 0;
            $perQuestion = [];

            // Backwards compatibility: if client didn't send answers but provided a numeric 'score', accept it
            $legacyScore = $request->input('score', null);
            $hasAnswers = is_array($answers) && count($answers) > 0;

            foreach ($questions as $qid => $qrow) {
                $qIdStr = (string)$qrow->id_question;
                $point = isset($qrow->point) ? (int)$qrow->point : 0;
                $totalPoints += $point;
                if ($hasAnswers) {
                    $selected = isset($answers[$qIdStr]) ? (string)$answers[$qIdStr] : null;
                    $correctChoice = $correctMap[$qIdStr] ?? null;
                    $isCorrect = ($selected !== null && $correctChoice !== null && $selected === $correctChoice);
                    if ($isCorrect) $earnedPoints += $point;
                    $perQuestion[] = [
                        'question_id' => $qIdStr,
                        'selected_choice_id' => $selected,
                        'correct_choice_id' => $correctChoice,
                        'is_correct' => $isCorrect,
                        'point' => $point,
                    ];
                }
            }

            if ($hasAnswers) {
                $scorePercent = $totalPoints > 0 ? round(($earnedPoints / $totalPoints) * 100) : 0;
            } else {
                $scorePercent = is_numeric($legacyScore) ? (int)$legacyScore : 0;
            }

            // insert summary result
            $insert = [
                'fk_id_quiz' => $fkQuizInt ?? $fkQuiz,
                'fk_id_user' => $fkUserInt ?? $fkUser,
                'score' => $scorePercent,
                'status' => 'finished',
                'started_at' => $startedAt ?? null,
                'finished_at' => $finishedAt ?? null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            $id = DB::table('result_quiz')->insertGetId($insert, 'id_resultquiz');

            // Insert per-question results into result_question table for auditability
            if (Schema::hasTable('result_question') && is_array($perQuestion) && count($perQuestion) > 0) {
                foreach ($perQuestion as $pq) {
                    try {
                        DB::table('result_question')->insert([
                            'fk_id_resultquiz' => $id,
                            'fk_id_question' => isset($pq['question_id']) ? (int)$pq['question_id'] : null,
                            'selected_choice_id' => isset($pq['selected_choice_id']) && $pq['selected_choice_id'] !== null ? (int)$pq['selected_choice_id'] : null,
                            'correct_choice_id' => isset($pq['correct_choice_id']) && $pq['correct_choice_id'] !== null ? (int)$pq['correct_choice_id'] : null,
                            'is_correct' => !empty($pq['is_correct']) ? 1 : 0,
                            'point' => isset($pq['point']) ? (int)$pq['point'] : 0,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    } catch (\Throwable $_) {
                        // swallow per-question insert errors to avoid failing the whole request; log if possible
                        try { Log::warning('Could not insert result_question row: ' . json_encode($pq)); } catch (\Throwable $_) {}
                    }
                }
            }

            $resultPayload = [
                'id' => $id,
                'score' => $scorePercent,
                'total_points' => $totalPoints,
                'earned_points' => $earnedPoints,
                'per_question' => $perQuestion,
            ];

            return response()->json(['data' => $resultPayload], 201);
        } catch (\Throwable $e) {
            try { Log::error('submitResult failed: ' . $e->getMessage()); } catch (\Throwable $_) {}
            return response()->json(['message' => 'Could not save result', 'error' => $e->getMessage()], 500);
        }
    }

    // GET /api/result-quiz?user_id=...&quiz_id=...
    public function results(Request $request)
    {
        $userId = $request->query('user_id');
        $quizId = $request->query('quiz_id');
        $details = $request->query('details');

        try {
            $query = DB::table('result_quiz');
            if ($userId) $query->where('fk_id_user', $userId);
            if ($quizId) $query->where('fk_id_quiz', $quizId);
            $rows = $query->orderBy('created_at', 'desc')->get();

            // if details requested and we have a user+quiz filter, include per-question details for the most recent result
            if (!empty($details) && $userId && $quizId) {
                $first = $rows->first();
                if ($first) {
                    $resultId = $first->id_resultquiz ?? $first->id ?? null;
                    if ($resultId) {
                        $per = [];
                        if (Schema::hasTable('result_question')) {
                            $perRows = DB::table('result_question')
                                ->where('fk_id_resultquiz', $resultId)
                                ->get();
                            foreach ($perRows as $pr) {
                                // try to include choice content when available
                                $selectedContent = null;
                                $correctContent = null;
                                try {
                                    if (!empty($pr->selected_choice_id) && Schema::hasTable('answer_choices')) {
                                        $sel = DB::table('answer_choices')->where('id_answerchoice', $pr->selected_choice_id)->first();
                                        if ($sel) $selectedContent = $sel->content ?? null;
                                    }
                                } catch (\Throwable $_) {}
                                try {
                                    if (!empty($pr->correct_choice_id) && Schema::hasTable('answer_choices')) {
                                        $cor = DB::table('answer_choices')->where('id_answerchoice', $pr->correct_choice_id)->first();
                                        if ($cor) $correctContent = $cor->content ?? null;
                                    }
                                } catch (\Throwable $_) {}

                                $per[] = [
                                    'question_id' => $pr->fk_id_question,
                                    'selected_choice_id' => $pr->selected_choice_id,
                                    'selected_choice_content' => $selectedContent,
                                    'correct_choice_id' => $pr->correct_choice_id,
                                    'correct_choice_content' => $correctContent,
                                    'is_correct' => (bool)$pr->is_correct,
                                    'point' => $pr->point,
                                ];
                            }
                        }

                        return response()->json(['data' => ['summary' => $first, 'per_question' => $per]], 200);
                    }
                }
            }

            return response()->json(['data' => $rows], 200);
        } catch (\Throwable $e) {
            try { Log::error('results fetch failed: ' . $e->getMessage()); } catch (\Throwable $_) {}
            return response()->json(['data' => [], 'error' => $e->getMessage()], 500);
        }
    }
}
