# Analisa Backend — SEA App (Smart Education Assistant)

**Tanggal Analisa:** 20 Juli 2026
**Versi Backend:** Laravel 11 (PHP 8.2+)
**Status:** MVP — Banyak area perlu perbaikan

---

## 1. Nilai UI Flutter (Sekilas)

Berdasarkan `.memori.txt` dan struktur file Flutter, UI sudah melalui **modernisasi besar-besaran**:
- Bottom navigation concave notch premium
- Skeleton loading shimmer, staggered animations
- Card components modern (9 kartu showcase)
- Dark/light theme konsisten
- Phosphor Icons, design tokens terstruktur
- Developer mode dengan showcase

**Penilaian UI: 8.5/10** — Sangat baik untuk MVP. Tingkat polish tinggi, animasi smooth, konsisten.

---

## 2. Analisa Backend — Masalah Utama

### 2.1 ★ KRITIS: Tabel `question_answer_choices` Overloaded

**Lokasi:** `migrations/2025_10_19_000008`, `QuizController.php`

Tabel ini memiliki **3 fungsi sekaligus**:
1. **Pivot table** — menghubungkan `questions` ↔ `answer_choices` (fk_id_resultquiz = NULL)
2. **Jawaban siswa** — mencatat jawaban siswa per quiz attempt (fk_id_resultquiz != NULL)
3. **Penanda benar/salah** — `is_correct` yang **duplikat** dari `answer_choices.is_correct`

**Dampak:**
- Query membingungkan — harus filter `whereNull('fk_id_resultquiz')` untuk dapat soal asli
- `answer_choices.is_correct` dan `question_answer_choices.is_correct` bisa tidak sinkron
- Tabel `result_question` (migration Oct 21) dibuat karena tabel ini tidak cukup, tapi malah menambah kompleksitas
- Seeder menghapus semua jawaban lama (`where('fk_id_resultquiz', ...)`) sebelum menulis ulang — operasi berisiko

**Solusi yang Disarankan:**
- Pisahkan menjadi 3 tabel: `question_answer_choices` (pivot murni), `student_answers` (jawaban siswa)
- Hapus `is_correct` dari `answer_choices` (hanya ada di pivot)
- atau Gunakan `result_question` sebagai satu-satunya tabel jawaban siswa

---

### 2.2 ★ KRITIS: GemminiController = God Object

**Lokasi:** `GeminiController.php` (742 baris)

Controller ini menangani **8+ tanggung jawab**:
1. `askGemini()` — Proxy AI general
2. `echoRequest()` — Health check
3. `chatStudent()` — Chat siswa + persist message
4. `check_understanding()` — Evaluasi pemahaman AI
5. `generateQuestions()` — Generate soal AI
6. `generateGroups()` — Generate kelompok AI
7. `deleteAllDiscussionMessages()` — Hapus semua pesan
8. `getDiscussionMessages()` — Ambil pesan gabungan
9. `getDiscussionSummaries()` — Ambil ringkasan + auto-compute understanding
10. `submitDiscussionSummary()` — Submit ringkasan + evaluasi AI

**Dampak:**
- Sulit di-maintain dan di-test
- Logika AI (prompt) bercampur dengan logika CRUD
- Duplicated code: prompt understanding evaluation **di-copy-paste** di 3+ tempat (`check_understanding`, `getDiscussionSummaries`, `submitDiscussionSummary`)
- Error handling tidak konsisten

**Solusi yang Disarankan:**
- Pisahkan: `AiProxyController`, `ChatController`, `DiscussionSummaryController`, `GroupController`
- Buat `AiPromptService` untuk mengelola semua prompt
- Buat `GeminiApiService` untuk HTTP call ke Gemini

---

### 2.3 ★ KRITIS: Tidak Ada Auth Middleware

**Lokasi:** `routes/web.php`

**Semua 35+ endpoint** menggunakan `withoutMiddleware([VerifyCsrfToken::class])` tapi **TIDAK ADA** middleware autentikasi.

