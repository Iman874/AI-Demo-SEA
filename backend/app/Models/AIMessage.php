<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AIMessage extends Model
{
    use HasFactory;

    protected $table = 'ai_messages';
    protected $primaryKey = 'id_aimessage';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_chatroomai',
        'role',
        'content',
        'content_type',
        'status',
        'response_meta',
    ];
}
