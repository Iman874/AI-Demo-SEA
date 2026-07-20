# Task 5 — Database Schema Cleanup

## Deskripsi
Membersihkan skema database: memisahkan tabel `question_answer_choices` yang overloaded, menambahkan UNIQUE constraint di pivot tables, dan membuat tabel `student_answers` yang terpisah.

## Tujuan Teknis
- Buat tabel `student_answers` untuk jawaban siswa
- Hapus kolom `is_correct` dan `fk_id_resultquiz` dari `question_answer_choices`
- Tambah UNIQUE constraint di pivot tables
- Migrasi data lama dari `question_answer_choices` ke `student_answers`

## Scope
**Backend:**
- BUAT: `database/migrations/xxxx_create_student_answers_table.php`
- BUAT: `database/migrations/xxxx_cleanup_question_answer_choices_table.php`
- BUAT: `database/migrations/xxxx_add_unique_constraints_table.php`
- EDIT: `app/Models/QuestionAnswerChoice.php` (hapus overloaded fields)
- BUAT: `app/Models/StudentAnswer.php`

**Flutter:** Tidak ada perubahan

## Langkah Implementasi

### 1. Buat Tabel `student_answers`
```php
Schema::create('student_answers', function (Blueprint $table) {
    $table->id('id_studentanswer');
    $table->unsignedBigInteger('fk_id_resultquiz');
    $table->unsignedBigInteger('fk_id_question');
    $table->unsignedBigInteger('fk_id_answerchoice')->nullable();
    $table->boolean('is_correct')->default(false);
    $table->integer('point')->default(0);
    $table->timestamps();

    $table->foreign('fk_id_resultquiz')->references('id_resultquiz')->on('result_quiz')->cascadeOnDelete();
    $table->foreign('fk_id_question')->references('id_question')->on('questions')->cascadeOnDelete();
    $table->foreign('fk_id_answerchoice')->references('id_answerchoice')->on('answer_choices')->nullOnDelete();
});
```

### 2. Migrasi Data Lama
```php
// Copy data dari question_answer_choices WHERE fk_id_resultquiz IS NOT NULL
$oldData = DB::table('question_answer_choices')
    ->whereNotNull('fk_id_resultquiz')
    ->get();

foreach ($oldData as $row) {
    DB::table('student_answers')->insert([
        'fk_id_resultquiz' => $row->fk_id_resultquiz,
        'fk_id_question' => $row->fk_id_question,
        'fk_id_answerchoice' => $row->fk_id_answerchoice,
        'is_correct' => $row->is_correct,
        'point' => 0, // tidak ada di tabel lama
        'created_at' => $row->created_at,
        'updated_at' => $row->updated_at,
    ]);
}
```

### 3. Cleanup `question_answer_choices`
```php
// Hapus kolom yang tidak perlu
Schema::table('question_answer_choices', function (Blueprint $table) {
    $table->dropForeign(['fk_id_resultquiz']);
    $table->dropColumn('fk_id_resultquiz');
    $table->dropColumn('is_correct');
});
```

### 4. Tambah UNIQUE Constraint
```php
Schema::table('user_classes', function (Blueprint $table) {
    $table->unique(['fk_id_user', 'fk_id_class']);
});

Schema::table('quiz_classes', function (Blueprint $table) {
    $table->unique(['fk_id_quiz', 'fk_id_class']);
});

Schema::table('discussion_students', function (Blueprint $table) {
    $table->unique(['fk_id_chatroomai', 'fk_id_user']);
});
```

### 5. Buat Model `StudentAnswer`
```php
<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StudentAnswer extends Model
{
    protected $table = 'student_answers';
    protected $primaryKey = 'id_studentanswer';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_resultquiz',
        'fk_id_question',
        'fk_id_answerchoice',
        'is_correct',
        'point',
    ];

    public function resultQuiz()  { return $this->belongsTo(ResultQuiz::class, 'fk_id_resultquiz'); }
    public function question()    { return $this->belongsTo(Question::class, 'fk_id_question'); }
    public function answerChoice(){ return $this->belongsTo(AnswerChoice::class, 'fk_id_answerchoice'); }
}
```

### 6. Update Query di Controllers
Setelah migration, update semua query yang menggunakan `question_answer_choices` dengan `fk_id_resultquiz`:
- `QuizController::submitResult()` — gunakan `StudentAnswer` model
- `QuizController::results()` — gunakan `StudentAnswer` model
- `DatabaseSeeder` — gunakan `StudentAnswer` model

## Output yang Diharapkan
- Tabel `student_answers` terpisah dan berisi data jawaban siswa
- `question_answer_choices` hanya berisi pivot murni (question ↔ answer_choice)
- UNIQUE constraint aktif di pivot tables
- Data lama ter-migrasi dengan benar

## Dependencies
- Task 4 (Model Relationships) sebaiknya selesai duluan

## Acceptance Criteria
- [ ] Tabel `student_answers` dibuat
- [ ] Data lama ter-migrasi dari `question_answer_choices`
- [ ] Kolom `is_correct` dan `fk_id_resultquiz` dihapus dari `question_answer_choices`
- [ ] UNIQUE constraint aktif di `user_classes`, `quiz_classes`, `discussion_students`
- [ ] `StudentAnswer` model dibuat dengan relationships
- [ ] Semua query jawaban siswa menggunakan `StudentAnswer`
- [ ] `composer lint` bersih

## Estimasi: 3-4 jam
