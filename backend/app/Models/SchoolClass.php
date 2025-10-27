<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SchoolClass extends Model
{
    use HasFactory;

    protected $table = 'classes';
    protected $primaryKey = 'id_class';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'code_class',
        'name',
        'description',
        'semester',
        'created_by',
    ];
}
