# Relasi & Skema Tabel Database — SEA App

## Diagram Relasi (ERD Text)

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │──1:N──│  api_tokens  │       │   classes    │
│──────────────│       │──────────────│       │──────────────│
│ id_user (PK) │       │ id (PK)      │       │ id_class(PK) │
│ name         │       │ user_id (FK) │──N:1──│ code_class   │
│ role         │       │ token        │       │ name         │
│ email        │       └──────────────┘       │ description  │
│ password     │                              │ semester     │
└──────┬───────┘                              │ created_by   │
       │                                      └──────┬───────┘
       │                                             │
       │          ┌──────────────┐                   │
       └────N:M───│ user_classes │──────N:M──────────┘
                  │──────────────│
                  │ id_userclass │
                  │ fk_id_user   │ (FK → users)
                  │ fk_id_class  │ (FK → classes)
                  │ role         │
                  └──────────────┘

┌──────────────┐       ┌──────────────┐
│    quizzes   │──1:N──│ quiz_classes │──N:1── classes
│──────────────│       │──────────────│
│ id_quiz (PK) │       │ id_quiz_class│
│ title        │       │ fk_id_quiz   │ (FK → quizzes)
│ duration     │       │ fk_id_class  │ (FK → classes)
│ created_by   │       └──────────────┘
└──────┬───────┘
       │
       ├──1:N── questions ──1:N── question_answer_choices ──N:1── answer_choices
       │         │                      │
       │         │                      └──N:1── result_quiz (nullable, untuk jawaban per-quiz)
       │         │
       │         └──N:1── material_quiz (nullable fk_id_material)
       │
       ├──1:N── result_quiz ──1:N── result_question
       │              │
       │              └──N:1── users (fk_id_user)
       │
       └──1:N── quiz_students ──N:1── users (fk_id_user)
                          │
                          └──N:1── classes (fk_id_class, nullable)

┌──────────────────┐       ┌──────────────────┐
│ discussion_rooms │──1:N──│   chat_room_ai   │
│──────────────────│       │──────────────────│
│ id_discussionroom│       │ id_chatroomai    │
│ title            │       │ title            │
│ description      │       │ description      │
│ tag              │       │ status           │
│ status           │       │ ai_model         │
│ num_groups       │       │ created_by       │
│ students_per_grp │       │ fk_id_class      │
│ created_by       │       │ fk_id_discussion │ (FK → discussion_rooms)
│ fk_id_class      │       └────────┬─────────┘
└──────────────────┘                │
                                    │
       ┌────────────────────────────┼────────────────────────────┐
       │                            │                            │
       ├──1:N── discussion_messages │──1:N── ai_messages         │
       │         │                  │         │                  │
       │         └──N:1── users     │         └──(no FK users)  │
       │                            │                            │
       ├──1:N── discussion_students │──1:N── discussion_groups   │
       │         │                  │         │                  │
       │         └──N:1── users     │         └──N:1── users     │
       │                            │                            │
       ├──1:N── discussion_questions│──1:N── summary_discussions │
       │         │                  │         │                  │
       │         └──N:1── users     │         └──N:1── users     │
       │                            │                            │
       │                            └────────────────────────────┘
       │
       └──1:N── material_quiz (fk_id_discussionroom)
                      │
                      └──(juga terhubung ke quizzes via fk_id_quiz)

┌──────────────────┐
│ summary_discuss. │──1:N── result_understandings
│──────────────────│         │
│ id_summarydisc.  │         └──(hanya type: string)
│ content          │
│ fk_id_user       │ (FK → users)
│ fk_id_chatroomai │ (FK → chat_room_ai)
└──────────────────┘

