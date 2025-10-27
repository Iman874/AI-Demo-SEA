<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizClass extends Model
{
    use HasFactory;

    protected $table = 'quiz_classes';
    protected $primaryKey = 'id_quiz_class';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_quiz',
        'fk_id_class',
    ];
}
