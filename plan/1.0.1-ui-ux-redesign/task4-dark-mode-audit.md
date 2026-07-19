# Task 4 — Perbaikan Dark Mode

## Deskripsi
Audit seluruh kode Flutter untuk menemukan dan memperbaiki warna-warna terang yang di-hardcode sehingga dark mode berfungsi penuh.

## Tujuan Teknis
Tidak ada `Colors.white`, `Colors.black`, `Colors.grey.shade*`, atau `Color(0xFF...)` yang bersifat light-mode-only tanpa penanganan dark mode.

## Scope
**Backend:** Tidak ada
**Flutter:** Semua file .dart di lib/ — terutama:
- `component/card/*` (9 file)
- `component/window/*` (8 file)
- `component/header/top.dart`
- `component/nav/bottom_navigation.dart`
- `pages/page_guide.dart`
- `pages/student/*` (7 file)
- `pages/teacher/*` (7 file)
- `pages/page_*.dart` (7 file)

## Langkah Implementasi

### 1. Audit hardcoded colors
Cari pola berbahaya di semua file:
- `Colors.white` / `Colors.black`
- `Colors.grey.shade*` (terang seperti shade100, shade200)
- `Color(0xFF...)` — terutama warna terang
- `const TextStyle(color: ...)` — warna tidak dinamis
- `decoration: BoxDecoration(color: ...)` — warna hardcoded

### 2. Perbaiki tiap pola
- `Colors.white` → `Theme.of(context).colorScheme.surface`
- `Colors.black` → `Theme.of(context).colorScheme.onSurface`
- `Colors.grey.shade100` → `Theme.of(context).colorScheme.surfaceVariant` atau custom
- `Colors.grey.shade200` → `Theme.of(context).dividerColor`
- `Color(0xFFF3F3F3)` → `AppColors.forBrightness(context).background`
- `TextStyle(color: Colors.black)` → `TextStyle(color: Theme.of(context).colorScheme.onSurface)`

### 3. Perbaikan spesifik per file

#### `page_guide.dart`
- `dropdownColor: Colors.white` → `dropdownColor: Theme.of(context).cardColor`
- `style: TextStyle(color: Colors.black)` → gunakan `AppTextStyles.bodyMedium(context)`

#### `page_menu_discussion_chatroom_student.dart`
- `color: Colors.grey.shade100` → `color: Theme.of(context).colorScheme.surfaceVariant`
- `color: Colors.white` → `color: Theme.of(context).cardColor`

#### `page_menu_discussion_detail_student.dart`
- `color: Colors.blue.shade50` → hapus atau ganti warna tema

#### `page_menu_quiz_work_student.dart`
- `Color(0xFFDD6A2B)` → `AppColors.studentAccent`

#### Lain-lain
- Semua `Color(0xFF...)` yang bukan bagian dari design token → ganti dengan AppColors

### 4. Verifikasi
Buat function helper untuk testing: light mode tetap terlihat baik, dark mode juga terbaca jelas

## Output yang Diharapkan
- Dark mode berfungsi di semua halaman
- Tidak ada teks putih di background putih atau sebaliknya
- `flutter analyze` bersih

## Dependencies
Task 1 (Design Token)

## Acceptance Criteria
- [x] Tidak ada `Colors.white`/`Colors.black` langsung di widget (kecuali legitimate seperti splash)
- [x] Tidak ada `Colors.grey.shade*` tanpa theme
- [x] Semua `Color(0xFF...)` sudah diganti dengan AppColors atau Theme
- [x] Dark mode kontras terbaca di semua halaman
- [x] `flutter analyze` bersih

## Estimasi: 3-4 jam