┌──────────────────┐
│ result_question  │
│──────────────────│
│ id_resultquestion│
│ fk_id_resultquiz │ (FK → result_quiz)
│ fk_id_question   │ (FK → questions)
│ selected_choice  │ (id pilihan siswa)
│ correct_choice   │ (id pilihan benar)
│ is_correct       │
│ point            │
└──────────────────┘
```

---

## Detail Setiap Tabel

### 1. `users` — Pengguna

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_user` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `name` | varchar | NOT NULL | |
| `role` | enum | `teacher`, `student`, `admin` | Default: `student` |
| `email` | varchar | UNIQUE | |
| `email_verified_at` | timestamp | NULLABLE | |
| `password` | varchar | NOT NULL | Hashed |
| `remember_token` | varchar | | Laravel bawaan |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 2. `api_tokens` — Token Autentikasi

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id` | bigint (PK) | AUTO_INCREMENT | |
| `user_id` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `token` | varchar(80) | UNIQUE | SHA-256 hash |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tidak ada field `expires_at` di migration, tapi `DevUserSeeder` mencoba isi `expires_at`. Ini akan error kecuali kolom ditambah manual.

---

### 3. `classes` — Kelas

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_class` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `code_class` | varchar | UNIQUE | Format: `CLS001` |
| `name` | varchar | NOT NULL | |
| `description` | text | NULLABLE | |
| `semester` | varchar | NULLABLE | Max 10 char |
| `created_by` | bigint (FK) | → `users.id_user` ON DELETE SET NULL | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 4. `user_classes` — Pivot User ↔ Kelas

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_userclass` | bigint (PK) | AUTO_INCREMENT | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `fk_id_class` | bigint (FK) | → `classes.id_class` ON DELETE CASCADE | |
| `role` | enum | `teacher`, `student` | Default: `student` |
| `joined_at` | timestamp | NULLABLE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tidak ada UNIQUE constraint di `(fk_id_user, fk_id_class)`. Bisa duplikasi enrollment.

---

### 5. `quizzes` — Kuis

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_quiz` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `title` | varchar | NOT NULL | |
| `duration` | int | NULLABLE | Dalam menit |
| `created_by` | bigint (FK) | → `users.id_user` ON DELETE SET NULL | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 6. `quiz_classes` — Pivot Quiz ↔ Kelas

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_quiz_class` | bigint (PK) | AUTO_INCREMENT | |
| `fk_id_quiz` | bigint (FK) | → `quizzes.id_quiz` ON DELETE CASCADE | |
| `fk_id_class` | bigint (FK) | → `classes.id_class` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tidak ada UNIQUE constraint di `(fk_id_quiz, fk_id_class)`. Bisa duplikasi.

---

### 7. `questions` — Soal Kuis

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_question` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_quiz` | bigint (FK) | → `quizzes.id_quiz` ON DELETE CASCADE | |
| `number` | int | NOT NULL | Urutan soal |
| `question_text` | text | NOT NULL | |
| `point` | int | DEFAULT 0 | Bobot poin |
| `fk_id_material` | bigint (FK) | → `material_quiz.id_material` ON DELETE SET NULL | NULLABLE |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 8. `answer_choices` — Pilihan Jawaban

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_answerchoice` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `content` | text | NOT NULL | Teks jawaban |
| `is_correct` | bool | DEFAULT false | ★ MASALAH: redundant dengan pivot |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 9. `question_answer_choices` — ★ OVERLOADED PIVOT

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_questionanswerchoice` | bigint (PK) | AUTO_INCREMENT | |
| `fk_id_question` | bigint (FK) | → `questions.id_question` ON DELETE CASCADE | |
| `fk_id_answerchoice` | bigint (FK) | → `answer_choices.id_answerchoice` ON DELETE CASCADE | |
| `is_correct` | bool | DEFAULT false | ★ Duplikasi dari `answer_choices.is_correct` |
| `fk_id_resultquiz` | bigint (FK) | → `result_quiz.id_resultquiz` ON DELETE SET NULL | NULLABLE |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**★ KRITIS — Tabel ini punya 3 fungsi sekaligus:**
1. **Pivot normal** — menghubungkan question ↔ answer_choice (fk_id_resultquiz = NULL)
2. **Jawaban siswa** — mencatat jawaban siswa per quiz (fk_id_resultquiz != NULL)
3. **Penanda benar/salah** — is_correct duplikat dari answer_choices

Ini membuat tabel ini ambigu dan sulit di-maintain.

---

### 10. `material_quiz` — Materi

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_material` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `title` | varchar | NOT NULL | |
| `content` | text | NOT NULL | |
| `type` | enum | `text`, `pdf`, `image`, `video` | NULLABLE |
| `fk_id_quiz` | bigint | NULLABLE | Ditambah via ALTER migration |
| `fk_id_discussionroom` | bigint | NULLABLE | Ditambah via ALTER migration |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tabel ini multifungsi (quiz + discussion) dengan foreign key nullable. Tidak ada FK constraint di migration — hanya index.

