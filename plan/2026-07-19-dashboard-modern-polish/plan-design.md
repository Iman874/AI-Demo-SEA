# Plan Design — Dashboard Modern Polish v1.2.0

**Tanggal**: 2026-07-19
**Versi**: v1.2.0 (UI/UX Modern Polish)
**Tipe**: Feature / Visual refactor
**Scope**: Flutter client (backend tidak tersentuh)
**Acuan**: Feedback desain user (10 poin + revisi dark mode), target naik dari ~8.3/10 ke 9.3–9.5/10

## Latar Belakang

Setelah UI/UX redesign v1.0.1–v1.1.6, tampilan sudah 70–80% modern (warna, spacing, ikon konsisten). Yang masih terasa "2021–2022" adalah **komposisi & hierarchy**, bukan warna. User memberi 10 poin feedback konkret + revisi dark mode. Poin paling terasa: header kosong, bottom nav gaya Material lama, stats tanpa hierarchy, card kelas kosong, kurang aksen kecil (badge/progress/metadata).

## Tujuan

1. Header dashboard terasa hidup (info aktivitas + progress nyata, bukan palsu).
2. Stats card punya hierarchy visual (angka dominan, label kecil, ikon soft).
3. Card kelas lebih informatif (metadata + aksen), tidak kosong.
4. Ada aksen warna kedua (badge/status pakai semantic color, bukan semua biru).
5. Tombol aksi card ringkas (icon button), tidak sebesar card.
6. Floating CTA lebih hidup (gradient, shadow lembut, subtitle).
7. Section header punya pemisah visual (garis aksen / ikon).
8. Bottom nav active tab pakai capsule (bukan cuma warna).
9. Avatar gradient + border putih + indikator online + shadow.
10. Spacing antar section lebih lega (whitespace = premium).
11. Dark mode 3-tier elevasi (background < card < surface) agar card "naik".

## Scope

### Yang Dikerjakan
- `app_colors.dart` + `dark_theme.dart`: 3-tier dark surface system + token central.
- `page_menu_home_teacher.dart` & `page_menu_home_student.dart`: header info+progress, stats hierarchy, card kelas metadata, CTA, section header, avatar, spacing.
- `card_class.dart`: metadata + aksen badge semantic.
- `card_discussion.dart` & `card_quiz.dart`: tombol aksi ringkas (icon button).
- `bottom_navigation.dart`: active tab capsule.
- `top.dart`: avatar gradient + border + indikator online (header halaman non-home).
- Sapu hardcoded `Color(0xFF1E293B)` / `Color(0xFF1F2D40)` di card → pakai token.

### Yang TIDAK Dikerjakan (out of scope)
- Tidak tambah field model baru (ClassModel tetap).
- Tidak tambah endpoint backend / tracking progress mingguan.
- Tidak ubah logika bisnis / API call / state management.
- Tidak ubah halaman editor (quiz/discussion editor) — sudah dirubah v1.1.x.
- Tidak fabricate angka progress palsu (prinsip kejujuran AGENTS.md).

## Keputusan Desain (perlu konfirmasi user)

| # | Keputusan | Alasan |
|---|---|---|
| D1 | **Progress header pakai data nyata**: siswa = `completedQuizzes/totalQuizzes` %; guru = info aktivitas (kelas diajar + diskusi aktif) tanpa bar palsu. Jika data 0 → tampilkan prompt kontekstual, bukan bar 0%. | Tidak ada tracking backend; hindari angka palsu. |
| D2 | **Metadata card kelas**: `semester` + "Terakhir diperbarui" (relative time dari `updatedAt`). Tidak tampilkan jumlah siswa (ClassModel tidak punya field; fetch per-card terlalu mahal). | Field model terbatas. |
| D3 | **Tombol aksi card** → icon button bulat (bukan ⋮ menu). Alasan: aksi utama hanya 1 (Edit/Detail/Hasil), icon button cukup & lebih ringkas dari pill berlabel. ⋮ menu cocok kalau ada ≥2 aksi. | Minim aksi per card. |
| D4 | **Floating CTA** → container card gradient (bukan FAB sistem), judul + subtitle, radius 20, shadow lembut. Pertahankan posisi inline di akhir konten. | Feedback minta "subtitle kecil" & CTA tidak datar. |
| D5 | **Terapkan ke BOTH home** (guru & murid) untuk konsistensi. | Konsistensi role-based UI. |

## Design Teknis per Poin

### P1 — Header hidup (home guru & murid)
- Tambah info row di bawah nama (di dalam header gradient):
  - Guru: `Belajar mengajar hari ini` + `X kelas • Y diskusi aktif`
  - Murid: `Aktivitas belajar` + `X kelas • Y kuis aktif`
- Progress bar (hanya murid, derived): `completedQuizzes / (active+completed)` %. Kalau total 0 → sembunyikan bar, tampilkan teks motivasi.
- Guru: tidak pakai bar (tidak ada metrik pengajaran yang tersedia); pakai info aktivitas saja.

