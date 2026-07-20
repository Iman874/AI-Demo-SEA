# Analisa Model Eloquent — SEA App

## Ringkasan

Dari 19 model yang ada:
- **1** model punya relationship definition (DiscussionStudent)
- **18** model TIDAK punya relationship sama sekali
- **Semua** model menggunakan custom primary key name
- **Tidak ada** model yang menggunakan SoftDeletes

---

## Detail per Model

### 1. User

```php
class User extends Authenticatable
{
    protected $primaryKey = 'id_user';
    protected $fillable = ['name', 'role', 'email', 'password'];
    protected $hidden = ['password', 'remember_token'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function tokens()     { return $this->hasMany(ApiToken::class, 'user_id'); }
public function classes()    { return $this->belongsToMany(SchoolClass::class, 'user_classes', 'fk_id_user', 'fk_id_class'); }
public function quizzes()    { return $this->belongsToMany(Quiz::class, 'quiz_students', 'fk_id_user', 'fk_id_quiz'); }
public function results()    { return $this->hasMany(ResultQuiz::class, 'fk_id_user'); }
public function discussions(){ return $this->hasMany(DiscussionRoom::class, 'created_by'); }
public function messages()   { return $this->hasMany(DiscussionMessage::class, 'fk_id_user'); }
```

---

### 2. SchoolClass (table: classes)

```php
class SchoolClass extends Model
{
    protected $table = 'classes';
    protected $primaryKey = 'id_class';
    protected $fillable = ['code_class', 'name', 'description', 'semester', 'created_by'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function users()      { return $this->belongsToMany(User::class, 'user_classes', 'fk_id_class', 'fk_id_user'); }
public function quizzes()    { return $this->belongsToMany(Quiz::class, 'quiz_classes', 'fk_id_class', 'fk_id_quiz'); }
public function discussions(){ return $this->hasMany(DiscussionRoom::class, 'fk_id_class'); }
```

---

### 3. Quiz

```php
class Quiz extends Model
{
    protected $table = 'quizzes';
    protected $primaryKey = 'id_quiz';
    protected $fillable = ['title', 'duration', 'created_by'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function classes()    { return $this->belongsToMany(SchoolClass::class, 'quiz_classes', 'fk_id_quiz', 'fk_id_class'); }
public function questions()  { return $this->hasMany(Question::class, 'fk_id_quiz'); }
public function materials()  { return $this->hasMany(MaterialQuiz::class, 'fk_id_quiz'); }
public function results()    { return $this->hasMany(ResultQuiz::class, 'fk_id_quiz'); }
```

---

### 4. Question

```php
class Question extends Model
{
    protected $table = 'questions';
    protected $primaryKey = 'id_question';
    protected $fillable = ['fk_id_quiz', 'number', 'question_text', 'point', 'fk_id_material'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function material()   { return $this->belongsTo(MaterialQuiz::class, 'fk_id_material'); }
public function choices()    { return $this->belongsToMany(AnswerChoice::class, 'question_answer_choices', 'fk_id_question', 'fk_id_answerchoice')->whereNull('fk_id_resultquiz'); }
```

---

### 5. AnswerChoice

```php
class AnswerChoice extends Model
{
    protected $table = 'answer_choices';
    protected $primaryKey = 'id_answerchoice';
    protected $fillable = ['content', 'is_correct'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function questions()  { return $this->belongsToMany(Question::class, 'question_answer_choices', 'fk_id_answerchoice', 'fk_id_question'); }
```

---

### 6. QuestionAnswerChoice

```php
class QuestionAnswerChoice extends Model
{
    protected $table = 'question_answer_choices';
    protected $primaryKey = 'id_questionanswerchoice';
    protected $fillable = ['fk_id_question', 'fk_id_answerchoice', 'is_correct', 'fk_id_resultquiz'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function question()   { return $this->belongsTo(Question::class, 'fk_id_question'); }
public function answerChoice(){ return $this->belongsTo(AnswerChoice::class, 'fk_id_answerchoice'); }
public function resultQuiz() { return $this->belongsTo(ResultQuiz::class, 'fk_id_resultquiz'); }
```

---

### 7. MaterialQuiz

```php
class MaterialQuiz extends Model
{
    protected $table = 'material_quiz';
    protected $primaryKey = 'id_material';
    protected $fillable = ['title', 'content', 'type', 'fk_id_quiz', 'fk_id_discussionroom'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function discussion() { return $this->belongsTo(DiscussionRoom::class, 'fk_id_discussionroom'); }
public function questions()  { return $this->hasMany(Question::class, 'fk_id_material'); }
```

---

### 8. ResultQuiz

