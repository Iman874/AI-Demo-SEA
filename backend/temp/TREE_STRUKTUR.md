# Tree Struktur Backend — SEA App

```
backend/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       ├── Controller.php                    # Base controller (kosong)
│   │       ├── AuthController.php                # Register, Login, Get User
│   │       ├── ClassController.php               # CRUD Kelas
│   │       ├── UserClassController.php           # Join class, my-classes, class-members
│   │       ├── QuizController.php                # CRUD Quiz, Soal, Submit Hasil
│   │       ├── MaterialController.php            # CRUD Materi (text/pdf)
│   │       ├── DiscussionController.php          # CRUD Discussion Room + ChatRoomAI
│   │       ├── DiscussionStudentController.php   # Anggota diskusi
│   │       ├── DiscussionDataController.php      # Soal diskusi, ringkasan, pemahaman
│   │       └── GeminiController.php              # ★ GOD OBJECT — AI + Chat + Summary + Groups
│   │
│   ├── Models/
│   │   ├── User.php                              # Pengguna (teacher/student/admin)
│   │   ├── ApiToken.php                          # Token autentikasi
│   │   ├── SchoolClass.php                       # Kelas (table: classes)
│   │   ├── UserClass.php                         # Pivot: user ↔ class
│   │   ├── Quiz.php                              # Kuis
│   │   ├── QuizClass.php                         # Pivot: quiz ↔ class
│   │   ├── QuizStudent.php                       # Pivot: quiz ↔ user (UNUSED by controllers)
│   │   ├── Question.php                          # Soal kuis
│   │   ├── AnswerChoice.php                      # Pilihan jawaban
│   │   ├── QuestionAnswerChoice.php              # ★ OVERLOADED pivot: quiz+result+correct
│   │   ├── MaterialQuiz.php                      # Materi (quiz + discussion)
│   │   ├── ResultQuiz.php                        # Hasil kuis per siswa
│   │   ├── DiscussionRoom.php                    # Ruang diskusi
│   │   ├── ChatRoomAI.php                        # Chat room AI per grup
│   │   ├── DiscussionStudent.php                 # Anggota chat (ONLY model with relationships)
│   │   ├── DiscussionMessage.php                 # Pesan manusia
│   │   ├── AIMessage.php                         # Pesan AI
│   │   ├── DiscussionGroup.php                   # Grup diskusi
│   │   ├── DiscussionQuestion.php                # Pertanyaan diskusi
│   │   ├── SummaryDiscussion.php                 # Ringkasan siswa
│   │   └── ResultUnderstanding.php               # Hasil evaluasi pemahaman AI
│   │
│   └── Providers/
│       └── AppServiceProvider.php
│
├── config/                                        # Laravel config bawaan
│
├── database/
│   ├── migrations/                                # 20+ migration files
│   │   ├── 0000_01_01_000000_create_users_table.php
│   │   ├── 0001_01_01_000001_create_sessions.php
│   │   ├── 0001_01_01_000001_create_cache_table.php
│   │   ├── 0001_01_01_000002_create_jobs_table.php
│   │   ├── 0001_01_01_000002_fix_sessions_userid.php
│   │   ├── 2025_10_19_000002_create_api_tokens_table.php
│   │   ├── 2025_10_19_000002_create_classes_table.php
│   │   ├── 2025_10_19_000003_create_user_classes_table.php
│   │   ├── 2025_10_19_000004_create_quizzes_table.php
│   │   ├── 2025_10_19_000005_create_quiz_classes_table.php
│   │   ├── 2025_10_19_000006_create_questions_table.php
│   │   ├── 2025_10_19_000007_create_answer_choices_table.php
│   │   ├── 2025_10_19_000008_create_question_answer_choices_table.php
│   │   ├── 2025_10_19_000009_create_material_quiz_table.php
│   │   ├── 2025_10_19_000010_create_result_quiz_table.php
│   │   ├── 2025_10_19_000011_create_quiz_students_table.php
│   │   ├── 2025_10_19_000012_create_discussion_rooms_table.php
│   │   ├── 2025_10_19_000013_create_chat_room_ai_table.php
│   │   ├── 2025_10_19_000014_create_discussion_messages_table.php
│   │   ├── 2025_10_19_000015_create_ai_messages_table.php
│   │   ├── 2025_10_19_000016_create_summary_discussions_table.php
│   │   ├── 2025_10_19_000017_create_result_understandings_table.php
│   │   ├── 2025_10_20_000001_create_discussion_students_table.php
│   │   ├── 2025_10_20_000001_add_relations_to_material_quiz_table.php
│   │   ├── 2025_10_21_000011_create_result_question_table.php
│   │   ├── 2025_10_22_000012_create_discussion_questions_table.php
│   │   ├── 2025_10_22_000013_add_group_fields_to_discussion_rooms_table.php
│   │   └── 2025_10_22_000014_create_discussion_groups_table.php
│   │
│   └── seeders/
│       ├── DatabaseSeeder.php                    # Seeder utama (30 siswa, 1 guru, 1 kelas)
│       ├── DevUserSeeder.php                     # Akun demo dev (guru + 3 siswa)
│       └── DiscussionResultSeeder.php            # Seeder hasil diskusi + pemahaman
│
├── routes/
│   ├── web.php                                   # ★ 82 endpoint, SEMUA di sini (tanpa api.php)
│   └── console.php
│
├── tests/
│   ├── TestCase.php
│   ├── Unit/ExampleTest.php
│   └── Feature/ExampleTest.php
│
└── storage/logs/laravel.log
```

## Ringkasan Statistik

| Item | Jumlah |
|---|---|
| Controllers | 9 (+ 1 base) |
| Models | 19 |
| Migrations | 20+ (termasuk fix & alter) |
| Seeders | 3 |
| Routes (API) | ~35 endpoint |
| Tabel Database | 18 tabel utama |
| Tabel Framework | 3 (sessions, cache, jobs) |
