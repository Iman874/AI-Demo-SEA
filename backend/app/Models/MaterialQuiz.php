<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MaterialQuiz extends Model
{
    use HasFactory;

    protected $table = 'material_quiz';
    protected $primaryKey = 'id_material';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'title',
        'content',
        'type',
        'fk_id_quiz',
        'fk_id_discussionroom',
    ];
}
