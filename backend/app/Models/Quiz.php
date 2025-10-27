<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Quiz extends Model
{
    use HasFactory;

    protected $table = 'quizzes';
    protected $primaryKey = 'id_quiz';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'title',
        'duration',
        'created_by',
    ];
}