### P2 — Stats hierarchy
- Restructure 2 stats card: layout vertikal — ikon soft (small, top-left, alpha 0.12), **angka BESAR** (28px bold), label kecil (10px) di bawah angka.
- Pertahankan posisi melayang di bawah header gradient.

### P3 — Card kelas metadata
- Horizontal card (home): tambah footer `semester` + "Diperbarui X lalu" (relative time). Tambah ikon buku di header card.
- `card_class.dart` (vertical): tambah row metadata (semester + last updated), badge "Aktif" → hijau (success), kode kelas → badge abu-abu neutral.

### P4 — Aksen warna kedua
- `card_class.dart` badge "Aktif" → `AppColors.success` (hijau).
- `card_discussion.dart` status "Terbuka" → sudah hijau, pertahankan; "Selesai" → abu/neutral.
- Kode kelas badge → abu muda neutral (bukan biru).
- Tambah aksen ungu/cyan hanya bila ada kategori nyata (tidak dipaksakan).

### P5 — Tombol aksi ringkas
- `card_discussion.dart` & `card_quiz.dart`: ganti `AppButton.pill(icon+label)` → `IconButton` bulat (radius penuh, background alpha 0.12, ikon 18px) + `Tooltip`.
- Diskusi: ikon `edit_rounded` (open) / `info_outline_rounded` (closed).
- Kuis: ikon `chevron_right_rounded` atau `assignment_outlined`.

### P6 — Floating CTA
- Home guru: "Mulai Diskusi Baru" → container gradient `studentGradient` (atau `teacherGradient`? — CTA aksi utama guru, pakai teacherGradient), radius 20, shadow lembut, layout: ikon besar (28px) di kiri + kolom [judul bold, subtitle kecil].
- Bisa di-tap seluruh area (InkWell).

### P7 — Section header aksen
- `_buildContentSectionHeader` (dua home): tambah **garis aksen vertikal gradient** 4px di kiri judul, tinggi mengikuti tinggi teks. Pertahankan watermark angka besar di belakang.

### P8 — Bottom nav capsule
- `_NavItem` active: bungkus `Column(icon+label)` dalam `Container` pill dengan background `accentColor.withValues(alpha: 0.12)` + border tipis `accentColor.withValues(alpha: 0.25)`, radius 16, padding horizontal 12. Inactive: tetap polos.
- Pertahankan glassmorphism `BackdropFilter`.

### P9 — Avatar modern
- Home header avatar: gradient fill (role gradient), border putih 2px, shadow lembut, inisial putih. Tambah indikator online hijau kecil di pojok kanan-bawah.
- `top.dart` avatar: sama (gradient + border + shadow), tanpa indikator online (header halaman non-home, lebih simpel).

### P10 — Spacing
- Tingkatkan gap antar section: `SizedBox(height: 20)` → `28` di seluruh home. Tambah `SizedBox(height: 8–12)` sebelum section header kalau belum ada.

### Dark Mode — 3-tier elevasi
- `app_colors.dart`:
  - `backgroundDark`: `#080C14` → `#0B1020`
  - `cardDark` (BARU): `#151D2F`
  - `surfaceDark`: `#111827` → `#1C2740`
  - `borderDark`: `#1F2D40` → `Color(0x14FFFFFF)` (rgba 255,255,255,0.08)
  - `scaffoldDark`: ikut `backgroundDark`
- `dark_theme.dart`: `cardColor` → `cardDark`; `colorScheme.surface` → `surfaceDark`.
- Sapu hardcoded dark card color di home pages & cards (`0xFF1E293B`, `0xFF1F2D40`) → `AppColors.cardDark` / `AppColors.surfaceDark`.
- Tambah helper `AppColors.card(Brightness)`.

## Dampak ke Sistem

- **Fitur terdampak**: Home guru & murid, semua card (kelas/diskusi/quiz), bottom nav, header halaman non-home, dark mode seluruh app.
- **Efek samping positif**: Dark mode lebih dalam & ber-elevasi di seluruh app (bukan cuma home).
- **Efek samping negatif**: Tidak ada logic change. Hanya visual.
- **Risiko regresi**: Sedang. Banyak file tersentuh. Mitigasi: verifikasi `flutter analyze` per task, regression visual manual.
- **Backend**: Tidak tersentuh.

## Definition of Done

- [ ] `flutter analyze` 0 error (warning tidak boleh tambah dari baseline 20).
- [ ] 10 poin feedback + dark mode terimplementasi.
- [ ] Tidak ada angka progress/badai palsu.
- [ ] Dark mode: card terlihat "naik" dari background (3-tier).
- [ ] Bottom nav active tab pakai capsule.
- [ ] Avatar gradient + border + indikator online (home).
- [ ] Konsistensi guru & murid.
- [ ] `.memori.txt` diupdate.
- [ ] Tidak ada perubahan liar di luar scope.
