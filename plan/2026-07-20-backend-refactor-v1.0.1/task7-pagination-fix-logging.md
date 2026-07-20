# Task 7 — Pagination, Code Fix & Logging

## Deskripsi
Menambahkan pagination di index endpoints, memperbaiki code_class generation bug, dan mengganti silent error swallowing dengan proper logging.

## Tujuan Teknis
- Tambah pagination di semua index endpoint
- Fix code_class generation (race condition + gap ID)
- Ganti `catch (\Throwable $_) {}` dengan proper logging
- Tambah `created_at`/`updated_at` otomatis di semua insert manual

## Scope
**Backend:**
- EDIT: `app/Http/Controllers/ClassController.php`
- EDIT: `app/Http/Controllers/QuizController.php`
- EDIT: `app/Http/Controllers/MaterialController.php`
- EDIT: `app/Http/Controllers/DiscussionController.php`
- EDIT: `app/Http/Controllers/DiscussionDataController.php`

**Flutter:** Tidak ada perubahan

## Langkah Implementasi

### 1. Pagination di Index Endpoints

**ClassController@index:**
```php
public function index(Request $request)
{
    $classes = SchoolClass::orderBy('created_at', 'desc')->paginate(20);
    return ClassResource::collection($classes);
}
```

**QuizController@index:**
```php
public function index(Request $request)
{
    $classId = $request->query('class_id');
    $query = Quiz::query();
    if ($classId) {
        $query->whereHas('classes', fn($q) => $q->where('fk_id_class', $classId));
    }
    $quizzes = $query->orderBy('created_at', 'desc')->paginate(20);
    return QuizResource::collection($quizzes);
}
```

**MaterialController@index:**
```php
public function index(Request $request)
{
    $query = MaterialQuiz::query();
    // ... filters
    $items = $query->orderBy('created_at', 'desc')->paginate(20);
    return MaterialResource::collection($items);
}
```

**DiscussionController@index:**
```php
public function index(Request $request)
{
    $query = DiscussionRoom::with('chatrooms');
    // ... filters
    $rooms = $query->orderBy('created_at', 'desc')->paginate(20);
    return DiscussionResource::collection($rooms);
}
```

### 2. Fix Code Class Generation

**ClassController@store:**
```php
// Sebelum (buggy):
$code = 'CLS' . str_pad((string) (SchoolClass::max('id_class') + 1), 3, '0', STR_PAD_LEFT);

// Sesudah (safe):
do {
    $code = 'CLS' . strtoupper(uniqid('', false));
} while (SchoolClass::where('code_class', $code)->exists());
```

Atau lebih sederhana:
```php
$code = 'CLS' . str_pad((string) (SchoolClass::max('id_class') + 1), 4, '0', STR_PAD_LEFT);
// + cek uniqueness
```

### 3. Proper Logging

Ganti semua silent catch:
```php
// Sebelum:
} catch (\Throwable $_) {}

// Sesudah:
} catch (\Throwable $e) {
    Log::warning('Failed to create discussion student: ' . $e->getMessage());
}
```

Terutama di:
- `DiscussionController::store()` — gagal create DiscussionStudent
- `GeminiController::chatStudent()` — gagal persist message
- `QuizController::submitResult()` — gagal insert result_question
- `DiscussionController::update()` — gagal update discussion students

## Output yang Diharapkan
- Semua index endpoint punya pagination
- Code class generation aman dari race condition
- Error log tercatat di `storage/logs/laravel.log`

## Dependencies
- Task 5 (DB Schema) sebaiknya selesai duluan

## Acceptance Criteria
- [ ] Semua index endpoint return paginated response
- [ ] Code class generation tidak ada race condition
- [ ] Tidak ada `catch (\Throwable $_) {}` tanpa logging
- [ ] Error tercatat di log file
- [ ] `composer lint` bersih

## Estimasi: 2-3 jam
