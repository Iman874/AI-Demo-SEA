## Repo snapshot

This workspace is a multi-part demo app containing three main components:

- backend/ — Laravel 11 PHP app (API endpoints and Gemini proxy)
- frontend/ — React + Vite web UI (minimal starter app)
- sea_app/ — Flutter mobile/desktop app that talks to the backend

When editing, prefer changes that keep cross-platform interfaces stable: HTTP API contracts under `backend/routes/web.php` are consumed by the Flutter app (`sea_app/lib/utils/send_message.dart`) and may be used by the web UI.

## What to know first (big picture)

- The Laravel backend exposes simple POST endpoints used as an API gateway to Google Gemini. Important routes:
  - `POST /api/ask` — generic prompt -> Gemini (see `backend/app/Http/Controllers/GeminiController.php`)
  - `POST /api/echo` — returns the request payload (used for debugging)
  - `POST /api/student/chat` — chat endpoint that expects { history: [...], materials: [...] } and returns `{ answer }`
  - `POST /api/student/check_understanding` — expects { materials: [...], summary } and returns `{ result }`

- The backend reads the Gemini API key from the environment variable `GEMINI_API_KEY`. Example local env template: `backend/.env.example`.

- The Flutter client uses hard-coded API host/port (127.0.0.1:8000) in `sea_app/lib/config/api.dart` and `sea_app/lib/utils/send_message.dart` — adjust those when running backend elsewhere or when adding CI.

## Developer workflows (how to run, build, and test)

- Backend (Laravel / PHP):
  - Install PHP deps: use Composer in `backend/` (composer v2+). The project expects PHP 8.2+.
  - Create a `.env` from `.env.example` and set `GEMINI_API_KEY` before exercising Gemini calls.
  - Typical dev server (Laravel): `php artisan serve --port=8000` (runs PHP server bound to port 8000, matching Flutter default)
  - Frontend assets for Laravel use Vite; there is a `backend/package.json` with `dev` and `build` scripts.
  - Tests: `vendor/bin/phpunit` (phpunit config is at `backend/phpunit.xml`)

- Frontend (React + Vite):
  - From `frontend/`, use `npm install` then `npm run dev` to start Vite dev server. The current `src` is a minimal starter app — expand carefully.

- Flutter app (`sea_app/`):
  - Standard Flutter project (see `pubspec.yaml`). It uses `http`, `file_picker` and Syncfusion PDF packages.
  - The app calls the backend at `http://127.0.0.1:8000` by default. When developing locally, run the backend and then `flutter run` (or use `flutter run -d windows` on Windows).

## Project-specific conventions and patterns

- API contract: the Flutter app sends JSON with simple shapes:
  - chat: { history: [{role, content}], materials: [{title, content, type}] }
  - check_understanding: { materials: [...], summary: string }
  Backend returns JSON with `answer` (string) or `result` (one of: "Understanding", "Not Fully Understanding", "Not Understanding"). See `GeminiController.php` for exact behavior.

- Environment variables: Gemini key must be placed in `backend/.env` as `GEMINI_API_KEY`. The backend uses `env('GEMINI_API_KEY')` directly.

- No client-side authentication is implemented. Keep changes minimal if adding auth — update all three components.

## Integration points & external dependencies

- Google Gemini generative API: backend posts to `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent` with the API key in header `X-goog-api-key`.
- Flutter packages of note: `http`, `file_picker`, `syncfusion_flutter_pdf` (see `sea_app/pubspec.yaml`).
- Laravel dev tooling: `laravel/pint` (pint formatter) and `phpunit` for tests.

## Files to inspect when making changes

- `backend/app/Http/Controllers/GeminiController.php` — main server logic for AI calls and request/response shape
- `backend/routes/web.php` — route definitions
- `backend/.env.example` — template for local environment variables
- `sea_app/lib/utils/send_message.dart` and `sea_app/lib/config/api.dart` — Flutter client network code and host/port
- `sea_app/lib/models/*` — data models used in Flutter request shape
- `frontend/src/` — simple React UI; minimal usage but a good place to add a web client later

## Actionable guidance for AI agents

- When changing API behavior, update the controller, routes, and Flutter client examples together. Add tests in `backend/tests/Feature/` if changing responses.
- Do not commit real API keys. If adding CI or integration tests that need Gemini, mock responses or read the key from a secure secret store.
- Prefer small, focused diffs: this repo is a multi-language monorepo. Mention which component you modified in the PR title (e.g., "backend: improve Gemini error handling").

## Required for automated assistants

The following rules are mandatory for any automated assistant (or Copilot-style agent) working on this repository. These are in addition to the project's normal contributor guidance.

- Read the entire repository (or at least the relevant component folders) before making edits. Open and inspect `backend/`, `sea_app/`, and `frontend/` files that may be affected. Use code search and file reads to trace symbols and HTTP contracts.
- Before any non-trivial change, update the repository todo list using the `manage_todo_list` workflow: write the full todo list, mark one item `in-progress`, complete it when done. This ensures visibility and traceability of automated edits.
- When a change affects cross-cutting behavior (API contract, data models, client-server formats, seeding, or environment variables), update this `copilot-instructions.md` file with a brief note describing the change and any developer actions required (env vars, migrations, ports, etc.).
- Run quick sanity checks after edits: syntax check (PHP lint), Dart/Flutter analyzer or `flutter pub get` as appropriate, and run unit tests if available. If checks fail and cannot be fixed quickly, leave clear notes in this file about the failure and next steps.
- Never add or commit secrets (API keys, service account credentials). If a secret is required for testing, mock it or document how to provide it in `backend/.env.example` (do not add real values).
- Keep diffs minimal and prefer idempotent operations (use `firstOrCreate` and migrations where applicable). If randomness is used in seeding, document the behavior so maintainers know repeated seeds will vary.

Follow these rules every time before creating PRs or committing changes. They help keep the monorepo stable and make automated work auditable.

## Examples (copyable snippets)

- Example POST payload (student chat):

  {
    "history": [{"role":"student","content":"What is photosynthesis?"}],
    "materials": [{"title":"Biology 101","content":"Photosynthesis is...","type":"pdf"}]
  }

- Example successful response:

  { "answer": "Photosynthesis is the process by which..." }

## Quick TODOs for contributors

- If you add new backend routes, add them to `backend/routes/web.php` and update Flutter `api.dart` if the client needs them.
- Add PHP unit tests for backend behavior in `backend/tests/Feature`.

---
If anything here is unclear or missing (e.g., preferred local ports, CI hooks, or test credentials), tell me which component you'd like more detail about and I will iterate.
