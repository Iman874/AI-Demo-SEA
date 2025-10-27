<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GeminiController;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;

Route::get('/', function () {
    return view('welcome');
});

Route::post('/api/ask', [GeminiController::class, 'askGemini'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/echo', [GeminiController::class, 'echoRequest'])->withoutMiddleware([VerifyCsrfToken::class]);

// AUTH
use App\Http\Controllers\AuthController;
Route::post('/api/register', [AuthController::class, 'register'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/login', [AuthController::class, 'login'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/user', [AuthController::class, 'user'])->withoutMiddleware([VerifyCsrfToken::class]);

// QUIZ API
use App\Http\Controllers\QuizController;
Route::post('/api/quizzes', [QuizController::class, 'store'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/quizzes', [QuizController::class, 'index'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/quizzes/save', [QuizController::class, 'storeFull'])->withoutMiddleware([VerifyCsrfToken::class]);
// Quiz questions and results
Route::get('/api/quiz-questions', [QuizController::class, 'questions'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/result-quiz', [QuizController::class, 'submitResult'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/result-quiz', [QuizController::class, 'results'])->withoutMiddleware([VerifyCsrfToken::class]);

// Generate questions (AI)
Route::post('/api/generate-questions', [GeminiController::class, 'generateQuestions'])->withoutMiddleware([VerifyCsrfToken::class]);
// Generate groups (AI)
Route::post('/api/generate-groups', [GeminiController::class, 'generateGroups'])->withoutMiddleware([VerifyCsrfToken::class]);

// CLASSES
use App\Http\Controllers\ClassController;
Route::get('/api/classes', [ClassController::class, 'index'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/classes', [ClassController::class, 'store'])->withoutMiddleware([VerifyCsrfToken::class]);

// USER <-> CLASS
use App\Http\Controllers\UserClassController;
Route::post('/api/join-class', [UserClassController::class, 'join'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/my-classes', [UserClassController::class, 'myClasses'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/user-class-ids', [UserClassController::class, 'userClassIds'])->withoutMiddleware([VerifyCsrfToken::class]);

// DISCUSSIONS
use App\Http\Controllers\DiscussionController;
Route::get('/api/discussions', [DiscussionController::class, 'index'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/discussions', [DiscussionController::class, 'store'])->withoutMiddleware([VerifyCsrfToken::class]);
// update an existing discussion (teacher edit)
Route::put('/api/discussions/{id}', [DiscussionController::class, 'update'])->withoutMiddleware([VerifyCsrfToken::class]);
// fetch a single discussion
Route::get('/api/discussions/{id}', [DiscussionController::class, 'show'])->withoutMiddleware([VerifyCsrfToken::class]);

// Discussion members (users linked to chat_room_ai via discussion_students)
use App\Http\Controllers\DiscussionStudentController;
Route::get('/api/discussion-members', [DiscussionStudentController::class, 'members'])->withoutMiddleware([VerifyCsrfToken::class]);
// get class members by class id
Route::get('/api/class-members', [UserClassController::class, 'classMembers'])->withoutMiddleware([VerifyCsrfToken::class]);

// MATERIALS
use App\Http\Controllers\MaterialController;
Route::get('/api/materials', [MaterialController::class, 'index'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/materials', [MaterialController::class, 'store'])->withoutMiddleware([VerifyCsrfToken::class]);


// ROUTES STUDENT
Route::post('/api/student/chat', [GeminiController::class, 'chatStudent'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/student/check_understanding', [GeminiController::class, 'check_understanding'])->withoutMiddleware([VerifyCsrfToken::class]);

// Discussion utilities
Route::post('/api/discussion/delete_all_messages', [GeminiController::class, 'deleteAllDiscussionMessages'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::post('/api/discussion/submit_summary', [GeminiController::class, 'submitDiscussionSummary'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/discussion/messages', [GeminiController::class, 'getDiscussionMessages'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/discussion/summaries', [GeminiController::class, 'getDiscussionSummaries'])->withoutMiddleware([VerifyCsrfToken::class]);

use App\Http\Controllers\DiscussionDataController;
Route::get('/api/discussion-questions', [DiscussionDataController::class, 'questions'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/discussion-summaries', [DiscussionDataController::class, 'summaries'])->withoutMiddleware([VerifyCsrfToken::class]);
Route::get('/api/discussion-understandings', [DiscussionDataController::class, 'understandings'])->withoutMiddleware([VerifyCsrfToken::class]);