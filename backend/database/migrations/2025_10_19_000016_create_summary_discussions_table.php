<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('summary_discussions')) {
            Schema::create('summary_discussions', function (Blueprint $table) {
                $table->id('id_summarydiscussion');
                $table->text('content');
                $table->unsignedBigInteger('fk_id_user');
                $table->unsignedBigInteger('fk_id_chatroomai');
                $table->timestamps();

                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->cascadeOnDelete();
                }
                if (Schema::hasTable('chat_room_ai')) {
                    $table->foreign('fk_id_chatroomai')->references('id_chatroomai')->on('chat_room_ai')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('summary_discussions');
    }
};
