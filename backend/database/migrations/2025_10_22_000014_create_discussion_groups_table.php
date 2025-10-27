<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('discussion_groups')) {
            Schema::create('discussion_groups', function (Blueprint $table) {
                $table->id('id_discussiongroup');
                $table->unsignedBigInteger('fk_id_chatroomai');
                $table->unsignedInteger('group_no');
                $table->unsignedBigInteger('fk_id_user')->nullable();
                $table->string('user_name')->nullable();
                $table->timestamps();

                if (Schema::hasTable('chat_room_ai')) {
                    $table->foreign('fk_id_chatroomai')->references('id_chatroomai')->on('chat_room_ai')->cascadeOnDelete();
                }
                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('discussion_groups');
    }
};
