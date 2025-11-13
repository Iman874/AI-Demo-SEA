## Repo snapshot (big picture)

Multi-part demo app with three components:
- backend/ — Laravel 11 API and Gemini proxy
- frontend/ — React + Vite starter
- sea_app/ — Flutter client (mobile/desktop) that calls the backend

Keep HTTP contracts stable: endpoints in `backend/routes/web.php` are consumed by Flutter (`sea_app/lib/utils/send_message.dart` and `sea_app/lib/config/api.dart`) and may be reused by the web UI.

## Routes map (stable API contracts)

- AI core: `POST /api/ask`, `POST /api/echo`
- Student AI: `POST /api/student/chat` => `{ answer }`; `POST /api/student/check_understanding` => `{ result }`
- AI helpers: `POST /api/generate-questions`, `POST /api/generate-groups`
- Discussions: `GET /api/discussion/messages?chatroom_id=...`, `GET /api/discussion/summaries?chatroom_id=...`, `POST /api/discussion/submit_summary`, `POST /api/discussion/delete_all_messages`
- Auth: `POST /api/register`, `POST /api/login`, `GET /api/user`
- Classes: `GET/POST /api/classes`, user-class: `POST /api/join-class`, `GET /api/my-classes`, `GET /api/user-class-ids`, `GET /api/class-members?class_id=...`
- Materials: `GET/POST /api/materials`
- Quizzes: `GET/POST /api/quizzes`, `POST /api/quizzes/save`, `GET /api/quiz-questions`, `POST/GET /api/result-quiz`

All API routes skip CSRF (see `withoutMiddleware(VerifyCsrfToken::class)` in `web.php`).

## Env, build, and run

- Env: Backend requires `GEMINI_API_KEY` in `backend/.env` (added to `.env.example`). Default DB is SQLite. Create `database/database.sqlite`, then migrate/seed as needed.
- Backend (from `backend/`):
  - Composer install, then run: `php artisan migrate`; dev server: `php artisan serve --port=8000`
  - Frontend assets via Vite: `npm run dev` or `npm run build`
  - Tests: `vendor/bin/phpunit`
- Flutter (from `sea_app/`): `flutter pub get`; run: `flutter run -d windows` (default API base `http://127.0.0.1:8000`)
- Frontend (from `frontend/`): `npm install`; `npm run dev`

## Data shapes and client conventions

- Chat request: `{ history: [{role, content}], materials: [{title, content, type}], chatroom_id?, sender_id? }` → response `{ answer }`
- Understanding check: `{ materials: [...], summary: string }` → `{ result }` where result ∈ {"Understanding","Not Fully Understanding","Not Understanding"} (or model text)
- Generate groups: `{ class_id?, group_count, per_group?, quiz_id?, students?: [{id,name}] }` → newline text: `1, (123, John Doe), (124, Jane Doe)` …; server validates coverage and may fallback to deterministic grouping
- Discussion messages: `GET` returns `{ data: [...] }`; submit summary requires `{ chatroom_id, user_id, content }`
- Flutter API base is duplicated in `sea_app/lib/config/api.dart` and `sea_app/lib/utils/send_message.dart` (constants). If you change host/port, update both or centralize.

## Key files to read/change

- `backend/app/Http/Controllers/GeminiController.php` — Gemini calls, chat/check-understanding, group generation
- `backend/routes/web.php` — API surface map above
- `backend/.env.example` — includes `GEMINI_API_KEY=` placeholder and SQLite defaults
- Flutter networking: `sea_app/lib/utils/send_message.dart`, base URLs in `sea_app/lib/config/api.dart`
- Models and shapes: `sea_app/lib/models/*`

## Guardrails for AI agents

- Preserve API contracts. When changing an endpoint, update: controller + `routes/web.php` + Flutter constants, and add/adjust tests in `backend/tests/Feature/`.
- Never commit secrets. Read `GEMINI_API_KEY` from env; for CI, mock Gemini or use secret store.
- Keep diffs small and idempotent (prefer `firstOrCreate`, migrations for schema). Document randomness (e.g., seeders, group shuffling).
- Maintain a todo using the provided workflow before non-trivial edits; run quick sanity checks (PHP unit/analyzer, Flutter analyzer) post-change.

## Examples

- Chat
  `{ "history":[{"role":"student","content":"What is photosynthesis?"}], "materials":[{"title":"Bio 101","content":"...","type":"pdf"}] }`
- Check understanding
  `{ "materials":[{"title":"Bio 101","content":"..."}], "summary":"..." }`
- Generate groups (class-driven)
  `{ "class_id": 1, "group_count": 4, "quiz_id": 2 }`

If anything here is unclear (ports, data shapes, or expected outputs), say which component you’re touching and we’ll iterate.
