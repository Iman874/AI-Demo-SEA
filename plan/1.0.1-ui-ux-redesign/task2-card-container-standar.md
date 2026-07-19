# Task 2 — Standarisasi Card & Container Styling

## Deskripsi
Mengaplikasikan design token dari Task 1 ke semua komponen card dan container di `component/card/`. Standarisasi border radius, shadow, padding, dan warna.

## Tujuan Teknis
- Semua card menggunakan border radius konsisten (`radiusMd=12` atau `radiusLg=16`)
- Semua card menggunakan shadow konsisten (`shadowSm` atau `shadowMd`)
- Semua card menggunakan padding konsisten (`cardPadding=16`)
- Warna card mengikuti theme (`Theme.of(context).cardColor`)

## Scope
**Backend:** Tidak ada
**Flutter:** EDIT semua file di `component/card/` (9 file):
- `card_answer_question_student.dart`
- `card_class.dart`
- `card_conclusion_student.dart`
- `card_discussion.dart`
- `card_material.dart`
- `card_percentage_understanding.dart`
- `card_question.dart`
- `card_quiz.dart`
- `card_quiz_result.dart`

## Langkah Implementasi

### 1. Analisis setiap card
- Catat semua nilai `borderRadius`, `boxShadow`, `padding`, `margin`, `color` yang dipakai
- Catat semua `Color(0xFF...)` hardcoded

### 2. Refactor tiap card
- Ganti `borderRadius` dengan `AppDecorations.radiusMd` atau `AppDecorations.radiusLg`
- Ganti `boxShadow` dengan `AppDecorations.shadowSm` atau `AppDecorations.shadowMd`
- Ganti `color` dengan `Theme.of(context).cardColor`
- Ganti `padding` dengan `EdgeInsets.all(AppSpacing.cardPadding)`
- Ganti `margin` dengan `EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding)`
- Hapus semua `Color(0xFF...)` hardcoded

### 3. Perbaiki tipografi di dalam card
- Ganti `TextStyle(fontSize: ..., fontWeight: ...)` dengan `AppTextStyles.*`
- Hilangkan `FontWeight.w200` (terlalu tipis), ganti minimal `w400`

### 4. Format khusus per card:
- **card_class.dart**: class code pakai chip/badge, nama kelas pakai `titleMedium`
- **card_quiz.dart**: judul quiz pakai `titleMedium`, detail pakai `bodyMedium`
- **card_material.dart**: judul materi pakai `titleMedium`
- **card_discussion.dart**: judul diskusi pakai `titleMedium`
- **card_question.dart**: nomor soal pakai `bodySmall`, teks soal pakai `bodyLarge`
- **card_quiz_result.dart**: nilai pakai `heading2`, status pakai `bodyMedium`

## Output yang Diharapkan
- Semua 9 card file konsisten: radius, shadow, padding, warna
- Tipografi dalam card menggunakan AppTextStyles
- `flutter analyze` bersih

## Dependencies
Task 1 (Design Token & Theme System) harus selesai dulu

## Acceptance Criteria
- [x] border radius konsisten (hanya pakai radiusMd / radiusLg)
- [x] shadow konsisten (hanya pakai shadowSm / shadowMd)
- [x] card color dari theme (bukan hardcoded)
- [x] padding konsisten
- [x] tipografi pakai AppTextStyles
- [x] `flutter analyze` bersih

## Estimasi: 3-4 jam
