<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiscussionMessage extends Model
{
    use HasFactory;

    protected $table = 'discussion_messages';
    protected $primaryKey = 'id_message';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_chatroomai',
        'fk_id_user',
        'role',
        'content',
        'content_type',
        'status',
        'response_meta',
    ];
}
