<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiscussionStudent extends Model
{
    use HasFactory;

    protected $table = 'discussion_students';
    protected $primaryKey = 'id_discussionstudent';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_chatroomai',
        'fk_id_user',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'fk_id_user', 'id_user');
    }

    public function chatRoomAI()
    {
        return $this->belongsTo(ChatRoomAI::class, 'fk_id_chatroomai', 'id_chatroomai');
    }
}
