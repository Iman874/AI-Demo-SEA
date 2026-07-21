# 🎓 SEA App (Smart Education Assistant) — English Documentation

> **[🇬🇧 English Version](./README_EN.md)** | **[🇮🇩 Bahasa Indonesia](./README_ID.md)** | **[🛠️ How to Run](./how_to_run.md)**

**Smart Education Assistant (SEA App)** is an AI-powered intelligent learning assistant platform designed to support interactive teaching and learning processes. The application is built with a **Laravel 11 REST API** backend architecture and a multi-platform **Flutter 3.22+ Client** (Android, Windows, iOS, macOS, Web).

---

## 🌟 Feature Highlights

| Module | Key Feature | Description |
|---|---|---|
| 🔐 **Auth & Roles** | Multi-Role Interface | Dynamic token authentication system with fully separated UI experiences for **Teacher (Blue #4B6A85)** and **Student (Orange #D97B43)** roles. |
| 📚 **Classes & Materials** | Learning Management | Teachers can create classes and upload PDF study materials. Material text is automatically extracted for AI context consumption. |
| 📝 **Quizzes & Evaluation** | Interactive Quiz & AI Generator | Teachers can manually create quizzes or auto-generate AI questions based on study materials. Students answer quizzes with instant question navigation and visual status indicators. |
| 📈 **Grade Recap** | Class Performance Analytics | Teacher grade recap dashboard displays class average metrics, pass rates, and detailed answer sheets per student via the `WindowViewQuestion` dialog. |
| 💬 **Discussion & AI** | Group Forums & AI Summaries | Group discussion rooms equipped with an AI Assistant capable of automatically summarizing discussions and evaluating student comprehension. |
| 🛠️ **Dev Showcase** | Developer Mode & QA Tools | Specialized developer shortcut menu to test all UI components, perform instant user role switching, and showcase quiz screens without authentication hurdles. |

---

## 🏗️ Tech Stack & Architecture

### 1. Backend (Laravel 11 API)
- **Framework**: Laravel 11 (PHP 8.2+)
- **Database**: SQLite (default) / MySQL
- **Authentication**: Custom Bearer Token (`ApiToken` model)
- **AI Integration**: Proxy API to Google Gemini API (Endpoints: `/api/ask`, `/api/generate-questions`, `/api/check_understanding`)

### 2. Frontend Client (Flutter 3.22+)
- **Framework**: Flutter (Dart ^3.9.2)
- **State Management**: Provider (`ChangeNotifier`)
- **Design & Theme**: Custom Dark & Light Theme, Dynamic Role Branding Color Palette

---

## 🌳 Page Hierarchy & Navigation Tree

Here is the complete navigation structure diagram for all screens in the SEA App:

```
SEA App (Client Navigation Tree)
│
├── 🚀 Splash Screen (splashscreen.dart)
│
├── 🔐 Auth & Onboarding Module
│   ├── ⚙️ API Connection Settings (connection_config_page.dart)
│   ├── 🔀 Role & Action Choice (page_choice_user.dart)
│   ├── 🔑 User Login (page_login_user.dart)
│   ├── 📝 Account Registration (page_daftar_user.dart)
│   └── 📖 User Guide (page_guide.dart)
│
├── 👨‍🎓 Student Mode (Role: Student / Theme Orange)
│   ├── 🏠 Student Main Dashboard (page_menu_home_student.dart)
│   │   ├── 👥 Join Class & Member Roster
│   │   ├── 📄 PDF Text & Learning Modules
│   │   └── 🤖 AI Assistant Chat & Comprehension Check
│   ├── 📝 Student Quiz Module (page_menu_quiz_student.dart)
│   │   ├── ⏱️ Quiz Answer Sheet (page_menu_quiz_work_student.dart)
│   │   └── 📊 Quiz Results & Feedback (page_menu_quiz_result_student.dart)
│   └── 💬 Student Discussion Forum (page_menu_discussion_student.dart)
│       ├── 👥 Group Detail (page_menu_discussion_detail_student.dart)
│       └── 💭 Chat Room & AI Summary (page_menu_discussion_chatroom_student.dart)
│
├── 👨‍🏫 Teacher Mode (Role: Teacher / Theme Blue)
│   ├── 🏠 Teacher Main Dashboard (page_menu_home_teacher.dart)
│   │   ├── ➕ Class Management (Create/Edit Class)
│   │   └── 📤 Upload & Manage PDF Study Materials
│   ├── 📝 Teacher Quiz Management (page_menu_quiz_teacher.dart)
│   │   ├── 🛠️ Quiz Editor Form (page_menu_quiz_editor_teacher.dart)
│   │   ├── ❓ Question Creator & AI Generator (page_quiz_questions_teacher.dart)
│   │   └── 📈 Grade Recap & Class Analytics (page_menu_quiz_result_teacher.dart)
│   └── 💬 Teacher Forum Management (page_menu_discussion_teacher.dart)
│       ├── ✍️ Group Editor Form (page_menu_discussion_editor_teacher.dart)
│       └── 📄 Discussion Details & AI Summary (page_menu_discussion_details_teacher.dart)
│
└── 🛠️ Dev Showcase Module
    ├── ⚙️ App Settings & Dev Switch (page_settings.dart)
    ├── 🎨 UI Card Component Gallery (page_showcase_cards.dart)
    └── 🧪 Quiz Work Showcase (page_showcase_work_quiz.dart)
```

---

## 📸 Preview Map & Screenshots

All user interface screenshots are located in the following directory:

> 🗂️ **`preview/`** (project root)

| Page Name | Theme / Mode | Dart File | Preview Screenshot File |
|---|---|---|---|
| **Student Dashboard (Light)** | Light Mode | `page_menu_home_student.dart` | [`preview/dashboard_siswa_light.jpeg`](./preview/dashboard_siswa_light.jpeg) |
| **Student Dashboard (Dark)** | Dark Mode | `page_menu_home_student.dart` | [`preview/dashboard_siswa_dark.jpeg`](./preview/dashboard_siswa_dark.jpeg) |
| **Teacher Dashboard (Light)** | Light Mode | `page_menu_home_teacher.dart` | [`preview/dashboard_guru_light.jpeg`](./preview/dashboard_guru_light.jpeg) |
| **Teacher Dashboard (Dark)** | Dark Mode | `page_menu_home_teacher.dart` | [`preview/dashboard_guru_dark.jpeg`](./preview/dashboard_guru_dark.jpeg) |
| **AI Chatbot Assistant Panel** | Light Mode | `page_menu_discussion_chatroom_student.dart` | [`preview/chat_room_ai_siswa_light.jpeg`](./preview/chat_room_ai_siswa_light.jpeg) |
| **Student Discussion Forum** | Light Mode | `page_menu_discussion_student.dart` | [`preview/forum_diskusi_siswa_light.jpeg`](./preview/forum_diskusi_siswa_light.jpeg) |
| **Student Quiz List** | Light Mode | `page_menu_quiz_student.dart` | [`preview/kuis_siswa_light.jpeg`](./preview/kuis_siswa_light.jpeg) |
| **Student Quiz Work Sheet** | Light Mode | `page_showcase_work_quiz.dart` | [`preview/pengerjaan_kuis_siswa_light.jpeg`](./preview/pengerjaan_kuis_siswa_light.jpeg) |
| **Student Quiz Results** | Light Mode | `page_menu_quiz_result_student.dart` | [`preview/hasil_kuis_siswa_light.jpeg`](./preview/hasil_kuis_siswa_light.jpeg) |
| **Teacher Quiz Management** | Light Mode | `page_menu_quiz_teacher.dart` | [`preview/kelola_kuis_guru_light.jpeg`](./preview/kelola_kuis_guru_light.jpeg) |
| **Teacher Grade Recap** | Light Mode | `page_menu_quiz_result_teacher.dart` | [`preview/rekap_nilai_kuis_guru_light.jpeg`](./preview/rekap_nilai_kuis_guru_light.jpeg) |
| **User Onboarding Guide** | Light Mode | `page_guide.dart` | [`preview/panduan_penggunaan_light.jpeg`](./preview/panduan_penggunaan_light.jpeg) |

---

## ⚡ Quick Steps to Run

```powershell
# 1. Start Backend API
cd backend
composer install
php artisan migrate --seed
php artisan serve --port=8000

# 2. Start Client Application
cd ../sea_app
flutter pub get
flutter run -d windows
```

> 📖 For detailed instructions, please refer to [`how_to_run.md`](./how_to_run.md).
