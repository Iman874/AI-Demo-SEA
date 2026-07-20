# Task 4 — Model Relationships & ResultQuestion Model

## Deskripsi
Menambahkan relationship definition di semua 19 model dan membuat model `ResultQuestion` yang sudah ada migration-nya tapi belum ada model-nya. Saat ini hanya 1 dari 19 model yang punya relationship.

## Tujuan Teknis
- Tambahkan `hasMany`, `belongsTo`, `belongsToMany` di semua model
- Buat `ResultQuestion` model
- Pastikan tidak ada circular dependency

## Scope
**Backend:**
- EDIT: Semua 19 model files di `app/Models/`
- BUAT: `app/Models/ResultQuestion.php`

**Flutter:** Tidak ada perubahan

## Relationship yang Ditambahkan

### User
```php
public function tokens()      { return $this->hasMany(ApiToken::class, 'user_id'); }
public function classes()     { return $this->belongsToMany(SchoolClass::class, 'user_classes', 'fk_id_user', 'fk_id_class'); }
public function createdClasses() { return $this->hasMany(SchoolClass::class, 'created_by'); }
public function quizzes()     { return $this->hasMany(Quiz::class, 'created_by'); }
public function results()     { return $this->hasMany(ResultQuiz::class, 'fk_id_user'); }
public function messages()    { return $this->hasMany(DiscussionMessage::class, 'fk_id_user'); }
```

### SchoolClass (table: classes)
```php
public function creator()     { return $this->belongsTo(User::class, 'created_by'); }
public function users()       { return $this->belongsToMany(User::class, 'user_classes', 'fk_id_class', 'fk_id_user'); }
public function quizzes()     { return $this->belongsToMany(Quiz::class, 'quiz_classes', 'fk_id_class', 'fk_id_quiz'); }
public function discussions() { return $this->hasMany(DiscussionRoom::class, 'fk_id_class'); }
```

### Quiz
```php
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function classes()    { return $this->belongsToMany(SchoolClass::class, 'quiz_classes', 'fk_id_quiz', 'fk_id_class'); }
public function questions()  { return $this->hasMany(Question::class, 'fk_id_quiz'); }
public function materials()  { return $this->hasMany(MaterialQuiz::class, 'fk_id_quiz'); }
public function results()    { return $this->hasMany(ResultQuiz::class, 'fk_id_quiz'); }
```

### Question
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function material()   { return $this->belongsTo(MaterialQuiz::class, 'fk_id_material'); }
public function answerChoices() { return $this->belongsToMany(AnswerChoice::class, 'question_answer_choices', 'fk_id_question', 'fk_id_answerchoice'); }
```

### AnswerChoice
```php
public function questions()  { return $this->belongsToMany(Question::class, 'question_answer_choices', 'fk_id_answerchoice', 'fk_id_question'); }
```

### MaterialQuiz
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function discussion() { return $this->belongsTo(DiscussionRoom::class, 'fk_id_discussionroom'); }
public function questions()  { return $this->hasMany(Question::class, 'fk_id_material'); }
```

### ResultQuiz
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
public function details()    { return $this->hasMany(ResultQuestion::class, 'fk_id_resultquiz'); }
```

### DiscussionRoom
```php
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function schoolClass(){ return $this->belongsTo(SchoolClass::class, 'fk_id_class'); }
public function chatrooms()  { return $this->hasMany(ChatRoomAI::class, 'fk_id_discussionroom'); }
public function materials()  { return $this->hasMany(MaterialQuiz::class, 'fk_id_discussionroom'); }
```

### ChatRoomAI
```php
public function discussion() { return $this->belongsTo(DiscussionRoom::class, 'fk_id_discussionroom'); }
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function students()   { return $this->hasMany(DiscussionStudent::class, 'fk_id_chatroomai'); }
public function messages()   { return $this->hasMany(DiscussionMessage::class, 'fk_id_chatroomai'); }
public function aiMessages() { return $this->hasMany(AIMessage::class, 'fk_id_chatroomai'); }
public function summaries()  { return $this->hasMany(SummaryDiscussion::class, 'fk_id_chatroomai'); }
public function groups()     { return $this->hasMany(DiscussionGroup::class, 'fk_id_chatroomai'); }
```

### DiscussionMessage
```php
public function chatRoom()   { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai'); }
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
```

### AIMessage
```php
public function chatRoom()   { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai'); }
```

### SummaryDiscussion
```php
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
public function chatRoom()   { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai'); }
public function understanding() { return $this->hasOne(ResultUnderstanding::class, 'fk_id_summarydiscussion'); }
```

### ResultUnderstanding
```php
public function summary()    { return $this->belongsTo(SummaryDiscussion::class, 'fk_id_summarydiscussion'); }
```

### UserClass
```php
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
public function schoolClass(){ return $this->belongsTo(SchoolClass::class, 'fk_id_class'); }
```

### ApiToken
```php
public function user()       { return $this->belongsTo(User::class, 'user_id'); }
```

### QuizClass
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function schoolClass(){ return $this->belongsTo(SchoolClass::class, 'fk_id_class'); }
```

### DiscussionGroup
```php
public function chatRoom()   { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai'); }
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
```

### DiscussionQuestion
```php
public function chatRoom()   { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai'); }
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
```

### ResultQuestion (MODEL BARU)
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ResultQuestion extends Model
{
    protected $table = 'result_question';
    protected $primaryKey = 'id_resultquestion';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_resultquiz',
        'fk_id_question',
        'selected_choice_id',
        'correct_choice_id',
        'is_correct',
        'point',
    ];

    public function resultQuiz() { return $this->belongsTo(ResultQuiz::class, 'fk_id_resultquiz'); }
    public function question()   { return $this->belongsTo(Question::class, 'fk_id_question'); }
}
```

## Output yang Diharapkan
- Semua 19 model + 1 baru (ResultQuestion) punya relationship
- Query bisa pakai `$quiz->questions`, `$class->users()`, dll
- Tidak ada error relationship

## Dependencies
Tidak ada (bisa paralel dengan Task 1-3)

## Acceptance Criteria
- [ ] Semua model punya minimal 1 relationship
- [ ] `ResultQuestion` model dibuat
- [ ] Tidak ada circular dependency error
- [ ] `php artisan tinker` bisa jalankan relationship queries
- [ ] `composer lint` bersih

## Estimasi: 2-3 jam
