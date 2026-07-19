# Plan Design — Fix Quiz Editor & Modal Tambah Materi

**Tanggal**: 2026-07-19
**Versi**: Hotfix (lanjutan UI/UX Redesign v1.1.4)
**Tipe**: Bug fix
**Scope**: Flutter client (backend tidak tersentuh)

## Latar Belakang

AI sebelumnya diminta: (1) mengganti modal daftar soal kuis dengan halaman baru, (2) memperbaiki modal tambah materi (overflow 8.3px + tidak bisa back saat loading). AI berhenti tengah jalan karena limit, meninggalkan:

- File baru `page_quiz_questions_teacher.dart` (666 baris) **sudah dibuat & terintegrasi** ke `page_menu_quiz_editor_teacher.dart` via `Navigator.push` (permintaan #1 selesai secara struktural).
- **ERROR compile blocker** `Colors.white20` di `page_quiz_questions_teacher.dart:558` — getter tidak ada di Flutter. Akibatnya app tidak bisa di-build sama sekali.
- Permintaan #2 (overflow + back) **belum dikerjakan sama sekali**.
- 1 warning `unused_import` sisa refactor di editor kuis.
- Kerjaan ini **belum tercatat di `.memori.txt`** karena AI berhenti sebelum sempat update.

## Tujuan

1. App bisa di-build & di-run kembali (hilangkan error compile).
2. Modal tambah materi tidak overflow pada kondisi sempit.
3. User selalu bisa keluar dari modal tambah materi (bahkan saat saving/loading).
4. Linting bersih (tidak menambah error/warning baru).

## Scope

### Yang Dikerjakan
- Fix typo `Colors.white20` → `Colors.white24` di `page_quiz_questions_teacher.dart:558`.
- Fix overflow 8.3px di `window_add_material.dart` (akar: `AppButton` `Row` anak tidak flexibel saat label+icon melebihi lebar).
- Fix tidak bisa back saat loading di `window_add_material.dart` (tombol Batal & close-X hilang saat `_loading=true`).
- Bersihkan `unused_import` di `page_menu_quiz_editor_teacher.dart`.

### Yang TIDAK Dikerjakan (out of scope)
- Tidak mengubah struktur halaman bank soal yang sudah jadi.
- Tidak menyentuh backend.
- Tidak mengubah logika `_save` / `convertPdfToText`.
- Tidak refactor komponen lain.

## Breakdown Task

| # | Task | File | Hasil |
|---|---|---|---|
| T1 | Fix error compile `Colors.white20` | `page_quiz_questions_teacher.dart:558` | App bisa build |
| T2 | Fix overflow di `AppButton` (modal materi) | `app_button.dart` | Tidak overflow 8.3px |
| T3 | Fix tombol back saat loading | `window_add_material.dart` | User bisa keluar saat loading |
| T4 | Hapus unused import | `page_menu_quiz_editor_teacher.dart:9` | Warning hilang |
| T5 | Verifikasi `flutter analyze` | — | Tidak ada error baru |
| T6 | Update `.memori.txt` | `.memori.txt` | Konteks tersimpan |

## Design Teknis

### T1 — Fix `Colors.white20`
- **Baris 558**: `Colors.white20` → `Colors.white24` (palette Flutter tersedia: `white10/12/24/30/38`).
- Visually `white24` paling dekat dengan intensitas `white20` yang dimaksud.

### T2 — Fix overflow `AppButton`
- **Akar masalah**: Pada `app_button.dart` build method, `Row` anak berisi `Icon` + `Text` tanpa `Flexible`/`Expanded`. Saat `isFullWidth=true` dan label panjang (mis. "Simpan" di lebar dialog sempit), total width melebihi container → overflow kanan.
- **Solusi**: Bungkus `Text` dengan `Flexible` agar bisa wrap/shrink. `Icon` tetap fixed (tidak perlu flex).
- **Dampak**: Semua pemanggil `AppButton.primary/secondary/pill` mendapat keuntungan — tidak ada efek samping negatif karena hanya menambah flex pada Text.

### T3 — Fix back saat loading
- **Akar masalah**: Saat `_loading=true`, seluruh baris aksi (Batal + Simpan) diganti `CircularProgressIndicator()` tanpa tombol keluar. Jika `convertPdfToText` lama (PDF besar), user terkunci di dialog. Selain itu, dialog `barrierDismissible` default = true, tapi header close-X juga hilang saat loading.
- **Solusi**: 
  - Header close-X **selalu tampil** (pindah keluar `Row` aksi, tidak ikut loading state).
  - Tombol "Batal" **tetap aktif** saat loading (disabled state hanya untuk tombol Simpan agar tidak double-submit).
  - `CircularProgressIndicator` ditampilkan **inline** di samping label Simpan (bukan menggantikan seluruh baris), memakai `isLoading` properti `AppButton` yang sudah ada.
- **Konsekuensi**: `Navigator.pop()` saat saving akan membatalkan proses async (acceptable — user sadar membatalkan).

### T4 — Hapus unused import
- `import '../../component/window/window_confirmation.dart';` di `page_menu_quiz_editor_teacher.dart:9` tidak dipakai (konfirmasi hapus soal dipindah ke `page_quiz_questions_teacher.dart`).

## Dampak ke Sistem

- **Fitur terdampak**: Editor kuis guru, modal tambah materi (dipakai di editor kuis & editor diskusi).
- **Efek samping positif**: Semua `AppButton` di seluruh app jadi lebih tahan terhadap overflow.
- **Efek samping negatif**: Tidak ada — perubahan hanya pada rendering Text yang melebihi lebar.
- **Risiko regresi**: Rendah. T1 fix 1 baris. T2 menambah `Flexible` (behavior identik untuk label pendek). T3 hanya mengubah urutan rendering tombol.
- **Backend**: Tidak tersentuh. Tidak ada perubahan API/payload.

## Definition of Done

- [ ] `flutter analyze` 0 error (warning pre-existing boleh, tidak boleh tambah baru).
- [ ] App bisa di-build & di-run.
- [ ] Modal tambah materi tidak overflow pada lebar sempit (sekitar 8.3px benar).
- [ ] User bisa keluar dari modal tambah materi saat loading (close-X & tombol Batal selalu aktif).
- [ ] Halaman bank soal kuis tampil normal (tidak crash karena `white20`).
- [ ] `.memori.txt` diupdate dengan kerjaan AI sebelumnya + fix ini.
- [ ] Tidak ada perubahan liar di luar scope.
