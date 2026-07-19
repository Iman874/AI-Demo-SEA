# SEA App — Agent Guide

Aplikasi **Smart Education Assistant** — Sistem pembelajaran cerdas berbasis AI untuk membantu proses belajar mengajar. Terdiri dari **Laravel 11 API** (backend) dan **Flutter client** (mobile/desktop).

## Memory proyek (`.memori.txt`)

Project ini punya **persistent project memory** di file `.memori.txt` (root project) agar AI tetap paham konteks lintas sesi.

- **Sebelum kerja apa pun**: cari `.memori.txt` di root. Jika ada, **cari entry yang relevan dengan konteks kerja saat ini**; jadikan konteks utama. Jika tidak ada, beritahu user dan tawarkan membuat file baru.
- **Kapan update**: saat ada info penting — bug ditemukan/diperbaiki, perubahan arsitektur/struktur folder/fitur/dependency/framework/config, keputusan desain, atau catatan teknis berguna. Jangan catat hal sepele (typo, format).
- **Format**: untuk info **baru**, tambahkan catatan **paling atas** (newest first). Untuk info yang **sudah ada** di entry tertentu, **edit langsung entry tersebut di tempatnya** — jangan pindahkan ke atas.
  ```
  ==================================================
  Tanggal : YYYY-MM-DD
  Waktu   : HH:mm
  Kategori: <Bug | Feature | Refactor | Config | Decision | Architecture | Note>

  Judul:
  Ringkasan singkat.

  Detail:
  - ...
  - ...

  Dampak:
  - ...
  ==================================================
  ```
- **Aturan penulisan**: jangan hapus history lama; jangan ubah catatan lama kecuali salah; pakai bahasa singkat & jelas; fokus info teknis. Jika mengupdate memori yang relevan dengan pekerjaan agent lain, edit entry-nya di tempat.
- **Maintenance**: bila file > ±1000 baris / ±100 KB, buat bagian "Ringkasan Project" — gabungkan info lama, pertahankan keputusan/bug/arsitektur penting.
- **Sebelum akhiri kerja**: cek apakah ada info layak disimpan; jika ada, update `.memori.txt`; jika tidak ada info penting, jangan ubah file.

## Bahasa (language)

- **WAJIB**: Selalu gunakan **Bahasa Indonesia** untuk seluruh komunikasi — baik chat/balasan ke user maupun semua dokumen plan, catatan, dan commit message. Jangan menulis penjelasan atau dokumen planning dalam Bahasa Inggris kecuali user yang minta.

## Project info

| Item | Detail |
|---|---|
| Nama Aplikasi | SEA App (Smart Education Assistant) / Flow App |
| Platform | Android, iOS, Windows, Linux, macOS, Web (Flutter) |
| Backend | Laravel 11 (PHP 8.2+) — REST API |
| Client | Flutter 3.22+ (Dart ^3.9.2) — Provider state management |
| AI Integration | Google Gemini API (via proxy endpoint) |
| Database | SQLite (default) / MySQL |
| Auth | Custom token-based (ApiToken model, Bearer header) |
| Status | MVP selesai (September 2025) — Aktif, maintenance |

## Struktur proyek

```
AI-Demo-SEA/
├── backend/              # Laravel 11 API
│   ├── app/
│   │   ├── Http/Controllers/   # API Controllers
│   │   ├── Models/             # Eloquent Models
│   │   └── Providers/
│   ├── config/                 # Laravel config
│   ├── database/
│   │   ├── migrations/         # 30 migration files
│   │   └── seeders/            # Demo data seeder
│   ├── routes/
│   │   └── web.php             # Semua API routes (82 endpoint)
│   └── tests/
│
└── sea_app/              # Flutter Client
    ├── lib/
    │   ├── main.dart
    │   ├── component/          # Reusable widgets (card, nav, window)
    │   ├── controller/         # AI message controller
    │   ├── models/             # Data models
    │   ├── pages/              # Screens (student, teacher)
    │   ├── providers/          # State management (ChangeNotifier)
    │   ├── services/           # API service
    │   ├── theme/              # Dark & light theme
    │   └── utils/              # Helpers (PDF, logger, dll)
    ├── assets/
    └── test/
```

## Fitur & modul

### Backend (Laravel) — API Endpoints

