<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiscussionGroup extends Model
{
    use HasFactory;

    protected $table = 'discussion_groups';
    protected $primaryKey = 'id_discussiongroup';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_chatroomai',
        'group_no',
        'fk_id_user',
        'user_name',
    ];
}