Autentikasi dilakukan **manual** di setiap controller method:
```php
// Ini diulang di 5+ tempat berbeda:
$header = $request->header('Authorization');
if (!$header || !str_starts_with($header, 'Bearer ')) {
    return response()->json(['message' => 'Unauthenticated'], 401);
}
$token = substr($header, 7);
$record = ApiToken::where('token', $token)->first();
```

**Dampak:**
- Endpoint publik seperti `/api/quizzes`, `/api/classes`, `/api/discussions` bisa diakses tanpa login
- Code duplikasi di AuthController, UserClassController (3 methods)
- Tidak bisa menambahkan rate limiting per-user

**Solusi yang Disarankan:**
- Buat `EnsureApiToken` middleware
- Apply ke semua route yang butuh auth
- Buat `auth:sanctum` atau custom middleware group

---

### 2.4 ★ KRITIS: Raw DB Queries Tanpa Model

**Lokasi:** `QuizController.php`, `GeminiController.php`, `DiscussionController.php`

Banyak kode menggunakan `DB::table()` langsung alih-alih Eloquent:
```php
// QuizController.php:78
DB::table('quiz_classes')->insert([...]);

// QuizController.php:286
$questions = DB::table('questions')->where('fk_id_quiz', $quizId)->get();

// GeminiController.php:282
$rows = DB::table('user_classes')->where('fk_id_class', $classId)->get();
```

**Dampak:**
- Tidak bisa pakai relationship Eloquent
- Schema check (`Schema::hasTable`, `Schema::hasColumn`) harus dilakukan manual di mana-mana
- Kode lebih panjang dan sulit dibaca
- Tidak ada type safety

---

### 2.5 Model Tanpa Relationship

Dari 19 model, **hanya 1** yang punya relationship definition:

| Model | Relationship | Status |
|---|---|---|
| DiscussionStudent | `user()`, `chatRoomAI()` | Ada |
| User | — | **TIDAK ADA** |
| SchoolClass | — | **TIDAK ADA** |
| Quiz | — | **TIDAK ADA** |
| Question | — | **TIDAK ADA** |
| ResultQuiz | — | **TIDAK ADA** |
| ChatRoomAI | — | **TIDAK ADA** |
| DiscussionRoom | — | **TIDAK ADA** |
| MaterialQuiz | — | **TIDAK ADA** |
| ... | ... | **SEMUA TIDAK ADA** |

**Dampak:**
- Tidak bisa pakai `$quiz->questions`, `$class->users()`, dll
- Semua query harus manual join atau multiple query
- Kode jadi verbose dan tidak expressif

---

### 2.6 Hardcoded API Key via `env()` Langsung

**Lokasi:** `GeminiController.php` (8+ tempat)

```php
'X-goog-api-key' => env('GEMINI_API_KEY'),
```

**Masalah:**
- `env()` hanya bisa dipanggil saat config cache belum di-build
- Jika `php artisan config:cache` dijalankan, semua `env()` di controller akan return `null`
- Seharusnya pakai `config('services.gemini.key')` atau `config('app.gemini_key')`

---

### 2.7 Silent Error Swallowing

**Lokasi:** Seluruh kode, terutama `GeminiController.php`, `DiscussionController.php`

```php
try {
    // ... logic penting ...
} catch (\Throwable $_) {
    // ignore — tanpa logging
}
```

**Dampak:**
- Error hilang tanpa jejak
- Sulit debugging di production
- Data bisa corrupt tanpa diketahui

**Contoh kasus:**
- `DiscussionController::store()` — gagal create DiscussionStudent diabaikan
- `GeminiController::chatStudent()` — gagal persist message diabaikan
- `QuizController::submitResult()` — gagal insert result_question diabaikan

---

### 2.8 Duplicated Auth Logic

Pola autentikasi manual **diulang** di minimal 4 tempat:

