# Flow App — Backend (Laravel 11)

This is the Laravel API backend for the Flow App (ai-demo-SEA). It powers auth, classes, materials, quizzes, discussions, and AI helpers. SQLite is used by default for easy local setup.

## Requirements

- PHP 8.2+
- Composer
- SQLite (bundled with PHP) or another DB if you reconfigure `config/database.php`

## Environment

1) Copy `.env.example` to `.env`
2) Set the following:
	- `APP_KEY` (run `php artisan key:generate` to create it)
	- `DB_CONNECTION=sqlite`
	- Ensure `database/database.sqlite` exists (create an empty file)
	- `GEMINI_API_KEY=` (required for AI routes; leave empty to skip AI features)

## Install, migrate, seed, run

From this `backend/` directory:

1) Install dependencies with Composer
2) Run migrations and seeders
3) Serve the app on port 8000

Seeder contents include:
- Quiz1 with 2 materials and 30 MCQs (4 choices each), with simulated results for all students
- Discussion room "Diskusi1" with 10 groups (3 students + 1 teacher), linked materials, and AI chat rooms
 - DiscussionResultSeeder adds: 30 summaries (16 Understanding, 4 Not Fully Understanding, 10 Not Understanding), minimal chat history (1 student + 1 AI message per student), and marks related chat rooms inactive.

## API routes (stable contracts)

- AI core: `POST /api/ask`, `POST /api/echo`
- Student AI: `POST /api/student/chat` → `{ answer }`; `POST /api/student/check_understanding` → `{ result }`
- AI helpers: `POST /api/generate-questions`, `POST /api/generate-groups`
- Discussions: `GET /api/discussion/messages?chatroom_id=...`, `GET /api/discussion/summaries?chatroom_id=...`, `POST /api/discussion/submit_summary`, `POST /api/discussion/delete_all_messages`
- Auth: `POST /api/register`, `POST /api/login`, `GET /api/user`
- Classes: `GET/POST /api/classes`, user-class: `POST /api/join-class`, `GET /api/my-classes`, `GET /api/user-class-ids`, `GET /api/class-members?class_id=...`
- Materials: `GET/POST /api/materials`
- Quizzes: `GET/POST /api/quizzes`, `POST /api/quizzes/save`, `GET /api/quiz-questions`, `POST/GET /api/result-quiz`

All API routes skip CSRF (see `routes/web.php` → `withoutMiddleware(VerifyCsrfToken::class)`).

Data shape highlights:
- Chat request: `{ history: [{role, content}], materials: [{title, content, type}], chatroom_id?, sender_id? }` → response `{ answer }`
- Understanding check: `{ materials: [...], summary: string }` → `{ result }` where result ∈ {"Understanding","Not Fully Understanding","Not Understanding"}
- Generate groups: `{ class_id?, group_count, per_group?, quiz_id?, students?: [{id,name}] }` → newline text groups

## Testing

- PHPUnit: `vendor/bin/phpunit`

## Notes

- Keep endpoints and response shapes stable for Flutter/web clients.
- Prefer idempotent seeders (`firstOrCreate`) and migrations for schema changes.
- Never commit secrets; use `.env` for `GEMINI_API_KEY`.

## Attribution
## Running only a specific seeder

To run only the discussion result seeder (without re-running everything):

```
php artisan db:seed --class=DiscussionResultSeeder
```

If you need a full reset including that seeder:

```
php artisan migrate:fresh --seed
```

The `DiscussionResultSeeder` is idempotent: re-running will not duplicate summaries or messages; it will adjust understanding distribution to match 16/4/10 if changed.


- Flow App — ai-demo-SEA
- Developed by: Rosul Iman
- Advisor: Prof. Dr. Muhammad Anwar, S.Pd., M.T.
