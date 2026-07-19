# Task 3 — Standarisasi Tombol & Input Field

## Deskripsi
Mengaplikasikan design token ke semua tombol dan input field di aplikasi. Standarisasi warna, border radius, padding, dan typography.

## Tujuan Teknis
- Warna tombol mengikuti `colorScheme` (bukan warna random)
- Border radius tombol konsisten (`radiusSm=8`)
- Input field border radius konsisten (`radiusSm=8`)
- Typography tombol dan label konsisten

## Scope
**Backend:** Tidak ada
**Flutter:** EDIT semua file di `component/window/` (8 file) dan beberapa halaman:
- `component/window/window_add_class.dart`
- `component/window/window_add_material.dart`
- `component/window/window_add_question.dart`
- `component/window/window_add_summary.dart`
- `component/window/window_confirmation.dart`
- `component/window/window_edit_question.dart`
- `component/window/window_join_class.dart`
- `component/window/window_message.dart`
- `pages/page_login_user.dart`
- `pages/page_daftar_user.dart`
- `pages/connection_config_page.dart`

## Langkah Implementasi

### 1. Standarisasi Button Theme di ThemeData
Di Task 1 sudah diset di theme files. Pastikan:
- `ElevatedButtonTheme`: bg `primary`, fg `white`, radius `radiusSm`, padding `horizontal 24 vertical 14`
- `OutlinedButtonTheme`: border `primary`, fg `primary`, radius `radiusSm`
- `TextButtonTheme`: fg `primary`
- Warna destructive: gunakan `colorScheme.error`

### 2. Ganti semua ElevatedButton di window files
Cari pola:
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF...),  // GANTI
  ),
)
```
- Ganti `backgroundColor` dengan theme color
- Hapus `style:` override jika sudah sesuai theme default
- Untuk destructive action → `backgroundColor: colorScheme.error`
- Untuk cancel → `OutlinedButton`

### 3. Standarisasi Input Field
- `InputDecoration` dengan `OutlineInputBorder`, `borderRadius: radiusSm`
- `contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)`
- `fillColor` dari theme surface
- Label style dari `AppTextStyles.labelMedium`

### 4. Standarisasi Dialog (Window files)
- Border radius dialog: `radiusLg=16`
- Padding dialog: `AppSpacing.cardPadding`
- Title style: `AppTextStyles.titleLarge`
- Content style: `AppTextStyles.bodyMedium`
- Action buttons: full-width, `primary` utk konfirmasi, `error` utk destructive, `outlined` utk cancel

## Output yang Diharapkan
- Semua tombol di window dan halaman auth menggunakan theme colors
- Semua input field menggunakan theme styling
- Dialog styles konsisten
- `flutter analyze` bersih

## Dependencies
Task 1 (Design Token & Theme System)

## Acceptance Criteria
- [x] Tidak ada tombol dengan warna hardcoded (kecuali theme override yg legitimate)
- [x] Tombol destructive pakai error color
- [x] Cancel action pakai OutlinedButton
- [x] Input field border radius konsisten
- [x] Dialog padding dan radius konsisten
- [x] `flutter analyze` bersih

## Estimasi: 2-3 jam
