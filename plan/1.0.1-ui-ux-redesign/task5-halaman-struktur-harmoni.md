# Task 5 — Harmonisasi Struktur Halaman

## Deskripsi
Menyeragamkan struktur halaman di seluruh aplikasi: header, body layout, dan bottom navigation bar. Menggunakan komponen `TopHeader` dan `BottomNavigation` secara konsisten.

## Tujuan Teknis
- Semua halaman utama menggunakan `TopHeader` (bukan custom header/AppBar)
- Semua halaman menggunakan padding horizontal konsisten
- Bottom navigation bar menggunakan tema (bukan warna hardcoded)
- Struktur layout seragam: `SafeArea > Scaffold > Column > [Header, Expanded(body), Nav]`

## Scope
**Backend:** Tidak ada
**Flutter:** EDIT:
- `component/header/top.dart`
- `component/nav/bottom_navigation.dart`
- `pages/student/*` (7 file)
- `pages/teacher/*` (7 file)
- `pages/student_home.dart`, `pages/teacher_home.dart`
- `pages/splashscreen.dart`

## Langkah Implementasi

### 1. Refactor `component/header/top.dart`
- Gunakan AppColors, AppTextStyles, AppSpacing, AppDecorations
- Pastikan warna header mengikuti role (teacher biru / student oranye)
- Gradient opsional (referensi MyWallet)

### 2. Refactor `component/nav/bottom_navigation.dart`
- Ganti warna hardcoded `#1B3C53` dan `#819DB1` → AppColors atau colorScheme
- Gunakan `Theme.of(context).colorScheme` untuk active/inactive color
- Floating style (seperti MyWallet glassmorphism) jika feasible

### 3. Update Student Pages
Untuk setiap file di `pages/student/`:
- Ganti custom header/AppBar dengan `TopHeader`
- Standarisasi padding: `EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding)`
- Struktur: `SafeArea > Scaffold > Column > [TopHeader, Expanded(body)]`

### 4. Update Teacher Pages
Sama seperti student pages:
- Ganti custom header/AppBar dengan `TopHeader`
- Standarisasi padding horizontal

### 5. Standarisasi Layout Pattern
Buat helper method atau ekstrak pattern umum:
```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        TopHeader(title: '...', role: ...),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
              vertical: AppSpacing.md,
            ),
            child: ...,
          ),
        ),
        BottomNavigation(),
      ],
    ),
  ),
)
```

### 6. Quiz Pages Khusus
`page_menu_quiz_work_student.dart` dan `page_menu_quiz_result_student.dart`:
- Header oranye custom → ganti dengan `TopHeader`
- Warna `Color(0xFFDD6A2B)` → `AppColors.studentAccent`

## Output yang Diharapkan
- Semua halaman utama menggunakan `TopHeader`
- Bottom navigation bar menggunakan theme colors
- Padding horizontal konsisten di semua halaman
- `flutter analyze` bersih

## Dependencies
Task 1 (Design Token), Task 2 (Card/Container), Task 3 (Button/Input)

## Acceptance Criteria
- [x] Semua halaman student pakai TopHeader
- [x] Semua halaman teacher pakai TopHeader
- [x] Bottom nav menggunakan theme colors
- [x] Padding horizontal konsisten (AppSpacing.horizontalPadding)
- [x] Layout structure seragam
- [x] `flutter analyze` bersih

## Estimasi: 4-5 jam