| Modul | Endpoints | Deskripsi |
|---|---|---|
| Auth | `/api/register`, `/api/login`, `/api/user` | Registrasi, login, profil |
| Kelas | `/api/classes`, `/api/join-class`, `/api/my-classes`, `/api/class-members` | CRUD kelas, enrollment |
| Materi | `/api/materials` | Upload & daftar materi |
| Quiz | `/api/quizzes`, `/api/quiz-questions`, `/api/result-quiz` | CRUD quiz, ambil quiz, hasil |
| Diskusi | `/api/discussions/*`, `/api/discussion/messages`, `/api/discussion/summaries` | Chat room, grup, ringkasan AI |
| AI/Gemini | `/api/ask`, `/api/student/chat`, `/api/check_understanding`, `/api/generate-questions`, `/api/generate-groups` | Proxy AI, cek pemahaman, generate soal/kelompok |

### Flutter Client

| Fitur | Detail |
|---|---|
| Auth | Login, register, token persistence |
| Role-based UI | Teacher (blue #4B6A85) / Student (orange #D97B43) |
| Kelas | Buat/gabung kelas, lihat anggota |
| Quiz | Buat quiz (guru), kerjakan quiz (murid), hasil, generate soal AI |
| Diskusi | Chat room dengan AI, grup diskusi, ringkasan AI, cek pemahaman |
| Materi | Upload materi, ekstrak teks PDF |
| AI Chat | Chat dengan konteks materi, evaluasi pemahaman |
| Tema | Dark & light mode (ikut sistem) |
| Konfigurasi | Dynamic API host/port/scheme |

## Acceptance criteria (ringkasan)

- Auth flow lengkap (register → login → token → protected routes)
- Role-based UI: guru bisa CRUD kelas/quiz, murid bisa join & mengerjakan
- Quiz: guru buat soal → ditugaskan ke kelas → murid kerjakan → lihat hasil
- Diskusi: grup diskusi dengan AI assistant, ringkasan otomatis, cek pemahaman
- AI Chat: murid bisa bertanya dengan konteks materi
- Dark/light theme stabil, mengikuti sistem
- Konfigurasi koneksi API bisa diubah runtime
- Empty state, error state, loading state di semua halaman

## Kebutuhan teknis

- **Backend**: PHP 8.2+, Composer, jalankan `php artisan serve --port=8000`
- **Flutter**: Flutter SDK 3.22+, jalankan `flutter run -d windows`
- **Database**: SQLite default — `php artisan migrate --seed` untuk setup demo
- **AI**: Set `GEMINI_API_KEY` di `.env` backend
- **Linting backend**: `./vendor/bin/pint`
- **Linting flutter**: `flutter analyze`
- **Test backend**: `vendor/bin/phpunit`
- **Test flutter**: `flutter test`
- **Seeder idempoten**: semua seeder pakai `firstOrCreate`, aman di-run ulang
- **Auth**: Bearer token via header `Authorization`, model `ApiToken`
- **API service**: Semua panggilan HTTP Flutter via `ApiService` static methods

## Workflow: perubahan (bug fix / fitur baru)

Untuk setiap perubahan non-trivial (fitur baru, perbaikan bug, refactor), ikuti planning workflow di bawah ini.

### 1. Plan & analisis
- Pahami scope — tentukan apakah perubahan di **backend (Laravel)**, **client (Flutter)**, atau **keduanya**.
- Identifikasi layering:
  - **Backend**: Route → Controller → Model → Database (Migration/Seeder)
  - **Flutter**: Page/Widget → Provider → Service (ApiService) → Backend API
- Buat folder per task di `plan/` dengan format: `<tanggal>-<nama-modul>/`.
- Di dalamnya buat:
  - **Plan design**: Latar Belakang, Tujuan, Scope, Breakdown Task, Design Teknis (file terdampak, flow, skema API), Dampak ke Sistem, Definition of Done.
  - **Task file**: 1 task = 1 hasil jelas.

### 2. Eksekusi
- Kerjakan task berurutan sesuai dependency.
- **Backend**: buat migration → model → controller → route → test.
- **Flutter**: buat model → service → provider → page/widget.
- Pastikan empty state, error state, dan loading state terhandle.

### 3. Verifikasi wajib (setiap task)
- **Backend**: `./vendor/bin/pint` (atau `composer lint`) — pastikan tidak ada error baru.
- **Flutter**: `flutter analyze` — pastikan tidak ada error/warning baru.
- **Test**: `vendor/bin/phpunit` (backend), `flutter test` (flutter).
- **Regression check**: pastikan fitur lain tidak rusak.

### 4. Setelah implementasi
- Update `.memori.txt` bila ada info penting.
- Pastikan `composer.json` / `pubspec.yaml` tidak corrupted.

### Definition of Done
- Kode sesuai scope plan.
- Linting bersih (backend + Flutter).
- Semua acceptance criteria terpenuhi.
- Empty/error/loading state terhandle.
- Tidak ada perubahan liar di luar scope.

## Workflow debugging & standar pelaporan

### 1. Identifikasi area
Tentukan apakah bug di backend (API response salah, query error) atau Flutter (UI, state, network).

### 2. Prosedur analisis error
- **Backend**: cek log di `backend/storage/logs/laravel.log`, cek response API via Postman/browser.
- **Flutter**: cek `flutter analyze`, minta screenshot atau console log dari user.
- **Database**: cek migration, pastikan seeder berjalan benar.
- **AI**: cek `GEMINI_API_KEY` di `.env`, cek response endpoint `/api/echo`.

### 3. Setelah perubahan
Validasi minimal: linting bersih, test relevan, pastikan tidak ada compile error, warning baru, dan perubahan tidak merusak fitur lain.

### 4. Git
- Commit message format (Bahasa Indonesia):
  - Perbaikan bug: `fix bug <judul>: <deskripsi>`
  - Penambahan fitur: `add feature <nama>: <deskripsi>`
  - Perubahan backend: `fix backend <judul>: <deskripsi>`
  - Perubahan flutter: `fix flutter <judul>: <deskripsi>`
- Jangan commit/push tanpa izin user.

### 5. Format laporan (wajib setiap selesai kerja)
- **Ringkasan**: masalah + solusi.
- **Yang Saya Lakukan**: daftar tindakan (analisis, lint, test, fix, refactor, dll).
- **Hasil Validasi**: linting bersih / ada error tertentu / tidak dapat verifikasi runtime.
- **File yang Diubah**: path, jenis perubahan, alasan, nomor baris, ringkasan.
- **Dampak Perubahan**: fitur terdampak, efek samping, risiko regresi.
- **Hal yang Perlu Diverifikasi User**: daftar uji manual.
- **Kendala**: keterbatasan yang dihadapi.

### 6. Prinsip kerja
- Jangan nebak penyebab bug; pakai bukti (log, stack trace, hasil analyze, hasil test).
- Jelaskan alasan tiap perubahan. Utamakan perubahan sekecil mungkin.
- Jika ada >1 solusi, jelaskan kelebihan/kekurangan masing-masing.
- Laporkan semua tindakan secara transparan. Jangan klaim selesai sebelum ada bukti.

### 7. Area spesifik
- **Perubahan database**: selalu buat migration baru, jangan edit migration yang sudah di-commit.
- **Perubahan API**: pastikan backward-compatible atau koordinasi dengan Flutter client.
- **Perubahan model Flutter**: sesuaikan dengan response API terbaru.
- **AI prompt**: perubahan prompt Gemini harus diuji dengan berbagai input.

## git

- Project menggunakan **satu repository git** di root `AI-Demo-SEA/`.
- JANGAN commit/push/buat branch tanpa izin user.
- Format commit message (Bahasa Indonesia):
  - Perbaikan bug: `fix bug <judul-bug>: <deskripsi>`
  - Penambahan fitur: `add feature <nama-fitur>: <deskripsi>`
  - Backend: `fix backend <judul>: <deskripsi>` / `add backend <fitur>: <deskripsi>`
  - Flutter: `fix flutter <judul>: <deskripsi>` / `add flutter <fitur>: <deskripsi>`
- Selalu cek `git status` sebelum dan sesudah bekerja.

## Prinsip kejujuran & delegasi

### Kejujuran
- **CRITICAL**: Selalu jujur kepada user, termasuk saat kabar buruk. Jika tidak paham logika tertentu, tidak mampu menangani sebuah bug, atau tidak yakin dengan solusi — katakan secara jujur, jangan berpura-pura selesai.
- Jangan klaim bug sudah diperbaiki / fitur sudah jadi tanpa bukti (hasil analyze, hasil test).
- Jika butuh informasi dari user (screenshot, console, akses device), minta dengan jelas.

### Delegasi & penghematan token
- Jika user meminta untuk memahami konteks (eksplorasi codebase, riset, analisis), manfaatkan sub-agent / multi-agent yang tersedia.
- Serahkan pengumpulan konteks berat ke agent terpisah, lalu gunakan hasil ringkasnya.

## following instructions

- **CRITICAL**: Nurut arahan user. JANGAN cari alternatif atau buat asumsi sendiri kecuali user yang suruh.
- Kalau user bilang lakukan A, lakukan A. Jangan coba-coba pendekatan B, C, D sendiri.
- Kalau user sudah jelas bilang apa yang mereka mau, langsung implement. Jangan sok pinter cari cara lain.
