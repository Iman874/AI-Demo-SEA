# Plan Design — UI/UX Redesign v1.0.1

## Latar Belakang

Aplikasi SEA App saat ini memiliki masalah visual yang signifikan: **terlalu banyak warna hardcoded (>16 varian)**, tidak ada sistem spacing/radius/shadow yang konsisten, dark mode rusak, tipografi tidak terstandarisasi, dan struktur halaman berbeda-beda antar screen. Ini membuat tampilan aplikasi terlihat tidak rapi, tidak profesional, dan sulit dimaintenance.

Referensi desain dari proyek **UangKu (MyWallet)** menunjukkan pendekatan yang jauh lebih baik: palet warna terbatas, card-based layout konsisten, tipografi seragam dengan Google Fonts, dan sistem desain yang terstandarisasi.

## Tujuan

1. Menciptakan **design system** yang kohesif untuk SEA App (warna, tipografi, spacing, radius, shadow)
2. Menerapkan design system ke **seluruh halaman Flutter** secara konsisten
3. Memperbaiki **dark mode** agar berfungsi penuh
4. Meningkatkan kualitas **empty state, loading state, dan error state**
5. Menyeragamkan **struktur halaman** (header, bottom nav, layout)
6. Menjadikan referensi UI **MyWallet (UangKu)** sebagai acuan visual

## Scope

### Dikerjakan
- ✅ Design token & theme system (warna, tipografi, spacing, radius, shadow)
- ✅ Refactor theme light & dark (color scheme, text theme, component theme)
- ✅ Standarisasi card & container styling
- ✅ Standarisasi button & input field styling
- ✅ Perbaikan dark mode (audit & fix hardcoded colors)
- ✅ Standarisasi empty / loading / error states
- ✅ Harmonisasi struktur halaman (header, bottom nav)
- ✅ Update version ke 1.0.1

### Tidak dikerjakan
- ❌ Perubahan logika bisnis atau fungsionalitas
- ❌ Penambahan fitur baru
- ❌ Perubahan backend API
- ❌ Animasi kompleks (Lottie/Rive)
- ❌ Shimmer skeleton loading (nice-to-have, pindah ke versi berikutnya)

## Breakdown Task

| # | Task | File Utama | Estimasi |
|---|---|---|---|
| 1 | Design Token & Theme System | `theme/*`, constants baru | 3-4 jam |
| 2 | Standarisasi Card & Container | `component/card/*`, theme | 3-4 jam |
| 3 | Standarisasi Tombol & Input | Theme, component/window/* | 2-3 jam |
| 4 | Perbaikan Dark Mode | Semua file .dart | 3-4 jam |
| 5 | Harmonisasi Struktur Halaman | `pages/**/*`, `component/*` | 4-5 jam |
| 6 | Empty/Loading/Error State | `component/*`, `pages/**/*` | 2-3 jam |
| 7 | Visual Polish & Version Bump | Semua file .dart, pubspec.yaml | 2-3 jam |

Total estimasi: **19-26 jam**

## Design Teknis

### 1. Design Token — Palet Warna (mengacu MyWallet)

Mengadopsi palet terbatas seperti MyWallet, diadaptasi untuk role-based UI (teacher biru, student oranye):

```dart
// Warna inti — dari MyWallet
Primary:       #3B82F6  (biru)  → default system
Secondary:     #D97B43  (oranye) → student accent
Success:       #22C55E  (hijau)
Error:         #EF4444  (merah)
Warning:       #F59E0B  (kuning)
Info:          #3B82F6

// Surface
Background:    #F8FAFC  (light) / #0F0F18  (dark)
Surface:       #FFFFFF  (light) / #222238  (dark)
Border:        #E2E8F0  (light) / #2E2E44  (dark)

// Text
TextPrimary:   #1E293B  (light) / #E2E8F0  (dark)
TextSecondary: #64748B  (light) / #94A3B8  (dark)

