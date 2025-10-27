<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserClass extends Model
{
    use HasFactory;

    protected $table = 'user_classes';
    protected $primaryKey = 'id_userclass';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'fk_id_user',
        'fk_id_class',
        'role',
        'joined_at',
    ];
}
