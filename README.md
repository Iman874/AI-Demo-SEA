# 🇮🇩 **Flow App — ai-demo-SEA**

**Flow App — ai-demo-SEA** adalah demo multi-bagian untuk **Student Engagement Assistant (SEA)** yang menampilkan alur pembelajaran berbasis AI.
Sistem ini terdiri dari:

* **backend/** — API Laravel 11 (MySQL/SQLite) + Gemini proxy
* **sea_app/** — Aplikasi Flutter (mobile/desktop) yang berkomunikasi dengan backend

Repositori ini dibuat dengan desain **local-first** dan kontrak HTTP yang stabil antar-komponen.

---

# 🗂️ Daftar Isi

* [Penjelasan Singkat](#penjelasan-singkat)
* [Fitur Utama](#fitur-utama)
* [Arsitektur](#arsitektur)
* [Kontrak API Stabil](#kontrak-api-stabil)
* [Persyaratan Sistem](#persyaratan-sistem)
* [Langkah Instalasi Cepat](#langkah-instalasi-cepat)
* [Data Seeder](#data-seeder)
* [Alur Pengembangan](#alur-pengembangan)
* [Attribution](#attribution)

---

<a name="penjelasan-singkat"></a>

## 🧾 Penjelasan Singkat

SEA dirancang sebagai asisten pembelajaran pintar yang mendukung diskusi kelas, kuis, materi ajar, serta interaksi AI dengan siswa dan guru.

Struktur utama:

* **Backend Laravel** → Menyediakan semua endpoint: auth, kelas, materi, kuis, diskusi, dan AI helper
* **Flutter Client** → Antarmuka utama untuk demo SEA
* **Web Frontend** → Starter ringan berbasis React + Vite

Semua klien menggunakan **REST API yang sama**.

---

<a name="fitur-utama"></a>

## 🚀 Fitur Utama

* 🔐 **Autentikasi**

  * Register, login, mendapatkan profil user
* 📘 **Manajemen Kelas**

  * Membuat/bergabung kelas
  * Melihat anggota kelas
* 📚 **Materi Pembelajaran**

  * Upload, list, konsumsi materi
* 📝 **Kuis & Penilaian**

  * Pembuatan kuis
  * Menjawab kuis
  * Mengambil hasil kuis
* 💬 **Diskusi & Ringkasan AI**

  * Chat room diskusi
  * Generasi ringkasan diskusi oleh AI
  * Hapus pesan diskusi
* 🤖 **Fitur AI**

  * Student AI chat
  * Check understanding
  * Generate question & group

---

<a name="arsitektur"></a>

## 🏗️ Arsitektur

### 📌 Backend (Laravel 11)

* REST endpoint untuk:

  * Auth
  * Classes & members
  * Materials
  * Quizzes
  * Discussion
  * AI Helpers (Gemini proxy)
* Menggunakan **SQLite** untuk kemudahan setup

### 📱 Flutter Client

* Aplikasi demo utama (mobile & desktop)
* Menggunakan API yang sama dengan web
* File penting:

  * `sea_app/lib/config/api.dart`
  * `sea_app/lib/utils/send_message.dart`

### 🌐 Web Frontend

* Starter ringan (React + Vite)
* Dipakai untuk percobaan API cepat

---

<a name="kontrak-api-stabil"></a>

## 🔗 Kontrak API Stabil

### AI Core

* `POST /api/ask`
* `POST /api/echo`

### Student AI

* `POST /api/student/chat` → `{ answer }`
* `POST /api/student/check_understanding` → `{ result }`

### AI Helpers

* `POST /api/generate-questions`
* `POST /api/generate-groups`

### Discussion

* `GET /api/discussion/messages?chatroom_id=...`
* `GET /api/discussion/summaries?chatroom_id=...`
* `POST /api/discussion/submit_summary`
* `POST /api/discussion/delete_all_messages`

### Auth

* `POST /api/register`
* `POST /api/login`
* `GET /api/user`

### Classes

* `GET/POST /api/classes`
* `POST /api/join-class`
* `GET /api/my-classes`
* `GET /api/user-class-ids`
* `GET /api/class-members?class_id=...`

### Materials

* `GET/POST /api/materials`

### Quizzes

* `GET/POST /api/quizzes`
* `POST /api/quizzes/save`
* `GET /api/quiz-questions`
* `POST/GET /api/result-quiz`

> Semua route API **skip CSRF** via `withoutMiddleware(VerifyCsrfToken::class)`.

---

<a name="persyaratan-sistem"></a>

## 🧰 Persyaratan Sistem

* Windows 10/11 / macOS / Linux
* PHP 8.2+, Composer
* Flutter 3.22+

---

<a name="langkah-instalasi-cepat"></a>

## ⚡ Langkah Instalasi Cepat (Windows PowerShell)

### 1️⃣ Setup Backend (Laravel)

* Copy `.env.example` → `.env`
* Isi `GEMINI_API_KEY` (opsional)
* Pastikan file SQLite tersedia:
  `backend/database/database.sqlite`
* Instal dependensi & migrasi:

```bash
cd backend
composer install
php artisan migrate --seed
php artisan serve --port=8000
```

---

### 2️⃣ Setup Flutter App

```bash
cd sea_app
flutter pub get
flutter run -d windows
```

Default API base:
`http://127.0.0.1:8000`

Jika pakai emulator Android → ganti ke `10.0.2.2`.

---

<a name="data-seeder"></a>

## 🌱 Data Seeder (Demo)

Seeder berisi:

* **Quiz 1** → 2 materi, 30 soal MCQ (4 opsi), hasil simulasi untuk seluruh siswa
* **Diskusi1** → 10 grup (3 siswa + 1 guru tiap grup), lengkap dengan chatroom AI

Seeder dapat dijalankan dari folder `backend/`.

---

<a name="alur-pengembangan"></a>

## 🔧 Alur Pengembangan

* Jaga kestabilan bentuk respons & endpoint
* Gunakan seeder idempotent (`firstOrCreate`)
* Jangan commit secret (gunakan `GEMINI_API_KEY`)
* Backend & Flutter harus sinkron host-port API

---

<a name="attribution"></a>

## 📝 Attribution

* Flow App — ai-demo-SEA
* Developed by: **Rosul Iman**
* Advisor: **Prof. Dr. Muhammad Anwar, S.Pd., M.T.**

---

---

# 🇬🇧 **Flow App — ai-demo-SEA (English Version)**

A multi-part demonstration project for the **Student Engagement Assistant (SEA)**, showcasing an AI-powered learning workflow across:

* **backend/** — Laravel 11 API (MySQL/SQLite) + Gemini proxy
* **sea_app/** — Flutter client for desktop/mobile

Designed for **local-first development** with stable HTTP contracts across components.

---

## 🗂️ Table of Contents

* [Overview](#overview)
* [Key Features](#key-features)
* [Architecture](#architecture-en)
* [Stable API Contracts](#api-contracts)
* [Prerequisites](#prerequisites)
* [Quick Start](#quick-start)
* [Demo Seed Data](#seed-data)
* [Development Workflow](#dev-workflow)
* [Attribution](#attribution-en)

---

<a name="overview"></a>

## 🧾 Overview

SEA acts as an intelligent learning assistant supporting:

* class management
* materials
* quizzes
* discussions
* AI helpers for students and teachers

Both Flutter and web clients consume the **same REST API**.

---

<a name="key-features"></a>

## 🚀 Key Features

* **Authentication** (register, login, user profile)
* **Classes** (create, join, list members)
* **Materials** (upload & fetch)
* **Quizzes** (create, answer, fetch results)
* **Discussions** (chat rooms, AI summaries)
* **AI Features**:

  * Student AI chat
  * Understanding checker
  * Question generator
  * Group generator

---

<a name="architecture-en"></a>

## 🏗️ Architecture

### Backend (Laravel 11)

* Provides full REST API
* Uses SQLite for ease of setup

### Flutter Client

* Primary demo app (mobile & desktop)
* Uses:

  * `sea_app/lib/config/api.dart`
  * `sea_app/lib/utils/send_message.dart`

### Web Frontend

* Minimal React + Vite starter
* Useful for rapid API experimentation

---

<a name="api-contracts"></a>

## 🔗 Stable API Contracts

(Identical to Indonesian version — kept consistent for development)

---

<a name="prerequisites"></a>

## 🧰 Prerequisites

* Windows/macOS/Linux
* PHP 8.2+, Composer
* Flutter 3.22+

---

<a name="quick-start"></a>

## ⚡ Quick Start

### Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan migrate --seed
php artisan serve --port=8000
```

### Flutter

```bash
cd sea_app
flutter pub get
flutter run -d windows
```

Default API: `http://127.0.0.1:8000`

---

<a name="seed-data"></a>

## 🌱 Demo Seed Data

Includes:

* Quiz1 (2 materials, 30 MCQs)
* Discussion1 with 10 groups and AI chatrooms

---

<a name="dev-workflow"></a>

## 🔧 Development Workflow

* Keep endpoints stable
* Use idempotent seeders
* Never commit API keys
* Sync host/port between backend and Flutter

---

<a name="attribution-en"></a>

## 📝 Attribution

* Flow App — ai-demo-SEA
* Developed by **Rosul Iman**
* Advisor: **Prof. Dr. Muhammad Anwar, S.Pd., M.T.**
