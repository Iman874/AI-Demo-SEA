<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuestionAnswerChoice extends Model
{
    use HasFactory;

    protected $table = 'question_answer_choices';
    protected $primaryKey = 'id_questionanswerchoice';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_question',
        'fk_id_answerchoice',
        'is_correct',
        'fk_id_resultquiz',
    ];
}
