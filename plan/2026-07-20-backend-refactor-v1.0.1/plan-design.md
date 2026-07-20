# Plan Design — Backend Refactor v1.0.1

## Latar Belakang

Backend SEA App (Laravel 11) dibuat 8 bulan lalu melalui AI-assisted coding (vibe coding) tanpa arsitektur yang dipikir matang di awal. Hasilnya: backend **bisa jalan** sebagai MVP tapi memiliki masalah arsitektural signifikan yang menghambat pengembangan lebih lanjut.

Berdasarkan analisa mendalam (lihat `backend/temp/ANALISA_BACKEND.md`), ditemukan **18 masalah utama** dengan skor kualitas **3.8/10**. Masalah paling kritis:

1. **Tidak ada Auth Middleware** — semua 35+ endpoint terbuka tanpa proteksi
2. **GeminiController = God Object** — 742 baris, 8+ tanggung jawab
3. **Tabel `question_answer_choices` overloaded** — pivot + jawaban siswa + benar/salah dalam 1 tabel
4. **18 dari 19 model tanpa relationship** — semua query harus manual
5. **`env()` dipanggil langsung di controller** — akan gagal jika config di-cache
6. **Response format tidak konsisten** — berbagai format di berbagai endpoint
7. **Duplicated code** — auth logic diulang di 4+ tempat, prompt AI di-paste di 4 lokasi

Saat ini UI Flutter sudah mendapat skor **8.5/10** setelah modernisasi besar. Backend harus menyusul agar seimbang.

## Tujuan

1. Meningkatkan **keamanan** backend dengan auth middleware yang proper
2. Memecah **God Object** (GeminiController) menjadi controller yang fokus
3. Membersihkan **skema database** — pisahkan tabel overloaded, tambah constraint
4. Menambahkan **relationship di semua model** agar query lebih bersih
5. Membuat **service layer** untuk AI calls dan prompt management
6. Menyeragamkan **response format** menggunakan API Resource
7. Menambahkan **pagination** di index endpoints
8. Menaikkan versi backend ke **v1.0.1**

## Scope

### Dikerjakan
- ✅ Auth Middleware (`EnsureApiToken`)
- ✅ Refactor GeminiController → 3-4 controller
- ✅ Buat `GeminiApiService` + `AiPromptService`
- ✅ Pindah `env()` ke `config()` untuk API key
- ✅ Tambah relationship di semua model
- ✅ Tambah `ResultQuestion` model (sudah ada migration)
- ✅ Refactor `question_answer_choices` → pisahkan tabel
- ✅ Tambah UNIQUE constraint di pivot tables
- ✅ Konsistensikan response format (API Resource)
- ✅ Tambah pagination di index endpoints
- ✅ Fix code_class generation
- ✅ Hapus silent error swallowing → proper logging
- ✅ Update version ke 1.0.1
- ✅ Buat `routes/api.php` (pisahkan dari `web.php`)

### Tidak dikerjakan
- ❌ Perubahan Flutter client (backend only)
- ❌ API versioning (`/api/v1/`) — next version
- ❌ Rate limiting — next version
- ❌ Soft deletes — next version
- ❌ Merge DiscussionRoom + ChatRoomAI — butuh diskusi desain lebih lanjut
- ❌ Penghapusan quiz_students table — biarkan dulu
- ❌ Testing (PHPUnit) — next version
- ❌ API Documentation (Swagger/OpenAPI) — next version

## Breakdown Task

| # | Task | File Utama | Estimasi |
|---|---|---|---|
| 1 | Auth Middleware & Route Protection | `Middleware/`, `routes/api.php` | 2-3 jam |
| 2 | Service Layer — GeminiApiService & AiPromptService | `Services/` | 2-3 jam |
| 3 | Refactor GeminiController → 3 Controller | `Controllers/` | 3-4 jam |
| 4 | Model Relationships & ResultQuestion Model | `Models/` | 2-3 jam |
| 5 | Database Schema Cleanup — Pisahkan Tabel Overloaded | `migrations/`, `Models/` | 3-4 jam |
| 6 | API Resource & Response Standardization | `Http/Resources/` | 2-3 jam |
| 7 | Pagination, Code Fix & Logging | `Controllers/` | 2-3 jam |
| 8 | Config API Key, Cleanup & Version Bump | `config/`, `composer.json` | 1-2 jam |

Total estimasi: **17-24 jam** (3-4 hari kerja)

## Design Teknis

### 1. Auth Middleware

Buat `app/Http/Middleware/EnsureApiToken.php`:
- Cek header `Authorization: Bearer <token>`
- Lookup `api_tokens` table
- Attach user ke `$request->user()`
- Return 401 jika invalid

Register di `bootstrap/app.php`:
```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'auth.token' => \App\Http\Middleware\EnsureApiToken::class,
    ]);
})
```

