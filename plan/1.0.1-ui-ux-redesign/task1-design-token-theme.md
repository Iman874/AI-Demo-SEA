# Task 1 — Design Token & Theme System

## Deskripsi
Membuat design token (warna, tipografi, spacing, radius, shadow) dalam file terpisah, lalu refactor `light_theme.dart` dan `dark_theme.dart` untuk menggunakannya secara konsisten.

## Tujuan Teknis
- Pisahkan semua nilai desain ke constants files
- Gunakan `ColorScheme.fromSeed` atau palet manual untuk warna
- Gunakan `Google Fonts Poppins` untuk seluruh tipografi
- Gunakan `TextTheme` dengan gaya yang terstandarisasi

## Scope
**Backend:** Tidak ada perubahan
**Flutter:**
- BUAT file baru: `theme/app_colors.dart`, `theme/app_text_styles.dart`, `theme/app_spacing.dart`, `theme/app_decorations.dart`
- EDIT: `theme/light_theme.dart`, `theme/dark_theme.dart`
- EDIT: `main.dart` (update provider setup jika perlu)
- EDIT: `pubspec.yaml` (tambah `google_fonts`)

## Langkah Implementasi

### 1. Buat `theme/app_colors.dart`
- Definisikan `class AppColors` dengan static const color palette:
  - `primary` (#3B82F6), `primaryLight`, `primaryDark`
  - `secondary` (#D97B43), `secondaryLight`, `secondaryDark`
  - `success` (#22C55E), `error` (#EF4444), `warning` (#F59E0B)
  - `background` (light/dark), `surface` (light/dark), `border` (light/dark)
  - `textPrimary` (light/dark), `textSecondary` (light/dark)
  - `teacherAccent` (#4B6A85), `studentAccent` (#D97B43)
- Buat method `forBrightness(Brightness)` yang return warna sesuai mode
- Hapus semua `Color(0xFF...)` dari theme files nantinya

### 2. Buat `theme/app_text_styles.dart`
- Definisikan `class AppTextStyles` dengan static methods:
  - `heading1`, `heading2`, `heading3`, `heading4`
  - `bodyLarge`, `bodyMedium`, `bodySmall`
  - `labelLarge`, `labelMedium`, `labelSmall`
- Semua menggunakan `GoogleFonts.poppins()`
- Setiap style punya method `*Context(BuildContext)` untuk warna dinamis

### 3. Buat `theme/app_spacing.dart`
- Definisikan `class AppSpacing` dengan static const:
  - `xs` = 4, `sm` = 8, `md` = 12, `lg` = 16, `xl` = 20, `xxl` = 24, `xxxl` = 32, `huge` = 48
  - `horizontalPadding` = 20.0
  - `sectionSpacing` = 24.0
  - `cardPadding` = 16.0
  - `safeAreaBottom` = 100.0

### 4. Buat `theme/app_decorations.dart`
- Definisikan `class AppDecorations` dengan static:
  - `radiusSm` = 8, `radiusMd` = 12, `radiusLg` = 16
  - `shadowSm` (offset 0,2 blur 8 opacity 0.04)
  - `shadowMd` (offset 0,4 blur 12 opacity 0.06)
  - Method `card(BuildContext)` → BoxDecoration
  - Method `elevatedCard(BuildContext)` → BoxDecoration

### 5. Refactor `theme/light_theme.dart`
- Import design token
- Gunakan AppColors untuk colorScheme
- Gunakan AppTextStyles untuk textTheme
- Gunakan AppDecorations untuk componentTheme (card, dialog, chip)
- Set button theme, input theme, appBar theme, bottom nav theme

### 6. Refactor `theme/dark_theme.dart`
- Sama seperti light theme, dengan AppColors.forBrightness(dark)

### 7. Update `pubspec.yaml`
- Tambah `google_fonts: ^6.1.0`
- Update version ke `1.0.1`

## Output yang Diharapkan
- 4 file design token baru (`app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_decorations.dart`)
- `light_theme.dart` dan `dark_theme.dart` menggunakan design token
- Tidak ada nilai warna/radius/spacing hardcoded di theme files
- `flutter analyze` bersih

## Dependencies
Tidak ada (task pertama)

## Acceptance Criteria
- [x] Design token file terpisah dan reusable
- [x] Light & dark theme menggunakan token
- [x] Google Fonts Poppins terintegrasi
- [x] TextTheme dengan 9 level style
- [x] ColorScheme dengan palet terbatas (≤12 warna)
- [x] Spacing system dengan base unit 4
- [x] Border radius maksimal 3 varian
- [x] Shadow maksimal 2 level
- [x] `flutter analyze` bersih

## Estimasi: 3-4 jam
