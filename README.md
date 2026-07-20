# 🎓 SEA App (Smart Education Assistant)

> **[🇬🇧 English](./README_EN.md)** | **[🇮🇩 Bahasa Indonesia](./README_ID.md)** | **[🛠️ Cara Menjalankan / How to Run](./how_to_run.md)**

---

**Smart Education Assistant (SEA App)** is an intelligent learning assistant platform built with **Laravel 11 REST API** (backend) and **Flutter 3.22+ client** (mobile/desktop).

---

**Smart Education Assistant (SEA App)** adalah platform asisten pembelajaran cerdas berbasis AI yang dibangun menggunakan **Laravel 11 REST API** (backend) dan **Flutter 3.22+ client** (mobile/desktop).

---

## 🌳 Structure & Screen Tree Hierarchy

```
SEA App Navigation Tree
│
├── 🚀 Splash Screen (splashscreen.dart)
│
├── 🔐 Auth & Initial Setup
│   ├── ⚙️ API Connection Config (connection_config_page.dart)
│   ├── 🔀 Role Selection (page_choice_user.dart)
│   ├── 🔑 Login (page_login_user.dart)
│   ├── 📝 Register (page_daftar_user.dart)
│   └── 📖 User Guide (page_guide.dart)
│
├── 👨‍🎓 Student Mode (Theme Orange #D97B43)
│   ├── 🏠 Student Home (page_menu_home_student.dart)
│   ├── 📝 Quiz List & Work (page_menu_quiz_student.dart & page_menu_quiz_work_student.dart)
│   ├── 📊 Quiz Evaluation (page_menu_quiz_result_student.dart)
│   └── 💬 Discussion Forum & AI (page_menu_discussion_student.dart)
│
├── 👨‍🏫 Teacher Mode (Theme Blue #4B6A85)
│   ├── 🏠 Teacher Home (page_menu_home_teacher.dart)
│   ├── 📝 Quiz Management & Editor (page_menu_quiz_teacher.dart & page_menu_quiz_editor_teacher.dart)
│   ├── 📈 Class Grade Recap (page_menu_quiz_result_teacher.dart)
│   └── 💬 Discussion Groups & AI Summary (page_menu_discussion_teacher.dart)
│
└── 🛠️ Dev & Showcase Mode
    ├── ⚙️ Settings & User Switcher (page_settings.dart)
    ├── 🎨 UI Card Gallery (page_showcase_cards.dart)
    └── 🧪 Quiz Work Showcase (page_showcase_work_quiz.dart)
```

---

## 🚀 Quick Start

```powershell
# 1. Start Backend API (Laravel)
cd backend
composer install
php artisan migrate --seed
php artisan serve --port=8000

# 2. Start Application Client (Flutter)
cd ../sea_app
flutter pub get
flutter run -d windows
```

> 📖 Complete Guide / Panduan Lengkap → [`how_to_run.md`](./how_to_run.md)

---

## 📸 Preview & Screenshot Map

All UI screenshots and layout preview assets are located in the:

> 🗂️ **`preview/`** folder (project root)

| Interface Module | Dart File | Preview File |
|---|---|---|
| **UI Component Showcase** | `page_showcase_cards.dart` | `preview/sea-card-showcase.png` |
| **Quiz Navigation & Work** | `page_menu_quiz_work_student.dart` | `preview/sea-quiz-navigation.png` |
| **Quiz Results & Recap** | `page_menu_quiz_result_student.dart` / `page_menu_quiz_result_teacher.dart` | `preview/sea-quiz-results.png` |
| **Complete Screen Map** | *All 24 Pages Listed in Docs* | See [`README_ID.md`](./README_ID.md) & [`README_EN.md`](./README_EN.md) |

---

## 🔖 Current Version

| Version | Release | Description |
|---|---|---|
| `v1.0.4` | UI/UX & Quiz Dialog Update | ✅ **Completed** — Quiz UI modernization, `WindowViewQuestion` dialog, safe unmount `dispose()`, and transition performance optimizations |
| `v1.0.0` | MVP Release | ✅ **Completed** — Classes, Quizzes, Discussion Groups, and Gemini AI Proxy integration |

---

## 📄 License

Private project — not for public distribution.
