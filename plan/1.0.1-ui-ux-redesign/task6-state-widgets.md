# Task 6 — Standarisasi Empty / Loading / Error State

## Deskripsi
Membuat widget reusable untuk empty state, loading state, dan error state yang konsisten di seluruh aplikasi. Mengadopsi pendekatan MyWallet.

## Tujuan Teknis
- Empty state: icon lingkaran + title + subtitle (center)
- Loading state: centered CircularProgressIndicator (konsisten)
- Error state: icon error + pesan + tombol retry (optional)
- Semua state menggunakan theme colors dan AppTextStyles

## Scope
**Backend:** Tidak ada
**Flutter:** BUAT baru dan EDIT:
- BUAT: `component/state/empty_state.dart`
- BUAT: `component/state/loading_state.dart`
- BUAT: `component/state/error_state.dart`
- EDIT: semua file pages dan component yang punya empty/loading/error state

## Langkah Implementasi

### 1. Buat `component/state/empty_state.dart`
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action; // optional button

  // Icon lingkaran besar dengan bg transparent
  // Title pakai AppTextStyles.titleMedium
  // Subtitle pakai AppTextStyles.bodyMedium
  // Semua dibungkus Center + Padding
}
```

### 2. Buat `component/state/loading_state.dart`
```dart
class LoadingState extends StatelessWidget {
  // Center(child: CircularProgressIndicator())
  // Warna dari Theme.of(context).colorScheme.primary
}
```

### 3. Buat `component/state/error_state.dart`
```dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  // Icon error (Icons.error_outline) dengan warna error
  // Pesan error pakai AppTextStyles.bodyMedium, warna error
  // Tombol retry (OutlinedButton) jika onRetry != null
}
```

### 4. Implementasi di Pages
Ganti semua pola manual:
```dart
// SEBELUM:
if (_isLoading) {
  return Center(child: CircularProgressIndicator());
}
if (_error != null) {
  return Center(child: Text('Error: $_error'));
}
if (_isEmpty) {
  return Center(child: Text('No data'));
}

// SESUDAH:
if (_isLoading) return LoadingState();
if (_error != null) return ErrorState(message: _error!, onRetry: _retry);
if (_isEmpty) return EmptyState(icon: Icons.inbox, title: 'Belum ada data');
```

### 5. Standarisasi Text Empty State
Seragamkan pesan empty state di seluruh app:
- "Belum ada kelas" (class_list)
- "Belum ada materi" (material)
- "Belum ada quiz" (quiz)
- "Belum ada diskusi" (discussion)
- "Belum ada hasil quiz" (quiz result)
- "Belum ada ringkasan" (summary)
- "Tidak ada pesan" (chat)

## Output yang Diharapkan
- 3 widget state reusable baru
- Semua halaman menggunakan state widgets konsisten
- `flutter analyze` bersih

## Dependencies
Task 1 (Design Token), Task 2 (Card/Container)

## Acceptance Criteria
- [x] EmptyState widget dengan icon + title + subtitle + optional action
- [x] LoadingState widget dengan centered indicator
- [x] ErrorState widget dengan pesan + optional retry
- [x] Semua halaman sudah migrasi ke state widget
- [x] Pesan empty state konsisten (format Bahasa Indonesia)
- [x] `flutter analyze` bersih

## Estimasi: 2-3 jam
