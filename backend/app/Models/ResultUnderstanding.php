<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ResultUnderstanding extends Model
{
    use HasFactory;

    protected $table = 'result_understandings';
    protected $primaryKey = 'id_resultunderstanding';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'type',
        'fk_id_summarydiscussion',
    ];
}
