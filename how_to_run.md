# 🛠️ Cara Menjalankan SEA App (Smart Education Assistant)

Aplikasi **Smart Education Assistant (SEA)** adalah sistem pembelajaran berbasis AI yang terdiri dari dua komponen utama:
1. **Backend**: REST API berbasis **Laravel 11 (PHP 8.2+)** dengan proxy integrasi **Google Gemini API**.
2. **Client**: Aplikasi multi-platform (Android, Windows, iOS, macOS, Web) berbasis **Flutter 3.22+**.

---

## ⚡ Quick Start (Jalan Cepat)

### 1. Jalankan Backend (Laravel 11 API)
```powershell
cd backend
composer install
cp .env.example .env
# Edit .env: Isi GEMINI_API_KEY=key_anda_disini
php artisan key:generate
php artisan migrate --seed
php artisan serve --port=8000
```

### 2. Jalankan Client (Flutter)
```powershell
cd sea_app
flutter pub get
flutter run -d windows
# atau: flutter run -d android
```

---

## 📋 Prasyarat Sistem

Pastikan tools berikut sudah terpasang di perangkat Anda:

| Komponen | Versi Minimum | Keterangan |
|---|---|---|
| **PHP** | `8.2.0`+ | Bahasa pemrograman backend Laravel |
| **Composer** | `2.5`+ | Dependency manager PHP |
| **Flutter SDK** | `3.22.0`+ (Dart ^3.9.2) | SDK antarmuka aplikasi Flutter |
| **Database** | SQLite / MySQL | Database default menggunakan SQLite (`database/database.sqlite`) |
| **Gemini API Key** | - | Diperlukan untuk fitur AI (diskusi, generate soal, cek pemahaman) |

---

## ⚙️ Konfigurasi Environment Variable

### 1. Backend (`backend/.env`)
Salin file `.env.example` menjadi `.env` lalu sesuaikan konfigurasi berikut:

```env
APP_NAME=SEA_Backend
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=sqlite
# Atau jika menggunakan MySQL:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=sea_db
# DB_USERNAME=root
# DB_PASSWORD=

GEMINI_API_KEY=your_google_gemini_api_key_here
```

### 2. Flutter Client (`sea_app/lib/services/api_service.dart`)
Secara default, Flutter client akan terhubung ke `http://localhost:8000/api` atau IP emulator `http://10.0.2.2:8000/api`. Konfigurasi ini dapat diubah secara dinamis saat aplikasi berjalan melalui halaman **Pengaturan Koneksi API** di dalam aplikasi.

---

## 🚀 Langkah Instalasi & Pengujian Detil

### Langkah 1: Setup Backend (Laravel)

```powershell
# Buka direktori backend
cd backend

# Install paket PHP
composer install

# Buat database SQLite jika belum ada (Opsional untuk SQLite)
New-Item -ItemType File -Path database/database.sqlite -Force

# Jalankan migrasi dan seeder data demo
php artisan migrate:fresh --seed

# Jalankan server lokal
php artisan serve --port=8000
```
> ℹ️ Server backend akan aktif di `http://127.0.0.1:8000`.

### Langkah 2: Setup Client (Flutter)

```powershell
# Buka direktori sea_app
cd sea_app

# Ambil library Flutter
flutter pub get

# Jalankan analisa kode untuk memastikan 0 error
flutter analyze

# Jalankan aplikasi (pilih platform target)
flutter run -d windows
```

---

## 🌳 Pohon Struktur Halaman (Screen Tree Hierarchy)

Berikut adalah struktur navigasi dan hirarki halaman antarmuka pada SEA App:

```
App Navigation Root
│
├── 🚀 Splash Screen (splashscreen.dart)
│
├── 🔐 Auth & Initial Flow
│   ├── ⚙️ Pengaturan Koneksi API (connection_config_page.dart)
│   ├── 🔀 Pilihan Peran/Aksi (page_choice_user.dart)
│   ├── 🔑 Login User (page_login_user.dart)
│   ├── 📝 Pendaftaran User (page_daftar_user.dart)
│   └── 📖 Panduan Pengguna / Guide (page_guide.dart)
│
├── 👨‍🎓 Mode Siswa (Role: Student - Theme: Orange #D97B43)
│   ├── 🏠 Dasbor Utama Siswa (page_menu_home_student.dart)
│   │   ├── 📚 Daftar Kelas & Enrollment (Join Class Dialog)
│   │   ├── 📄 Modul & Teks PDF Pembelajaran
│   │   └── 🤖 AI Assistant Chat & Evaluasi Pemahaman
│   ├── 📝 Modul Kuis Siswa (page_menu_quiz_student.dart)
│   │   ├── ⏱️ Lembar Pengerjaan Soal (page_menu_quiz_work_student.dart)
│   │   └── 📊 Hasil & Evaluasi Nilai Kuis (page_menu_quiz_result_student.dart)
│   └── 💬 Forum Diskusi Siswa (page_menu_discussion_student.dart)
│       ├── 👥 Detail Grup Diskusi (page_menu_discussion_detail_student.dart)
│       └── 💭 Chat Room & Ringkasan AI (page_menu_discussion_chatroom_student.dart)
│
├── 👨‍🏫 Mode Guru (Role: Teacher - Theme: Blue #4B6A85)
│   ├── 🏠 Dasbor Utama Guru (page_menu_home_teacher.dart)
│   │   ├── ➕ Buat / Kelola Kelas Pembelajaran
│   │   └── 📤 Upload & Kelola Materi Pembelajaran (PDF)
│   ├── 📝 Manajemen Kuis Guru (page_menu_quiz_teacher.dart)
│   │   ├── 🛠️ Form Editor Kuis (page_menu_quiz_editor_teacher.dart)
│   │   ├── ❓ Editor Soal & Kunci Jawaban (page_quiz_questions_teacher.dart)
│   │   └── 📈 Rekap Nilai & Metrik Kelas (page_menu_quiz_result_teacher.dart)
│   └── 💬 Kelola Diskusi Guru (page_menu_discussion_teacher.dart)
│       ├── ✍️ Editor Grup Diskusi & Kelompok (page_menu_discussion_editor_teacher.dart)
│       └── 📄 Detail Diskusi & Generasi AI (page_menu_discussion_details_teacher.dart)
│
└── 🛠️ Pengembang & Showcase (Dev Mode)
    ├── ⚙️ Pengaturan & Switch User (page_settings.dart)
    ├── 🎨 Showcase Component Gallery (page_showcase_cards.dart)
    └── 🧪 Showcase Pengerjaan Kuis (page_showcase_work_quiz.dart)
```

