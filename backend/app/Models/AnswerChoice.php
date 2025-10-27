<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnswerChoice extends Model
{
    use HasFactory;

    protected $table = 'answer_choices';
    protected $primaryKey = 'id_answerchoice';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'content',
        'is_correct',
    ];
}
