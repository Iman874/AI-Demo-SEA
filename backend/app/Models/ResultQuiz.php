<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ResultQuiz extends Model
{
    use HasFactory;

    protected $table = 'result_quiz';
    protected $primaryKey = 'id_resultquiz';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_quiz',
        'fk_id_user',
        'score',
        'status',
        'started_at',
        'finished_at',
    ];
}
