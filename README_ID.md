# 🎓 SEA App (Smart Education Assistant) — Dokumentasi Bahasa Indonesia

> **[🇬🇧 English Version](./README_EN.md)** | **[🇮🇩 Bahasa Indonesia](./README_ID.md)** | **[🛠️ Cara Menjalankan](./how_to_run.md)**

**Smart Education Assistant (SEA App)** adalah platform pembelajaran cerdas berbasis AI yang dirancang untuk mendukung proses belajar-mengajar interaktif. Aplikasi ini dibangun dengan arsitektur **Laravel 11 REST API** sebagai backend dan **Flutter 3.22+ Client** (multi-platform: Android, Windows, iOS, macOS, Web).

---

## 🌟 Highlight Fitur

| Modul | Fitur Utama | Deskripsi |
|---|---|---|
| 🔐 **Auth & Peran** | Multi-Role Interface | Sistem autentikasi token dinamis dengan pengalaman UI yang terpisah penuh antara **Guru (Biru #4B6A85)** dan **Siswa (Oranye #D97B43)**. |
| 📚 **Kelas & Materi** | Manajemen Pembelajaran | Guru dapat membuat kelas dan mengunggah materi PDF. Teks materi secara otomatis diekstrak untuk dikonsumsi oleh AI. |
| 📝 **Kuis & Evaluasi** | Kuis Interaktif & AI Generator | Guru dapat membuat kuis manual atau men-generate soal AI berbasis materi. Siswa mengerjakan kuis dengan navigasi soal instan dan indikator visual status pengerjaan. |
| 📈 **Rekap Nilai** | Analisis Performa Kelas | Dashboard rekap nilai guru menampilkan metrik rata-rata kelas, tingkat kelulusan, serta lembar jawaban detail tiap siswa via dialog `WindowViewQuestion`. |
| 💬 **Diskusi & AI** | Forum Diskusi & Ringkasan AI | Ruang diskusi kelompok dengan AI Assistant yang mampu merangkum hasil diskusi secara otomatis dan melakukan evaluasi pemahaman siswa. |
| 🛠️ **Dev Showcase** | Mode Pengembang & QA | Menu pintasan khusus pengembang untuk menguji seluruh komponen UI, pengubahan peran instan, dan showcase layar kuis tanpa hambatan auth. |

---

## 🏗️ Tech Stack & Arsitektur

### 1. Backend (Laravel 11 API)
- **Framework**: Laravel 11 (PHP 8.2+)
- **Database**: SQLite (default) / MySQL
- **Autentikasi**: Custom Bearer Token (Model `ApiToken`)
- **AI Integration**: Proxy API ke Google Gemini API (Endpoint: `/api/ask`, `/api/generate-questions`, `/api/check_understanding`)

### 2. Frontend Client (Flutter 3.22+)
- **Framework**: Flutter (Dart ^3.9.2)
- **State Management**: Provider (`ChangeNotifier`)
- **Desain & Tema**: Custom Dark & Light Theme, Dynamic Role Branding Color Palette

---

## 🌳 Pohon Struktur Halaman (Screen Tree Hierarchy)

Berikut adalah bagan struktur dan navigasi lengkap seluruh halaman aplikasi SEA App:

```
SEA App (Client Navigation Tree)
│
├── 🚀 Splash Screen (splashscreen.dart)
│
├── 🔐 Auth & Onboarding Module
│   ├── ⚙️ Pengaturan Koneksi API (connection_config_page.dart)
│   ├── 🔀 Pilihan Peran & Aksi (page_choice_user.dart)
│   ├── 🔑 Login User (page_login_user.dart)
│   ├── 📝 Registrasi Akun (page_daftar_user.dart)
│   └── 📖 Panduan Aplikasi (page_guide.dart)
│
├── 👨‍🎓 Mode Siswa (Role: Student / Theme Orange)
│   ├── 🏠 Dasbor Utama Siswa (page_menu_home_student.dart)
│   │   ├── 👥 Join Kelas & Lihat Anggota
│   │   ├── 📄 Konsumsi Teks & Modul PDF
│   │   └── 🤖 Chat Assistant & Cek Pemahaman AI
│   ├── 📝 Modul Kuis Siswa (page_menu_quiz_student.dart)
│   │   ├── ⏱️ Lembar Pengerjaan Kuis (page_menu_quiz_work_student.dart)
│   │   └── 📊 Hasil & Feedback Nilai Kuis (page_menu_quiz_result_student.dart)
│   └── 💬 Forum Diskusi Siswa (page_menu_discussion_student.dart)
│       ├── 👥 Detail Kelompok Diskusi (page_menu_discussion_detail_student.dart)
│       └── 💭 Chat Room & Ringkasan AI (page_menu_discussion_chatroom_student.dart)
│
├── 👨‍🏫 Mode Guru (Role: Teacher / Theme Blue)
│   ├── 🏠 Dasbor Utama Guru (page_menu_home_teacher.dart)
│   │   ├── ➕ Manajemen Kelas (Buat/Edit Kelas)
│   │   └── 📤 Upload & Kelola Berkas Materi PDF
│   ├── 📝 Manajemen Kuis Guru (page_menu_quiz_teacher.dart)
│   │   ├── 🛠️ Form Editor Kuis (page_menu_quiz_editor_teacher.dart)
│   │   ├── ❓ Pembuat Soal & AI Generator (page_quiz_questions_teacher.dart)
│   │   └── 📈 Rekap Nilai & Analisis Kelas (page_menu_quiz_result_teacher.dart)
│   └── 💬 Kelola Forum Guru (page_menu_discussion_teacher.dart)
│       ├── ✍️ Form Editor Kelompok (page_menu_discussion_editor_teacher.dart)
│       └── 📄 Detail Diskusi & AI Summary (page_menu_discussion_details_teacher.dart)
│
└── 🛠️ Dev Showcase Module
    ├── ⚙️ Pengaturan App & Dev Switch (page_settings.dart)
    ├── 🎨 Galeri Komponen Card UI (page_showcase_cards.dart)
    └── 🧪 Showcase Pengerjaan Kuis (page_showcase_work_quiz.dart)
```

---

## 📸 Map Berkas Preview & Screenshots

Seluruh tangkapan layar antarmuka tersimpan pada direktori:

> 🗂️ **`preview/`** (root proyek)

| Nama Halaman | Tema / Mode | Berkas Dart | Berkas Screenshot Preview |
|---|---|---|---|
| **Dasbor Utama Siswa (Terang)** | Light Mode | `page_menu_home_student.dart` | [`preview/dashboard_siswa_light.jpeg`](./preview/dashboard_siswa_light.jpeg) |
| **Dasbor Utama Siswa (Gelap)** | Dark Mode | `page_menu_home_student.dart` | [`preview/dashboard_siswa_dark.jpeg`](./preview/dashboard_siswa_dark.jpeg) |
| **Dasbor Utama Guru (Terang)** | Light Mode | `page_menu_home_teacher.dart` | [`preview/dashboard_guru_light.jpeg`](./preview/dashboard_guru_light.jpeg) |
| **Dasbor Utama Guru (Gelap)** | Dark Mode | `page_menu_home_teacher.dart` | [`preview/dashboard_guru_dark.jpeg`](./preview/dashboard_guru_dark.jpeg) |
| **Ruang Obrolan AI Siswa** | Light Mode | `page_menu_discussion_chatroom_student.dart` | [`preview/chat_room_ai_siswa_light.jpeg`](./preview/chat_room_ai_siswa_light.jpeg) |
| **Forum Diskusi Siswa** | Light Mode | `page_menu_discussion_student.dart` | [`preview/forum_diskusi_siswa_light.jpeg`](./preview/forum_diskusi_siswa_light.jpeg) |
| **Daftar Kuis Siswa** | Light Mode | `page_menu_quiz_student.dart` | [`preview/kuis_siswa_light.jpeg`](./preview/kuis_siswa_light.jpeg) |
| **Lembar Pengerjaan Kuis Siswa** | Light Mode | `page_showcase_work_quiz.dart` | [`preview/pengerjaan_kuis_siswa_light.jpeg`](./preview/pengerjaan_kuis_siswa_light.jpeg) |
| **Hasil & Evaluasi Kuis Siswa** | Light Mode | `page_menu_quiz_result_student.dart` | [`preview/hasil_kuis_siswa_light.jpeg`](./preview/hasil_kuis_siswa_light.jpeg) |
| **Manajemen Kuis Guru** | Light Mode | `page_menu_quiz_teacher.dart` | [`preview/kelola_kuis_guru_light.jpeg`](./preview/kelola_kuis_guru_light.jpeg) |
| **Rekap Nilai Guru** | Light Mode | `page_menu_quiz_result_teacher.dart` | [`preview/rekap_nilai_kuis_guru_light.jpeg`](./preview/rekap_nilai_kuis_guru_light.jpeg) |
| **Panduan Penggunaan** | Light Mode | `page_guide.dart` | [`preview/panduan_penggunaan_light.jpeg`](./preview/panduan_penggunaan_light.jpeg) |

---

## ⚡ Langkah Singkat Menjalankan Aplikasi

```powershell
# 1. Jalankan Backend API
cd backend
composer install
php artisan migrate --seed
php artisan serve --port=8000

# 2. Jalankan Application Client
cd ../sea_app
flutter pub get
flutter run -d windows
```

> 📖 Untuk informasi lebih rinci, silakan lihat [`how_to_run.md`](./how_to_run.md).
