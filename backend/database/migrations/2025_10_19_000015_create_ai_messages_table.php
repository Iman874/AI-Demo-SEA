<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('ai_messages')) {
            Schema::create('ai_messages', function (Blueprint $table) {
                $table->id('id_aimessage');
                $table->unsignedBigInteger('fk_id_chatroomai');
                $table->string('role')->nullable();
                $table->text('content');
                $table->enum('content_type', ['text', 'json', 'structured'])->nullable();
                $table->enum('status', ['ok', 'failed'])->nullable();
                $table->json('response_meta')->nullable();
                $table->timestamps();

                if (Schema::hasTable('chat_room_ai')) {
                    $table->foreign('fk_id_chatroomai')->references('id_chatroomai')->on('chat_room_ai')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_messages');
    }
};
