# Task 8 — Config API Key, Cleanup & Version Bump

## Deskripsi
Task terakhir: membersihkan sisa-sisa kode lama, memastikan config sudah benar, dan menaikkan versi ke 1.0.1.

## Tujuan Teknis
- Pastikan tidak ada `env()` langsung di controllers
- Update `composer.json` version ke 1.0.1
- Bersihkan unused imports
- Final lint check
- Update `.memori.txt`

## Scope
**Backend:**
- EDIT: `composer.json` (version bump)
- REVIEW: Semua controllers (pastikan tidak ada `env()`)
- REVIEW: Semua models (pastikan relationships benar)
- EDIT: `.memori.txt` (catatan refactoring)

**Flutter:** Tidak ada perubahan

## Langkah Implementasi

### 1. Version Bump
```json
{
    "name": "sea-app/backend",
    "version": "1.0.1"
}
```

### 2. Final Review Checklist

**Pastikan TIDAK ADA:**
- [ ] `env()` langsung di controllers (pindah ke config)
- [ ] `DB::table()` di controllers (pindah ke model/relationship)
- [ ] Manual auth code di controllers (pindah ke middleware)
- [ ] Prompt text di controllers (pindah ke AiPromptService)
- [ ] `Schema::hasTable()` berlebihan di controllers
- [ ] Silent catch tanpa logging
- [ ] Response format tidak konsisten

**Pastikan ADA:**
- [ ] Auth middleware di semua protected routes
- [ ] Service layer untuk AI calls
- [ ] Model relationships di semua model
- [ ] API Resource di semua responses
- [ ] Pagination di semua index endpoints
- [ ] Proper logging di semua catch blocks

### 3. Final Lint
```bash
./vendor/bin/pint
```

### 4. Update `.memori.txt`
Tambahkan entry baru tentang refactoring backend v1.0.1.

## Output yang Diharapkan
- Versi backend = 1.0.1
- Kode bersih dari anti-patterns
- Semua task selesai dan terverifikasi

## Dependencies
- Semua Task 1-7 harus selesai

## Acceptance Criteria
- [ ] Version di `composer.json` = `1.0.1`
- [ ] Tidak ada `env()` di controllers
- [ ] Tidak ada manual auth code
- [ ] Tidak ada prompt text di controllers
- [ ] `composer lint` bersih
- [ ] Semua endpoint berfungsi (regression test)
- [ ] `.memori.txt` diupdate

## Estimasi: 1-2 jam