Apply ke route group:
```php
Route::middleware('auth.token')->group(function () {
    // semua endpoint yang butuh auth
});
```

### 2. Service Layer

**`app/Services/GeminiApiService.php`:**
- Method `generateContent(string $prompt): string`
- Handle HTTP call ke Gemini API
- Handle error response
- Gunakan `config('services.gemini.key')` bukan `env()`

**`app/Services/AiPromptService.php`:**
- Method `evaluateUnderstanding(array $materials, string $summary): string`
- Method `generateQuestions(array $materials): string`
- Method `generateGroups(array $students, int $groupCount, ?string $quizResults): string`
- Prompt hanya ditulis **1 kali** di sini

### 3. Controller Refactor

**GeminiController → 3 controller:**

| Controller Baru | Tanggung Jawab | Methods |
|---|---|---|
| `AiProxyController` | Proxy AI general + generate | `askGemini`, `generateQuestions`, `generateGroups` |
| `ChatController` | Chat + messages | `chatStudent`, `getDiscussionMessages`, `deleteAllMessages` |
| `DiscussionUtilityController` | Summary + understanding | `submitSummary`, `getSummaries`, `checkUnderstanding` |

`GeminiController` lama dihapus.

### 4. Model Relationships

Tambahkan relationship di **semua 19 model** yang belum punya. Contoh:
```php
// User
public function tokens()     { return $this->hasMany(ApiToken::class, 'user_id'); }
public function classes()    { return $this->belongsToMany(SchoolClass::class, 'user_classes', 'fk_id_user', 'fk_id_class'); }
public function results()    { return $this->hasMany(ResultQuiz::class, 'fk_id_user'); }

// Quiz
public function questions()  { return $this->hasMany(Question::class, 'fk_id_quiz'); }
public function classes()    { return $this->belongsToMany(SchoolClass::class, 'quiz_classes', 'fk_id_quiz', 'fk_id_class'); }
```

### 5. Database Schema Cleanup

**Pisahkan `question_answer_choices` menjadi 2 tabel:**

Tabel `question_answer_choices` (pivot murni):
```
id, fk_id_question, fk_id_answerchoice, created_at, updated_at
```
(Hapus `is_correct` dan `fk_id_resultquiz`)

Tabel `student_answers` (jawaban siswa):
```
id, fk_id_resultquiz, fk_id_question, fk_id_answerchoice, is_correct, point, created_at, updated_at
```

**Migration:** Buat migration baru yang:
1. Buat tabel `student_answers`
2. Copy data dari `question_answer_choices` WHERE `fk_id_resultquiz IS NOT NULL` ke `student_answers`
3. Hapus kolom `is_correct` dan `fk_id_resultquiz` dari `question_answer_choices`

**UNIQUE constraints** di migration terpisah:
- `user_classes`: UNIQUE(`fk_id_user`, `fk_id_class`)
- `quiz_classes`: UNIQUE(`fk_id_quiz`, `fk_id_class`)
- `discussion_students`: UNIQUE(`fk_id_chatroomai`, `fk_id_user`)

### 6. API Resource

Buat `app/Http/Resources/`:
- `UserResource` — format user profile
- `ClassResource` — format kelas
- `QuizResource` — format kuis
- `QuestionResource` — format soal (tanpa is_correct!)
- `DiscussionResource` — format diskusi
- `MaterialResource` — format materi
- `ResultQuizResource` — format hasil kuis
- `MessageResource` — format pesan

Semua response menggunakan resource:
```php
return QuestionResource::collection($questions);
// Output: {"data": [{"id": 1, "number": 1, "question_text": "...", "choices": [...]}]}
```

### 7. Pagination

Gunakan Laravel's built-in pagination:
```php
$quizzes = Quiz::paginate(20); // default 20 per page
return QuizResource::collection($quizzes);
// Output: {"data": [...], "links": {...}, "meta": {...}}
```

### 8. Config API Key

Buat `config/services.php` tambahan:
```php
'gemini' => [
    'key' => env('GEMINI_API_KEY'),
    'url' => env('GEMINI_API_URL', 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
],
```

Ganti semua `env('GEMINI_API_KEY')` di controllers → `config('services.gemini.key')`.

### 9. Route Structure

Pindahkan SEMUA route dari `web.php` ke `api.php`:

```
routes/api.php

// Public routes (tanpa auth)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/echo', [AiProxyController::class, 'echo']);

// Protected routes (dengan auth.token middleware)
Route::middleware('auth.token')->group(function () {
    // Auth
    Route::get('/user', [AuthController::class, 'user']);

    // Classes
    Route::get('/classes', [ClassController::class, 'index']);
    Route::post('/classes', [ClassController::class, 'store']);
    // ... dst

    // Quiz
    Route::get('/quizzes', [QuizController::class, 'index']);
    // ... dst
});
```

## File yang Terdampak

