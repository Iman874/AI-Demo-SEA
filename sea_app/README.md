# Flow App — Frontend (React + Vite)

This is a lightweight web UI that consumes the same API as the Flutter app. It’s primarily for experimentation and quick demos.

## Requirements

- Node.js 18+
- npm (or Yarn/Pnpm)

## Setup & run

1) Install dependencies
2) Start the dev server (Vite)
3) Open the URL shown in your terminal (usually http://localhost:5173)

If your backend runs on a non-default host/port, update the API base in your frontend code (commonly a config or service file). Default backend base is `http://127.0.0.1:8000`.

## Backend contracts

This app consumes the same stable contracts as the Flutter client:
- AI core: `POST /api/ask`, `POST /api/echo`
- Student AI: `POST /api/student/chat` → `{ answer }`; `POST /api/student/check_understanding` → `{ result }`
- AI helpers: `POST /api/generate-questions`, `POST /api/generate-groups`
- Discussions: `GET /api/discussion/messages?chatroom_id=...`, `GET /api/discussion/summaries?chatroom_id=...`, `POST /api/discussion/submit_summary`, `POST /api/discussion/delete_all_messages`
- Auth: `POST /api/register`, `POST /api/login`, `GET /api/user`
- Classes: `GET/POST /api/classes`, user-class: `POST /api/join-class`, `GET /api/my-classes`, `GET /api/user-class-ids`, `GET /api/class-members?class_id=...`
- Materials: `GET/POST /api/materials`
- Quizzes: `GET/POST /api/quizzes`, `POST /api/quizzes/save`, `GET /api/quiz-questions`, `POST/GET /api/result-quiz`

## Tips

- If you see CORS issues in the browser, ensure the backend is running and accepts requests from your Vite dev origin.
- When targeting devices/emulators, align the API base host (e.g., `10.0.2.2` on Android emulator). For browser testing on the same machine, `http://127.0.0.1:8000` typically works.

## Attribution

- Flow App — ai-demo-SEA
- Developed by: Rosul Iman
- Advisor: Prof. Dr. Muhammad Anwar, S.Pd., M.T.