```php
class ResultQuiz extends Model
{
    protected $table = 'result_quiz';
    protected $primaryKey = 'id_resultquiz';
    protected $fillable = ['fk_id_quiz', 'fk_id_user', 'score', 'status', 'started_at', 'finished_at'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function quiz()       { return $this->belongsTo(Quiz::class, 'fk_id_quiz'); }
public function user()       { return $this->belongsTo(User::class, 'fk_id_user'); }
public function details()    { return $this->hasMany(ResultQuestion::class, 'fk_id_resultquiz'); }
```

---

### 9. DiscussionRoom

```php
class DiscussionRoom extends Model
{
    protected $table = 'discussion_rooms';
    protected $primaryKey = 'id_discussionroom';
    protected $fillable = ['title', 'description', 'tag', 'status', 'created_by', 'fk_id_class', 'num_groups', 'students_per_group'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function schoolClass(){ return $this->belongsTo(SchoolClass::class, 'fk_id_class'); }
public function chatrooms()  { return $this->hasMany(ChatRoomAI::class, 'fk_id_discussionroom'); }
public function materials()  { return $this->hasMany(MaterialQuiz::class, 'fk_id_discussionroom'); }
```

---

### 10. ChatRoomAI

```php
class ChatRoomAI extends Model
{
    protected $table = 'chat_room_ai';
    protected $primaryKey = 'id_chatroomai';
    protected $fillable = ['title', 'description', 'status', 'ai_model', 'created_by', 'fk_id_class', 'fk_id_discussionroom'];
}
```

**Relationship yang SEHARUSNYA ada:**
```php
public function discussion() { return $this->belongsTo(DiscussionRoom::class, 'fk_id_discussionroom'); }
public function creator()    { return $this->belongsTo(User::class, 'created_by'); }
public function students()   { return $this->hasMany(DiscussionStudent::class, 'fk_id_chatroomai'); }
public function messages()   { return $this->hasMany(DiscussionMessage::class, 'fk_id_chatroomai'); }
public function aiMessages() { return $this->hasMany(AIMessage::class, 'fk_id_chatroomai'); }
public function summaries()  { return $this->hasMany(SummaryDiscussion::class, 'fk_id_chatroomai'); }
public function groups()     { return $this->hasMany(DiscussionGroup::class, 'fk_id_chatroomai'); }
public function questions()  { return $this->hasMany(DiscussionQuestion::class, 'fk_id_chatroomai'); }
```

---

### 11. DiscussionStudent (SATU-SATUNYA yang punya relationship)

```php
class DiscussionStudent extends Model
{
    protected $table = 'discussion_students';
    protected $primaryKey = 'id_discussionstudent';
    protected $fillable = ['fk_id_chatroomai', 'fk_id_user'];

    public function user()       { return $this->belongsTo(User::class, 'fk_id_user', 'id_user'); }
    public function chatRoomAI() { return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai', 'id_chatroomai'); }
}
```

---

### 12-19. Models Lainnya (Tanpa Relationship)

| Model | Table | Fillable | Relationship |
|---|---|---|---|
| UserClass | user_classes | fk_id_user, fk_id_class, role, joined_at | ❌ Tidak ada |
| ApiToken | api_tokens | user_id, token | ❌ Tidak ada |
| QuizClass | quiz_classes | fk_id_quiz, fk_id_class | ❌ Tidak ada |
| QuizStudent | quiz_students | fk_id_quiz, fk_id_class, fk_id_user | ❌ Tidak ada |
| DiscussionMessage | discussion_messages | fk_id_chatroomai, fk_id_user, role, content, content_type, status, response_meta | ❌ Tidak ada |
| AIMessage | ai_messages | fk_id_chatroomai, role, content, content_type, status, response_meta | ❌ Tidak ada |
| DiscussionGroup | discussion_groups | fk_id_chatroomai, group_no, fk_id_user, user_name | ❌ Tidak ada |
| DiscussionQuestion | discussion_questions | fk_id_chatroomai, fk_id_user, content | ❌ Tidak ada |
| SummaryDiscussion | summary_discussions | content, fk_id_user, fk_id_chatroomai | ❌ Tidak ada |
| ResultUnderstanding | result_understandings | type, fk_id_summarydiscussion | ❌ Tidak ada |

---

## Model yang Sebaiknya Dihapus

| Model | Alasan |
|---|---|
| `QuizStudent` | Tidak digunakan oleh controller manapun |

## Model yang Sebaiknya Ditambah

| Model | Kegunaan |
|---|---|
| `ResultQuestion` | Sudah ada migration tapi belum ada model Eloquent |

---

## Ringkasan Relationship yang Hilang

Total relationship yang seharusnya ada tapi belum diimplementasi: **~40 relationship**

Ini menyebabkan:
- Query yang seharusnya 1 baris (`$quiz->questions`) menjadi 3-5 baris manual query
- Kode yang verbose dan sulit dibaca
- Tidak bisa pakai eager loading (`with()`) untuk optimasi N+1
