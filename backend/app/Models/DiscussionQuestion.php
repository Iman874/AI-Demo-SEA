<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DiscussionQuestion extends Model
{
    protected $table = 'discussion_questions';
    protected $primaryKey = 'id_discussionquestion';
    public $timestamps = true;
    protected $fillable = ['fk_id_chatroomai','fk_id_user','content'];
}