---

### 11. `result_quiz` — Hasil Kuis

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_resultquiz` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_quiz` | bigint (FK) | → `quizzes.id_quiz` ON DELETE CASCADE | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `score` | float | NULLABLE | Persentase 0-100 |
| `status` | enum | `in_progress`, `finished`, `graded` | Default: `in_progress` |
| `started_at` | timestamp | NULLABLE | |
| `finished_at` | timestamp | NULLABLE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tidak ada UNIQUE constraint di `(fk_id_quiz, fk_id_user)`. Siswa bisa submit berkali-kali tanpa batasan.

---

### 12. `quiz_students` — Pivot Quiz ↔ Siswa

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_quizstudent` | bigint (PK) | AUTO_INCREMENT | |
| `fk_id_quiz` | bigint (FK) | → `quizzes.id_quiz` ON DELETE CASCADE | |
| `fk_id_class` | bigint (FK) | → `classes.id_class` ON DELETE SET NULL | NULLABLE |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**★ MASALAH: Tabel ini TIDAK DIGUNAKAN oleh controller manapun.** Hanya di-seed di DatabaseSeeder.

---

### 13. `result_question` — Detail Jawaban Per Soal

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_resultquestion` | bigint (PK) | AUTO_INCREMENT | |
| `fk_id_resultquiz` | bigint (FK) | → `result_quiz.id_resultquiz` ON DELETE CASCADE | |
| `fk_id_question` | bigint (FK) | → `questions.id_question` ON DELETE CASCADE | |
| `selected_choice_id` | bigint | NULLABLE | ID pilihan siswa |
| `correct_choice_id` | bigint | NULLABLE | ID pilihan benar |
| `is_correct` | bool | DEFAULT false | |
| `point` | int | DEFAULT 0 | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Catatan:** Tabel ini ditambahkan SETELAH tabel `question_answer_choices`, menunjukkan evolusi desain yang kurang terencana. Fungsi `question_answer_choices.fk_id_resultquiz` dan tabel `result_question` saling tumpang tindih.

---

### 14. `discussion_rooms` — Ruang Diskusi

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_discussionroom` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `title` | varchar | NOT NULL | |
| `description` | text | NULLABLE | |
| `tag` | varchar | NULLABLE | |
| `status` | enum | `open`, `closed` | Default: `open` |
| `num_groups` | unsigned int | NULLABLE | Ditambah via ALTER |
| `students_per_group` | unsigned int | NULLABLE | Ditambah via ALTER |
| `created_by` | bigint (FK) | → `users.id_user` ON DELETE SET NULL | |
| `fk_id_class` | bigint (FK) | → `classes.id_class` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 15. `chat_room_ai` — Chat Room AI

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_chatroomai` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `title` | varchar | NOT NULL | |
| `description` | text | NULLABLE | |
| `status` | enum | `active`, `inactive` | Default: `active` |
| `ai_model` | varchar | NULLABLE | Contoh: `gemini-2.0-flash` |
| `created_by` | bigint (FK) | → `users.id_user` ON DELETE SET NULL | |
| `fk_id_class` | bigint (FK) | → `classes.id_class` ON DELETE SET NULL | |
| `fk_id_discussionroom` | bigint (FK) | → `discussion_rooms.id_discussionroom` ON DELETE SET NULL | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Hubungan `discussion_rooms` → `chat_room_ai` seharusnya 1:1 atau 1:N, tapi tidak ada UNIQUE constraint. Bisa ada banyak ChatRoomAI per DiscussionRoom.

