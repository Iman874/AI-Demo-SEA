<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizStudent extends Model
{
    use HasFactory;

    protected $table = 'quiz_students';
    protected $primaryKey = 'id_quizstudent';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_quiz',
        'fk_id_class',
        'fk_id_user',
    ];
}