| Lokasi | Method |
|---|---|
| `AuthController::user()` | Manual token check |
| `UserClassController::join()` | Manual token + fallback user_id |
| `UserClassController::myClasses()` | Manual token + fallback user_id |
| `UserClassController::userClassIds()` | Manual token + fallback user_id |

**Solusi:** Buat middleware atau private method `authenticateUser(Request $request)`.

---

### 2.9 Tidak Ada API Versioning

Semua endpoint di `/api/` tanpa versi (`/api/v1/`, `/api/v2/`).

**Dampak:**
- Breaking changes akan mempengaruhi semua client
- Tidak bisa melakukan migration perlahan

---

### 2.10 Tidak Ada Pagination

Endpoint `/api/classes`, `/api/quizzes`, `/api/discussions` mengembalikan **SEMUA data** tanpa pagination.

**Dampak:**
- Performance degradation saat data besar
- Memory usage tinggi di client

---

### 2.11 Response Format Tidak Konsisten

| Endpoint | Format Response |
|---|---|
| `/api/classes` | `{"data": [...]}` |
| `/api/quizzes` | `{"data": [...]}` |
| `/api/ask` | `{"answer": "..."}` |
| `/api/result-quiz` (GET) | `{"data": [...]}` |
| `/api/result-quiz` (POST) | `{"data": {"id": ..., "score": ...}}` |
| `/api/discussions` | `{"data": [...]}` (camelCase fields) |
| `/api/user` | `{"user": {...}}` |
| `/api/login` | `{"token": "...", "user": {...}}` |
| Error | `{"message": "..."}` atau `{"errors": {...}}` atau `{"error": "..."}` |

---

### 2.12 Code Class Generation Bug

**Lokasi:** `ClassController.php:26`

```php
$code = 'CLS' . str_pad((string) (SchoolClass::max('id_class') + 1), 3, '0', STR_PAD_LEFT);
```

**Masalah:**
- Jika ada gap ID (misal ID 5 di-delete, lalu ID 6 ada), max(id) + 1 bisa generate kode yang sudah dipakai
- Tidak ada pengecekan uniqueness setelah generate
- Race condition: 2 request bersamaan bisa dapat kode sama

---

### 2.13 Prompt AI Di-Paste Berulang

Prompt evaluasi pemahaman **di-copy-paste identik** di 3+ lokasi:

1. `GeminiController::check_understanding()` baris 178
2. `GeminiController::getDiscussionSummaries()` baris 591
3. `GeminiController::submitDiscussionSummary()` baris 689
4. `DiscussionDataController::summaries()` baris 61

**Dampak:**
- Jika prompt perlu diubah, harus ubah di 4+ tempat
- Risk of divergence (salah satu lupa diupdate)

---

### 2.14 DiscussionRoom & ChatRoomAI Overlap

`DiscussionRoom` dan `ChatRoomAI` memiliki kolom yang sangat mirip:
- Keduanya punya `title`, `description`, `status`, `created_by`, `fk_id_class`
- `ChatRoomAI.fk_id_discussionroom` menghubungkan ke `DiscussionRoom`
- Saat create DiscussionRoom, otomatis buat ChatRoomAI

**Pertanyaan desain:** Apakah perlu 2 tabel terpisah? Bisa disederhanakan menjadi 1 tabel dengan flag `has_ai_chat`.

---

### 2.15 Tidak Ada Soft Delete

Tidak ada model yang menggunakan `SoftDeletes`. Data yang dihapus hilang permanen.

---

### 2.16 Tidak Ada Rate Limiting

AI endpoints (`/api/ask`, `/api/student/chat`, `/api/generate-questions`, `/api/generate-groups`) tidak memiliki rate limiting.

**Dampak:**
- Bisa disalahgunakan untuk spam AI calls
- Biaya Gemini API bisa membengkak

---

### 2.17 Quiz Students Table Tidak Digunakan

Tabel `quiz_students` di-seed di `DatabaseSeeder` tapi **tidak ada controller** yang menggunakannya.