// Role-specific accent
TeacherAccent: #4B6A85
StudentAccent: #D97B43
```

Warna tombol akan mengikuti `ColorScheme`:
- Primary action → `colorScheme.primary`
- Success action → `colorScheme.primary` (bukan hijau random)
- Destructive action → `colorScheme.error`
- Cancel → `outlined` style

### 2. Design Token — Tipografi

Mengadopsi **Google Fonts (Poppins)** seperti MyWallet, dengan hierarki terbatas:

```dart
displayLarge: 28px, Bold        — Nominal/saldo besar
headlineMedium: 22px, SemiBold  — Judul halaman
titleLarge: 18px, SemiBold      — Sub-judul
titleMedium: 16px, SemiBold     — Section title
bodyLarge: 16px, Normal         — Paragraf
bodyMedium: 14px, Normal        — Konten umum
bodySmall: 12px, Normal         — Detail kecil
labelLarge: 16px, SemiBold      — Tombol
labelMedium: 14px, Medium       — Label form
labelSmall: 12px, Normal        — Caption
```

### 3. Design Token — Spacing

Menggunakan kelipatan 4 (seperti MyWallet):
```dart
// Spacing scale
space_4, space_8, space_12, space_16, space_20, space_24, space_32, space_48
```

Standarisasi:
- Screen horizontal padding: `20` (konsisten di semua halaman)
- Section spacing: `24`
- Card internal padding: `16`
- Element spacing dalam card: `12`
- Safe area bottom: `100`

### 4. Design Token — Border Radius

Maksimal 3 level:
```dart
radiusSm: 8    — Tombol, input, chip
radiusMd: 12   — Card kecil, dialog
radiusLg: 16   — Card besar, bottom sheet, window
```

### 5. Design Token — Shadow

Maksimal 2 level:
```dart
shadowSm: offset(0,2), blur:8, opacity:0.04  — Card surface
shadowMd: offset(0,4), blur:12, opacity:0.06  — Elevated card / dialog
```

### 6. File Baru

```
sea_app/lib/
├── theme/
│   ├── app_colors.dart          — Design token warna
│   ├── app_text_styles.dart     — Design token tipografi
│   ├── app_spacing.dart         — Design token spacing
│   ├── app_decorations.dart     — Design token radius & shadow
│   ├── light_theme.dart         — ThemeData light (refactor)
│   └── dark_theme.dart          — ThemeData dark (refactor)
```

### 7. File Terdampak

**Refactor langsung design token:**
- `sea_app/lib/theme/light_theme.dart`
- `sea_app/lib/theme/dark_theme.dart`

**Refactor styling:**
- `sea_app/lib/component/card/*` (9 file)
- `sea_app/lib/component/header/top.dart`
- `sea_app/lib/component/nav/bottom_navigation.dart`
- `sea_app/lib/component/window/*` (8 file)
- `sea_app/lib/pages/student/*` (7 file)
- `sea_app/lib/pages/teacher/*` (7 file)
- `sea_app/lib/pages/page_*.dart` (7 file)
- `sea_app/lib/providers/*` (2 file — minor)
- `sea_app/lib/main.dart`

## Dampak ke Sistem

- **Regresi visual**: setiap halaman perlu dicek satu per satu setelah refactor
- **Tidak ada perubahan fungsionalitas**: semua logika bisnis tetap sama
- **Backward compatible**: perubahan hanya di Flutter client, backend tidak tersentuh
- **pubspec.yaml**: update version + tambah dependency `google_fonts`, `shimmer`

## Definition of Done

- [x] Semua warna hardcoded (`Color(0xFF...)`) diganti dengan referensi theme
- [x] Design token terdefinisi di file terpisah (`app_colors.dart`, dll)
- [x] Dark mode berfungsi penuh (tidak ada warna terang yang hardcoded)
- [x] Card/container border radius dan shadow konsisten (max 3 varian radius, 2 varian shadow)
- [x] Tombol dan input mengikuti theme (tidak ada warna random)
- [x] Typography konsisten menggunakan Google Fonts + TextTheme
- [x] Empty state, loading state, error state terstandarisasi
- [x] Struktur halaman seragam (header, bottom nav, padding)
- [x] `flutter analyze` bersih (tanpa error/warning baru)
- [x] Version di `pubspec.yaml` sudah 1.0.1
