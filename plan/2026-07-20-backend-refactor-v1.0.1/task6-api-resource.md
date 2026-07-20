# Task 6 — API Resource & Response Standardization

## Deskripsi
Membuat API Resource untuk menyeragamkan format response. Saat ini setiap endpoint punya format berbeda-beda (`{"data": [...]}`, `{"answer": "..."}`, `{"user": {...}}`, dll).

## Tujuan Teknis
- Buat Resource classes untuk setiap model utama
- Gunakan Resource di semua controller responses
- Format konsisten: `{"data": {...}}` untuk single, `{"data": [...], "meta": {...}}` untuk collection

## Scope
**Backend:**
- BUAT: 8 Resource files di `app/Http/Resources/`
- EDIT: Semua controllers untuk pakai Resource

**Flutter:** Tidak ada perubahan (format response tetap kompatibel)

## Resource Classes

### UserResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_user,
        'name' => $this->name,
        'email' => $this->email,
        'role' => $this->role,
        'createdAt' => $this->created_at?->toDateTimeString(),
    ];
}
```

### ClassResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_class,
        'code' => $this->code_class,
        'name' => $this->name,
        'description' => $this->description,
        'semester' => $this->semester,
        'createdBy' => (string) $this->created_by,
        'createdAt' => $this->created_at?->toDateTimeString(),
        'updatedAt' => $this->updated_at?->toDateTimeString(),
    ];
}
```

### QuizResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_quiz,
        'title' => $this->title,
        'duration' => $this->duration,
        'createdBy' => (string) $this->created_by,
        'createdAt' => $this->created_at?->toDateTimeString(),
    ];
}
```

### QuestionResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_question,
        'number' => $this->number,
        'questionText' => $this->question_text,
        'point' => $this->point,
        'materialId' => $this->fk_id_material ? (string) $this->fk_id_material : null,
        'choices' => AnswerChoiceResource::collection($this->whenLoaded('answerChoices')),
    ];
}
```

### AnswerChoiceResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_answerchoice,
        'content' => $this->content,
        // is_correct TIDAK diinclude di sini (prevent leaking ke client)
    ];
}
```

### DiscussionResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_discussionroom,
        'title' => $this->title,
        'description' => $this->description,
        'tag' => $this->tag,
        'status' => $this->status,
        'numGroups' => $this->num_groups,
        'studentsPerGroup' => $this->students_per_group,
        'createdBy' => (string) $this->created_by,
        'classId' => (string) $this->fk_id_class,
        'chatroomActive' => $this->whenLoaded('chatrooms', function () {
            return $this->chatrooms->contains('status', 'active');
        }),
        'createdAt' => $this->created_at?->toDateTimeString(),
    ];
}
```

### MaterialResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_material,
        'title' => $this->title,
        'content' => $this->content,
        'type' => $this->type,
        'createdAt' => $this->created_at?->toDateTimeString(),
    ];
}
```

### ResultQuizResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_resultquiz,
        'quizId' => (string) $this->fk_id_quiz,
        'userId' => (string) $this->fk_id_user,
        'score' => $this->score,
        'status' => $this->status,
        'startedAt' => $this->started_at,
        'finishedAt' => $this->finished_at,
        'details' => ResultQuestionResource::collection($this->whenLoaded('details')),
    ];
}
```

### MessageResource
```php
public function toArray($request)
{
    return [
        'id' => (string) $this->id_message,
        'chatroomId' => (string) $this->fk_id_chatroomai,
        'userId' => (string) $this->fk_id_user,
        'role' => $this->role,
        'content' => $this->content,
        'contentType' => $this->content_type,
        'status' => $this->status,
        'createdAt' => $this->created_at?->toDateTimeString(),
    ];
}
```

## Contoh Penggunaan di Controller
```php
// Sebelum
$classes = SchoolClass::all();
return response()->json(['data' => $classes]);

// Sesudah
$classes = SchoolClass::all();
return ClassResource::collection($classes);
```

## Output yang Diharapkan
- 8 Resource files dibuat
- Semua controller menggunakan Resource
- Response format konsisten di semua endpoint

## Dependencies
- Task 3 (Controller Refactor) sebaiknya selesai duluan

## Acceptance Criteria
- [ ] 8 Resource files dibuat
- [ ] Semua controller responses menggunakan Resource
- [ ] Format response konsisten
- [ ] `is_correct` tidak bocor ke client (kecuali endpoint tertentu)
- [ ] `composer lint` bersih

## Estimasi: 2-3 jam
