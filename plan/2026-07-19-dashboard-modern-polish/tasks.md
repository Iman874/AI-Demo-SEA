# Task List — Dashboard Modern Polish v1.2.0

**Tanggal**: 2026-07-19
**Plan**: `plan/2026-07-19-dashboard-modern-polish/plan-design.md`

## Urutan Eksekusi (dependency: T1 fondasi → T2-T11 paralel-ish → T12 sapu → T13 verifikasi)

### T1 — Dark mode 3-tier color system (FONDASI)
- [ ] **File**: `app_colors.dart`, `dark_theme.dart`
- [ ] **Aksi**:
  - `app_colors.dart`: `backgroundDark #0B1020`, `cardDark #151D2F` (baru), `surfaceDark #1C2740`, `borderDark Color(0x14FFFFFF)`, `scaffoldDark = backgroundDark`; tambah helper `card(Brightness)`.
  - `dark_theme.dart`: `cardColor` → `cardDark`, `colorScheme.surface` → `surfaceDark`, `scaffoldBackgroundColor` → `scaffoldDark`.
- [ ] **Hasil jelas**: Token dark 3-tier tersedia untuk task berikutnya.

### T2 — Avatar modern (shared)
- [ ] **File**: `top.dart`, `page_menu_home_teacher.dart`, `page_menu_home_student.dart`
- [ ] **Aksi**: Avatar gradient (role gradient) + border putih 2px + shadow lembut + inisial putih. Home: tambah indikator online hijau. TopHeader: tanpa indikator online.
- [ ] **Hasil jelas**: Avatar tidak polos; ada depth & status.

### T3 — Stats hierarchy (home guru & murid)
- [ ] **File**: `page_menu_home_teacher.dart`, `page_menu_home_student.dart`
- [ ] **Aksi**: Restructure 2 stats card → vertikal: ikon soft (alpha 0.12, small), angka BESAR (28px bold), label kecil (10px).
- [ ] **Hasil jelas**: Mata tangkap angka dulu.

### T4 — Header info + progress (home guru & murid)
- [ ] **File**: `page_menu_home_teacher.dart`, `page_menu_home_student.dart`
- [ ] **Aksi**:
  - Tambah info row di bawah nama (guru: kelas + diskusi aktif; murid: kelas + kuis aktif).
  - Murid: progress bar derived `completed/(active+completed)`, sembunyi kalau total 0 → teks motivasi.
  - Guru: info aktivitas saja (tanpa bar palsu).
- [ ] **Hasil jelas**: Header terasa hidup; tidak ada angka palsu.

### T5 — Card kelas metadata
- [ ] **File**: `page_menu_home_teacher.dart` (`_buildClassHorizontalCard`), `page_menu_home_student.dart` (sama), `card_class.dart`
- [ ] **Aksi**:
  - Horizontal card: tambah ikon buku, footer `semester` + "Diperbarui X lalu" (relative time dari `updatedAt`).
  - `card_class.dart`: row metadata (semester + last updated), badge "Aktif" → hijau, kode → badge abu neutral.
- [ ] **Hasil jelas**: Card kelas tidak kosong.

### T6 — Aksen warna kedua (badge/status)
- [ ] **File**: `card_class.dart`, `card_discussion.dart`
- [ ] **Aksi**: Badge "Aktif" → `success`; kode kelas → abu neutral; status diskusi pertahankan hijau/abu. Tidak pakai biru untuk semua.
- [ ] **Hasil jelas**: Ada nuansa warna kedua.

### T7 — Tombol aksi card ringkas
- [ ] **File**: `card_discussion.dart`, `card_quiz.dart`
- [ ] **Aksi**: Ganti `AppButton.pill(icon+label)` → `IconButton` bulat (bg alpha 0.12, ikon 18px) + `Tooltip`.
- [ ] **Hasil jelas**: Tombol aksi tidak sebesar card.

### T8 — Floating CTA restyle
- [ ] **File**: `page_menu_home_teacher.dart` (CTA "Mulai Diskusi Baru")
- [ ] **Aksi**: Container gradient `teacherGradient`, radius 20, shadow lembut, ikon besar 28px + kolom [judul bold, subtitle kecil], InkWell seluruh area.
- [ ] **Hasil jelas**: CTA terasa hidup, tidak datar.

### T9 — Section header aksen
- [ ] **File**: `page_menu_home_teacher.dart` (`_buildContentSectionHeader`), `page_menu_home_student.dart` (sama)
- [ ] **Aksi**: Tambah garis aksen vertikal gradient 4px di kiri judul; pertahankan watermark angka.
- [ ] **Hasil jelas**: Section punya pemisah visual.

### T10 — Bottom nav capsule
- [ ] **File**: `bottom_navigation.dart`
- [ ] **Aksi**: Active `_NavItem` → bungkus Column dalam Container pill (bg `accentColor alpha 0.12`, border tipis, radius 16, padding horizontal 12). Inactive polos. Pertahankan glassmorphism.
- [ ] **Hasil jelas**: Active tab pakai capsule, bukan cuma warna.

### T11 — Spacing pass
- [ ] **File**: `page_menu_home_teacher.dart`, `page_menu_home_student.dart`
- [ ] **Aksi**: Gap antar section 20 → 28; tambah breathing room sebelum section header.
- [ ] **Hasil jelas**: Lebih lega, terasa premium.

### T12 — Sapu hardcoded dark card color
- [ ] **File**: home pages, card files (yg masih pakai `0xFF1E293B` / `0xFF1F2D40`)
- [ ] **Aksi**: Ganti → `AppColors.cardDark` / `AppColors.surfaceDark` / `AppColors.borderDark`.
- [ ] **Hasil jelas**: Dark mode konsisten pakai token 3-tier.

### T13 — Verifikasi & memori
- [ ] **Aksi**: `flutter analyze --no-pub` (target 0 error, warning ≤ baseline 20). Update `.memori.txt` (v1.2.0).
- [ ] **Hasil jelas**: Linting bersih; konteks tersimpan.

## Catatan Eksekusi

- **Urutan**: T1 wajib duluan (fondasi warna). T2-T11 bisa berurutan per file-group. T12 setelah visual selesai. T13 terakhir.
- **Linting wajib**: Setelah T1, T7, T10, T12 jalankan `flutter analyze` untuk pastikan tidak error baru.
- **Regression**: Pastikan editor & halaman non-home tidak rusak (TopHeader dipakai banyak halaman).
- **Kejujuran**: Jangan fabricate progress/jumlah siswa. Pakai data nyata atau kontekstual.
- **Tidak commit**: Tanpa izin user.
