<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('discussion_messages')) {
            Schema::create('discussion_messages', function (Blueprint $table) {
                $table->id('id_message');
                $table->unsignedBigInteger('fk_id_chatroomai');
                $table->unsignedBigInteger('fk_id_user');
                $table->enum('role', ['student', 'teacher'])->nullable();
                $table->text('content');
                $table->enum('content_type', ['text', 'image', 'file'])->nullable();
                $table->enum('status', ['sent', 'deleted', 'edited'])->default('sent');
                $table->json('response_meta')->nullable();
                $table->timestamps();

                if (Schema::hasTable('chat_room_ai')) {
                    $table->foreign('fk_id_chatroomai')->references('id_chatroomai')->on('chat_room_ai')->cascadeOnDelete();
                }
                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('discussion_messages');
    }
};