---

### 2.18 Migration Defensiveness Berlebihan

Setiap migration diawali `if (!Schema::hasTable(...))`. Setiap controller diawali `Schema::hasTable()` / `Schema::hasColumn()`.

Ini menunjukkan **ketidakpercayaan** terhadap state database, yang seharusnya dijamin oleh migration yang berjalan benar.

---

## 3. Rencana Perbaikan (Prioritas)

### Prioritas 1 — KRITIS (Minggu 1-2)
| # | Item | Estimasi |
|---|---|---|
| 1 | Buat Auth Middleware (`EnsureApiToken`) | 1 hari |
| 2 | Refactor `GeminiController` → 3-4 controller | 2 hari |
| 3 | Buat `GeminiApiService` + `AiPromptService` | 1 hari |
| 4 | Pindah `env()` ke `config()` untuk API key | 0.5 hari |
| 5 | Buat relationship di semua model | 1 hari |

### Prioritas 2 — PENTING (Minggu 3-4)
| # | Item | Estimasi |
|---|---|---|
| 6 | Refactor `question_answer_choices` → pisahkan tabel | 2 hari |
| 7 | Tambah UNIQUE constraint di pivot tables | 0.5 hari |
| 8 | Konsistensikan response format (API Resource) | 1 hari |
| 9 | Tambah pagination di index endpoints | 1 hari |
| 10 | Fix code_class generation (pakai Str::random atau UUID) | 0.5 hari |

### Prioritas 3 — MENENGAH (Minggu 5-6)
| # | Item | Estimasi |
|---|---|---|
| 11 | Tambah API versioning (`/api/v1/`) | 1 hari |
| 12 | Tambah rate limiting | 0.5 hari |
| 13 | Tambah SoftDeletes di model penting | 0.5 hari |
| 14 | Hapus `quiz_students` table atau gunakan | 0.5 hari |
| 15 | Evaluasi合并 DiscussionRoom + ChatRoomAI | 1 hari |
| 16 | Ganti silent catch dengan proper logging | 1 hari |

---

## 4. Skor Kualitas Backend

| Aspek | Skor (1-10) | Catatan |
|---|---|---|
| **Keamanan** | 3/10 | Tidak ada middleware auth, token tidak expire |
| **Arsitektur** | 4/10 | God object, raw queries, no service layer |
| **Skema Database** | 4/10 | Overloaded tables, redundant columns, missing constraints |
| **Code Quality** | 5/10 | Duplicated code, mixed patterns, silent errors |
| **Maintainability** | 4/10 | Sulit tambah fitur baru tanpa break yang lain |
| **Performance** | 6/10 | Tidak ada N+1 (karena tidak pakai relationship), tapi juga tidak ada optimasi |
| **Testing** | 2/10 | Hanya ExampleTest bawaan Laravel |
| **Documentation** | 3/10 | Tidak ada API docs, tidak ada OpenAPI/Swagger |
| **Error Handling** | 3/10 | Silent catch di mana-mana |
| **Konsistensi** | 4/10 | Mixed patterns, naming tidak konsisten |

**Skor Rata-rata: 3.8/10**

---

## 5. Kesimpulan

Backend SEA App berfungsi sebagai MVP tapi memiliki **masalah arsitektural signifikan** yang akan menghambat pengembangan lebih lanjut:

1. **Keamanan lemah** — tanpa auth middleware, semua endpoint terbuka
2. **Code organization buruk** — GeminiController sebagai god object
3. **Skema database ambigu** — terutama `question_answer_choices` yang overloaded
4. **Tidak scalable** — tanpa pagination, rate limiting, atau caching
5. **Sulit di-maintain** — duplicated code, silent errors, tanpa tests

**Rekomendasi:** Lakukan refactoring bertahap sesuai prioritas di atas. Mulai dari auth middleware dan pemecahan GeminiController, karena ini paling berdampak terhadap keamanan dan maintainability.
