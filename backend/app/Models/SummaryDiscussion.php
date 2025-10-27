<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SummaryDiscussion extends Model
{
    use HasFactory;

    protected $table = 'summary_discussions';
    protected $primaryKey = 'id_summarydiscussion';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'content',
        'fk_id_user',
        'fk_id_chatroomai',
    ];
}