---

### 16. `discussion_messages` — Pesan Diskusi (Manusia)

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_message` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `role` | enum | `student`, `teacher` | NULLABLE |
| `content` | text | NOT NULL | |
| `content_type` | enum | `text`, `image`, `file` | NULLABLE |
| `status` | enum | `sent`, `deleted`, `edited` | Default: `sent` |
| `response_meta` | json | NULLABLE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 17. `ai_messages` — Pesan AI

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_aimessage` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `role` | varchar | NULLABLE | Harusnya enum `ai` |
| `content` | text | NOT NULL | |
| `content_type` | enum | `text`, `json`, `structured` | NULLABLE |
| `status` | enum | `ok`, `failed` | NULLABLE |
| `response_meta` | json | NULLABLE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 18. `discussion_students` — Anggota Chat

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_discussionstudent` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:** Tidak ada UNIQUE constraint di `(fk_id_chatroomai, fk_id_user)`.

---

### 19. `discussion_groups` — Grup Diskusi

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_discussiongroup` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `group_no` | unsigned int | NOT NULL | Nomor grup |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE SET NULL | NULLABLE |
| `user_name` | varchar | NULLABLE | Redundan — ada di users.name |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

**Masalah:**
- `user_name` redundant — seharusnya join ke `users.name`
- Tidak ada UNIQUE constraint di `(fk_id_chatroomai, fk_id_user)`

---

### 20. `discussion_questions` — Pertanyaan Diskusi

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_discussionquestion` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `content` | text | NOT NULL | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 21. `summary_discussions` — Ringkasan Siswa

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_summarydiscussion` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `content` | text | NOT NULL | |
| `fk_id_user` | bigint (FK) | → `users.id_user` ON DELETE CASCADE | |
| `fk_id_chatroomai` | bigint (FK) | → `chat_room_ai.id_chatroomai` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

### 22. `result_understandings` — Hasil Evaluasi Pemahaman AI

| Kolom | Tipe | Constraint | Catatan |
|---|---|---|---|
| `id_resultunderstanding` | bigint (PK) | AUTO_INCREMENT | Custom PK name |
| `type` | varchar | NULLABLE | `Understanding` / `Not Fully Understanding` / `Not Understanding` |
| `fk_id_summarydiscussion` | bigint (FK) | → `summary_discussions.id_summarydiscussion` ON DELETE CASCADE | |
| `created_at` | timestamp | | |
| `updated_at` | timestamp | | |

---

## Ringkasan Masalah Skema

| # | Masalah | Dampak |
|---|---|---|
| 1 | `question_answer_choices` overloaded (pivot + jawaban + benar/salah) | Query membingungkan, data redundant |
| 2 | `answer_choices.is_correct` duplikat dengan `question_answer_choices.is_correct` | Inconsistency risk |
| 3 | `result_question` dan `question_answer_choices.fk_id_resultquiz` saling tumpang tindih | Dua cara menyimpan hal yang sama |
| 4 | `material_quiz` multifungsi (quiz + discussion) tanpa FK constraint | Data integrity lemah |
| 5 | `quiz_students` tidak digunakan oleh controller | Dead code |
| 6 | `discussion_groups.user_name` redundant | Inkonsistensi data |
| 7 | Banyak tabel pivot tanpa UNIQUE constraint | Duplikasi data |
| 8 | `api_tokens` tidak ada `expires_at` di migration | Token tidak pernah expired |
| 9 | Naming konsisten: `snake_case` vs `camelCase` di response | Frontend harus handle 2 format |
