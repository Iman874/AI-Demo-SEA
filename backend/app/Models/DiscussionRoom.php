<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DiscussionRoom extends Model
{
    use HasFactory;

    protected $table = 'discussion_rooms';
    protected $primaryKey = 'id_discussionroom';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'title',
        'description',
        'tag',
        'status',
        'created_by',
        'fk_id_class',
        // newly added group fields
        'num_groups',
        'students_per_group',
    ];

    protected $casts = [
        'num_groups' => 'integer',
        'students_per_group' => 'integer',
    ];
}