### Dibuat Baru
```
backend/app/
├── Http/
│   ├── Middleware/EnsureApiToken.php
│   ├── Controllers/AiProxyController.php
│   ├── Controllers/ChatController.php
│   ├── Controllers/DiscussionUtilityController.php
│   └── Resources/
│       ├── UserResource.php
│       ├── ClassResource.php
│       ├── QuizResource.php
│       ├── QuestionResource.php
│       ├── DiscussionResource.php
│       ├── MaterialResource.php
│       ├── ResultQuizResource.php
│       └── MessageResource.php
├── Services/
│   ├── GeminiApiService.php
│   └── AiPromptService.php
└── Models/ResultQuestion.php (sudah ada migration)

backend/database/migrations/
├── xxxx_create_student_answers_table.php
├── xxxx_cleanup_question_answer_choices_table.php
└── xxxx_add_unique_constraints_table.php

backend/routes/api.php (baru)
```

### Diedit
```
backend/app/Http/Controllers/AuthController.php
backend/app/Http/Controllers/ClassController.php
backend/app/Http/Controllers/QuizController.php
backend/app/Http/Controllers/MaterialController.php
backend/app/Http/Controllers/DiscussionController.php
backend/app/Http/Controllers/DiscussionStudentController.php
backend/app/Http/Controllers/DiscussionDataController.php
backend/app/Models/User.php (+relationships)
backend/app/Models/SchoolClass.php (+relationships)
backend/app/Models/Quiz.php (+relationships)
backend/app/Models/Question.php (+relationships)
backend/app/Models/AnswerChoice.php (+relationships)
backend/app/Models/QuestionAnswerChoice.php (hapus overloaded fields)
backend/app/Models/MaterialQuiz.php (+relationships)
backend/app/Models/ResultQuiz.php (+relationships)
backend/app/Models/DiscussionRoom.php (+relationships)
backend/app/Models/ChatRoomAI.php (+relationships)
backend/app/Models/DiscussionMessage.php (+relationships)
backend/app/Models/AIMessage.php (+relationships)
backend/app/Models/DiscussionStudent.php (sudah ada)
backend/app/Models/DiscussionGroup.php (+relationships)
backend/app/Models/DiscussionQuestion.php (+relationships)
backend/app/Models/SummaryDiscussion.php (+relationships)
backend/app/Models/ResultUnderstanding.php (+relationships)
backend/app/Models/UserClass.php (+relationships)
backend/app/Models/ApiToken.php (+relationships)
backend/app/Models/QuizClass.php (+relationships)
backend/bootstrap/app.php (register middleware)
backend/config/services.php (tambah gemini config)
backend/routes/web.php (kosongkan, pindah ke api.php)
```

### Dihapus
```
backend/app/Http/Controllers/GeminiController.php (diganti 3 controller baru)
```

## Urutan Eksekusi (Dependency Chain)

```
Task 1: Auth Middleware ─────────────┐
Task 2: Service Layer ──────────────┤
Task 3: Controller Refactor ────────┤── Task 6: API Resource
Task 4: Model Relationships ────────┤
Task 5: DB Schema Cleanup ──────────┘
                                     │
Task 7: Pagination & Fix ────────────┤
Task 8: Config & Version ───────────┘
```

**Catatan:**
- Task 1-5 bisa dikerjakan **paralel** (tidak saling bergantung)
- Task 6 (API Resource) bergantung pada Task 3 (controller sudah dipisah)
- Task 7 bergantung pada Task 5 (schema sudah bersih)
- Task 8 dikerjakan **terakhir** (cleanup & version bump)

## Dampak ke Sistem

- **Breaking change di API response format** — Flutter client perlu update model parsing
- **Endpoint pindah dari `/api/...` (web.php) ke `/api/...` (api.php)** — seharusnya transparent karena prefix sama
- **Auth diperlukan di semua endpoint** — kecuali register, login, echo
- **`question_answer_choices` berubah schema** — data lama perlu di-migrate
- **Semua controller berubah** — karena pakai service layer & resource

## Definition of Done

- [ ] Auth middleware berfungsi — endpoint tanpa token return 401
- [ ] GeminiController dihapus, diganti 3 controller baru
- [ ] `GeminiApiService` dan `AiPromptService` berfungsi
- [ ] Semua 19 model punya relationship definition
- [ ] `ResultQuestion` model ada dan berfungsi
- [ ] Tabel `student_answers` terpisah dari `question_answer_choices`
- [ ] UNIQUE constraint aktif di pivot tables
- [ ] Semua response menggunakan API Resource
- [ ] Pagination aktif di semua index endpoint
- [ ] `config('services.gemini.key')` digunakan bukan `env()`
- [ ] Route di `api.php`, `web.php` kosong (hanya welcome view)
- [ ] `composer lint` (pint) bersih
- [ ] Semua endpoint berfungsi seperti sebelumnya (regression check)
- [ ] Version di `composer.json` = `1.0.1`
