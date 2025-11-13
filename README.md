# Flow App — ai-demo-SEA

A multi-part demo for a Student Engagement Assistant (SEA) that showcases an AI-powered learning workflow across:

- backend/ — Laravel 11 API (Mysql or SQLite by default) and Gemini proxy
- sea_app/ — Flutter client (mobile/desktop) consuming the backend

This repository is designed for local-first development with stable HTTP contracts between components.

## Architecture

- Backend: Exposes REST endpoints for auth, classes, materials, quizzes, discussions, and AI helpers. Uses SQLite for easy setup.
- Flutter app: Primary client used in demos. Calls the exact same REST API as the web.
- Web frontend: Lightweight starter (React + Vite) for experimenting with the same API.

Keep API contracts stable. Endpoints are consumed by Flutter (`sea_app/lib/utils/send_message.dart` and `sea_app/lib/config/api.dart`).

## Stable API contracts

- AI core: `POST /api/ask`, `POST /api/echo`
- Student AI: `POST /api/student/chat` → `{ answer }`; `POST /api/student/check_understanding` → `{ result }`
- AI helpers: `POST /api/generate-questions`, `POST /api/generate-groups`
- Discussions: `GET /api/discussion/messages?chatroom_id=...`, `GET /api/discussion/summaries?chatroom_id=...`, `POST /api/discussion/submit_summary`, `POST /api/discussion/delete_all_messages`
- Auth: `POST /api/register`, `POST /api/login`, `GET /api/user`
- Classes: `GET/POST /api/classes`, user-class: `POST /api/join-class`, `GET /api/my-classes`, `GET /api/user-class-ids`, `GET /api/class-members?class_id=...`
- Materials: `GET/POST /api/materials`
- Quizzes: `GET/POST /api/quizzes`, `POST /api/quizzes/save`, `GET /api/quiz-questions`, `POST/GET /api/result-quiz`

All API routes skip CSRF (see `backend/routes/web.php` → `withoutMiddleware(VerifyCsrfToken::class)`).

## Prerequisites

- Windows 10/11 or macOS/Linux
- PHP 8.2+, Composer
- Flutter 3.22+ (for the Flutter client)

## Quick start (Windows PowerShell)

1) Backend (Laravel, port 8000):
	- Copy `backend/.env.example` to `.env` and set `GEMINI_API_KEY` (optional for AI routes)
	- Ensure SQLite DB file at `backend/database/database.sqlite` exists
	- Install and migrate/seed
	- Run dev server on 8000

2) Flutter client:
	- From `sea_app/`, run `flutter pub get`
	- Run on Windows desktop: `flutter run -d windows`
	- Default API base: `http://127.0.0.1:8000` (see `sea_app/lib/config/api.dart` and `sea_app/lib/utils/send_message.dart`)

Notes:
- When running on emulators or devices, update the API base host accordingly (e.g., Android emulator uses `10.0.2.2`).
- If you change the backend port/host, update the Flutter constants or centralize them.

## Seed data (demo)

The seeder provides:
- Quiz1 with 2 materials, 30 MCQs (4 choices each), and simulated results for all students
- Discussion room "Diskusi1" with 10 groups (3 students + 1 teacher per group), materials linked, AI chat rooms pre-populated

Run database migrations and seeders from `backend/`.

## Development workflow

- Keep endpoints and response shapes consistent across components.
- Prefer idempotent seeders (`firstOrCreate`) and migrations for schema changes.
- Never commit secrets; use `GEMINI_API_KEY` in `.env` for AI features.

## Attribution

- Flow App — ai-demo-SEA
- Developed by: Rosul Iman
- Advisor: Prof. Dr. Muhammad Anwar, S.Pd., M.T.

