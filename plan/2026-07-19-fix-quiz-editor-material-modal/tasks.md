# Task List — Fix Quiz Editor & Modal Tambah Materi

**Tanggal**: 2026-07-19
**Tipe**: Bug fix (lanjutan UI/UX Redesign v1.1.4)
**Plan**: `plan/2026-07-19-fix-quiz-editor-material-modal/plan-design.md`

## Urutan Eksekusi

### T1 — Fix error compile `Colors.white20`
- [ ] **File**: `sea_app/lib/pages/teacher/page_quiz_questions_teacher.dart:558`
- [ ] **Aksi**: Ganti `Colors.white20` → `Colors.white24`
- [ ] **Verifikasi**: `flutter analyze` tidak lagi melaporkan `undefined_getter white20`
- [ ] **Hasil jelas**: App bisa di-build

### T2 — Fix overflow `AppButton` (modal materi)
- [ ] **File**: `sea_app/lib/component/ui/app_button.dart`
- [ ] **Aksi**: Bungkus `Text` di dalam `Row` anak dengan `Flexible` agar bisa shrink/wrap bila melebihi lebar
- [ ] **Verifikasi**: Modal tambah materi tidak melaporkan RenderFlex overflowed by 8.3px
- [ ] **Hasil jelas**: Tidak ada overflow pada kondisi lebar sempit

### T3 — Fix back saat loading di modal tambah materi
- [ ] **File**: `sea_app/lib/component/window/window_add_material.dart`
- [ ] **Aksi**:
  - Header close-X selalu tampil (tidak ikut loading state)
  - Tombol "Batal" tetap aktif saat loading
  - `CircularProgressIndicator` inline pakai properti `isLoading` `AppButton` (bukan menggantikan seluruh baris)
- [ ] **Verifikasi**: Saat `_loading=true`, close-X dan tombol Batal masih bisa ditekan
- [ ] **Hasil jelas**: User selalu bisa keluar dari modal

### T4 — Hapus unused import
- [ ] **File**: `sea_app/lib/pages/teacher/page_menu_quiz_editor_teacher.dart:9`
- [ ] **Aksi**: Hapus baris `import '../../component/window/window_confirmation.dart';`
- [ ] **Verifikasi**: `flutter analyze` tidak lagi warning `unused_import` di file ini
- [ ] **Hasil jelas**: Warning hilang

### T5 — Verifikasi akhir
- [ ] **Aksi**: Jalankan `flutter analyze --no-pub`
- [ ] **Kriteria**: 0 error; warning tidak boleh lebih dari baseline (saat ini 22 issues, target: ≤21 karena 1 unused_import hilang, error 1 hilang)

### T6 — Update `.memori.txt`
- [ ] **Aksi**: Tambah entry paling atas untuk kerjaan AI sebelumnya (halaman bank soal) + fix ini
- [ ] **Format**: Sesuai template AGENTS.md (Tanggal/Waktu/Kategori/Judul/Detail/Dampak)
- [ ] **Hasil jelas**: Konteks lintas sesi tersimpan

## Catatan Eksekusi

- **Urutan dependency**: T1 → T2 → T3 → T4 → T5 → T6. T1 blocker, harus duluan.
- **Linting wajib**: Setiap T1-T4 selesai, jalankan `flutter analyze` untuk pastikan tidak ada error baru sebelum lanjut.
- **Regression check**: Pastikan editor diskusi (yang juga pakai `WindowAddMaterial` & `AppButton`) tidak rusak.
- **Tidak commit**: Sesuai aturan, tidak ada git commit tanpa izin user.
