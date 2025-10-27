<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatRoomAI extends Model
{
    use HasFactory;

    protected $table = 'chat_room_ai';
    protected $primaryKey = 'id_chatroomai';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'title',
        'description',
        'status',
        'ai_model',
        'created_by',
        'fk_id_class',
        'fk_id_discussionroom',
    ];
}
