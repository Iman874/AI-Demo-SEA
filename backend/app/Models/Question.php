<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    use HasFactory;

    protected $table = 'questions';
    protected $primaryKey = 'id_question';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_quiz',
        'number',
        'question_text',
        'point',
        'fk_id_material',
    ];
}
