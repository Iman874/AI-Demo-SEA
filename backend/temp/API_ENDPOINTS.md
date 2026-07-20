# Daftar API Endpoints — SEA App

**Base URL:** `http://localhost:8000/api`
**Autentikasi:** Bearer token di header `Authorization` (manual, tanpa middleware)

---

## Auth

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| POST | `/api/register` | ❌ | `AuthController@register` | Registrasi user baru |
| POST | `/api/login` | ❌ | `AuthController@login` | Login, return token |
| GET | `/api/user` | ✅ manual | `AuthController@user` | Dapatkan data user dari token |

---

## Kelas

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| GET | `/api/classes` | ❌ | `ClassController@index` | Daftar semua kelas |
| POST | `/api/classes` | ❌ | `ClassController@store` | Buat kelas baru |
| POST | `/api/join-class` | ✅ manual | `UserClassController@join` | Siswa gabung kelas via kode |
| GET | `/api/my-classes` | ✅ manual | `UserClassController@myClasses` | Kelas yang diikuti user |
| GET | `/api/user-class-ids` | ✅ manual | `UserClassController@userClassIds` | ID kelas yang diikuti |
| GET | `/api/class-members` | ❌ | `UserClassController@classMembers` | Anggota kelas |

---

## Quiz

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| GET | `/api/quizzes` | ❌ | `QuizController@index` | Daftar kuis (filter: ?class_id) |
| POST | `/api/quizzes` | ❌ | `QuizController@store` | Buat kuis baru |
| POST | `/api/quizzes/save` | ❌ | `QuizController@storeFull` | Simpan kuis lengkap (soal + materi) |
| GET | `/api/quiz-questions` | ❌ | `QuizController@questions` | Soal kuis (filter: ?quiz_id) |
| POST | `/api/result-quiz` | ❌ | `QuizController@submitResult` | Submit jawaban kuis |
| GET | `/api/result-quiz` | ❌ | `QuizController@results` | Hasil kuis (filter: ?user_id, ?quiz_id) |

---

## Materi

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| GET | `/api/materials` | ❌ | `MaterialController@index` | Daftar materi (?quiz_id, ?discussion_id) |
| POST | `/api/materials` | ❌ | `MaterialController@store` | Tambah materi baru |

---

## Diskusi

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| GET | `/api/discussions` | ❌ | `DiscussionController@index` | Daftar ruang diskusi (?class_id) |
| POST | `/api/discussions` | ❌ | `DiscussionController@store` | Buat ruang diskusi + chatroom |
| PUT | `/api/discussions/{id}` | ❌ | `DiscussionController@update` | Update ruang diskusi |
| GET | `/api/discussions/{id}` | ❌ | `DiscussionController@show` | Detail ruang diskusi |
| GET | `/api/discussion-members` | ❌ | `DiscussionStudentController@members` | Anggota diskusi |
| GET | `/api/discussion-questions` | ❌ | `DiscussionDataController@questions` | Pertanyaan diskusi |
| GET | `/api/discussion-summaries` | ❌ | `DiscussionDataController@summaries` | Ringkasan diskusi |
| GET | `/api/discussion-understandings` | ❌ | `DiscussionDataController@understandings` | Hasil pemahaman |

---

## Chat & AI

| Method | Endpoint | Auth | Controller | Deskripsi |
|---|---|---|---|---|
| POST | `/api/ask` | ❌ | `GeminiController@askGemini` | Tanya AI umum |
| POST | `/api/echo` | ❌ | `GeminiController@echoRequest` | Health check |
| GET | `/api/echo` | ❌ | `GeminiController@echoRequest` | Health check (GET) |
| POST | `/api/student/chat` | ❌ | `GeminiController@chatStudent` | Chat siswa dengan AI |
| POST | `/api/student/check_understanding` | ❌ | `GeminiController@check_understanding` | Cek pemahaman siswa |
| POST | `/api/generate-questions` | ❌ | `GeminiController@generateQuestions` | Generate soal dari materi |
| POST | `/api/generate-groups` | ❌ | `GeminiController@generateGroups` | Generate kelompok diskusi |
| POST | `/api/discussion/submit_summary` | ❌ | `GeminiController@submitDiscussionSummary` | Submit ringkasan + evaluasi |
| GET | `/api/discussion/messages` | ❌ | `GeminiController@getDiscussionMessages` | Ambil pesan gabungan |
| GET | `/api/discussion/summaries` | ❌ | `GeminiController@getDiscussionSummaries` | Ambil ringkasan + auto-evaluate |
| POST | `/api/discussion/delete_all_messages` | ❌ | `GeminiController@deleteAllDiscussionMessages` | Hapus semua pesan |

---

## Statistik

| Kategori | Jumlah |
|---|---|
| Total Endpoints | ~35 |
| GET | 15 |
| POST | 16 |
| PUT | 1 |
| Dengan Auth | 5 (manual, bukan middleware) |
| Tanpa Auth | ~30 |
| Error Handling | Minimal (try-catch silently) |