---

## 📸 Daftar Lengkap Halaman & Berkas Preview

Tangkapan layar (screenshot) dan berkas dokumentasi antarmuka tersimpan di direktori:

> 🗂️ **`preview/`** (root project)

### Map Halaman Aplikasi

| Kategori Halaman | Nama Berkas Halaman (Dart) | Berkas Preview |
|---|---|---|
| **Awal / Auth** | `splashscreen.dart` | `preview/sea-auth-splash.png` |
| | `connection_config_page.dart` | `preview/sea-auth-config.png` |
| | `page_choice_user.dart` | `preview/sea-auth-choice.png` |
| | `page_login_user.dart` | `preview/sea-auth-login.png` |
| | `page_daftar_user.dart` | `preview/sea-auth-register.png` |
| | `page_guide.dart` | `preview/sea-auth-guide.png` |
| **Siswa (Student)** | `page_menu_home_student.dart` | `preview/sea-student-home.png` |
| | `page_menu_quiz_student.dart` | `preview/sea-student-quiz-list.png` |
| | `page_menu_quiz_work_student.dart` | `preview/sea-quiz-navigation.png` |
| | `page_menu_quiz_result_student.dart` | `preview/sea-quiz-results.png` |
| | `page_menu_discussion_student.dart` | `preview/sea-student-discussion.png` |
| | `page_menu_discussion_detail_student.dart` | `preview/sea-student-discussion-detail.png` |
| | `page_menu_discussion_chatroom_student.dart` | `preview/sea-student-chatroom.png` |
| **Guru (Teacher)** | `page_menu_home_teacher.dart` | `preview/sea-teacher-home.png` |
| | `page_menu_quiz_teacher.dart` | `preview/sea-teacher-quiz-list.png` |
| | `page_menu_quiz_editor_teacher.dart` | `preview/sea-teacher-quiz-editor.png` |
| | `page_quiz_questions_teacher.dart` | `preview/sea-teacher-question-editor.png` |
| | `page_menu_quiz_result_teacher.dart` | `preview/sea-teacher-quiz-recap.png` |
| | `page_menu_discussion_teacher.dart` | `preview/sea-teacher-discussion.png` |
| | `page_menu_discussion_editor_teacher.dart` | `preview/sea-teacher-discussion-editor.png` |
| | `page_menu_discussion_details_teacher.dart` | `preview/sea-teacher-discussion-detail.png` |
| **Dev Showcase** | `page_settings.dart` | `preview/sea-dev-settings.png` |
| | `page_showcase_cards.dart` | `preview/sea-card-showcase.png` |
| | `page_showcase_work_quiz.dart` | `preview/sea-dev-work-quiz.png` |

---

## 🧪 Perintah Pengujian & Linting Kode

```powershell
# Format kode Dart
dart format sea_app/lib

# Analisis linting Flutter (wajib 0 error/warning)
cd sea_app
flutter analyze

# Jalankan pengujian Flutter
flutter test

# Pint Linter Backend (Laravel)
cd ../backend
./vendor/bin/pint
```

---

## ❓ Troubleshooting (Penanganan Masalah)

| Masalah | Penyebab | Solusi |
|---|---|---|
| **API Connection Refused** | Server Laravel belum aktif atau port beda | Jalankan `php artisan serve --port=8000` di folder `backend`. Masuk ke menu *Setelan Koneksi API* di aplikasi Flutter untuk menyesuaikan Host/Port. |
| **Gemini API Error (500)** | `GEMINI_API_KEY` belum diisi di `.env` | Buka file `backend/.env` dan isi `GEMINI_API_KEY` dengan kunci API aktif dari Google AI Studio. |
| **SQLite Table Not Found** | Database belum dimigrasi | Jalankan `php artisan migrate:fresh --seed` pada direktori `backend`. |
| **Flutter Build Lag / Stutter** | Gradient animation interpolation | Gunakan solid color background pada `AnimatedContainer` (sudah dioptimasi pada versi 1.0.4+). |
