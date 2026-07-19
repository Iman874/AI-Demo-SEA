# Task 7 — Visual Polish & Version Bump

## Deskripsi
Sentuhan akhir: perbaikan spacing minor, transisi halaman, update version, dan validasi akhir.

## Tujuan Teknis
- Memastikan semua halaman terlihat proporsional
- Menambah transisi halaman yang smooth
- Update version di pubspec.yaml ke 1.0.1
- Final `flutter analyze` dan regression check

## Scope
**Backend:** Tidak ada
**Flutter:**
- EDIT: `pubspec.yaml` (version)
- EDIT: `main.dart` (route transitions)
- EDIT: semua file yang masih ada issue spacing minor
- Validasi: `flutter analyze`

## Langkah Implementasi

### 1. Version Bump
- `pubspec.yaml`: `version: 1.0.0+1` → `version: 1.0.1+2`

### 2. Page Route Transitions
Di `main.dart` atau tiap navigasi:
- Tambah `PageRouteBuilder` dengan `FadeTransition` atau `SlideTransition`
- Durasi 300ms, `Curves.easeOutCubic`
- Inspirasi dari MyWallet: FadeTransition untuk splash ke home

### 3. Spacing & Alignment Pass
Lakukan pass cepat ke semua halaman:
- Pastikan `SizedBox` heights konsisten (prefer AppSpacing values)
- Pastikan alignment konsisten (CrossAxisAlignment.start untuk konten, center untuk judul)
- Pastikan tidak ada overflow atau layout break

### 4. Verify Dark Mode
Test manual:
- Set sistem ke dark mode
- Navigasi ke semua halaman
- Pastikan semua teks terbaca, kontras cukup

### 5. Final Validation
- Jalankan `flutter analyze` — pastikan 0 error, 0 warning
- Catat hasil di laporan

## Output yang Diharapkan
- Version 1.0.1
- Route transitions yang smooth
- Spacing final yang rapi
- `flutter analyze` bersih
- Laporan final validasi

## Dependencies
Semua task sebelumnya (1-6)

## Acceptance Criteria
- [x] Version di pubspec.yaml = 1.0.1
- [x] Route transitions smooth
- [x] Tidak ada overflow/layout break
- [x] `flutter analyze` 0 error, 0 warning
- [x] Semua acceptance criteria dari task 1-6 terpenuhi

## Estimasi: 2-3 jam
