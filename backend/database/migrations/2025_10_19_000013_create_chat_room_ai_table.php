<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('chat_room_ai')) {
            Schema::create('chat_room_ai', function (Blueprint $table) {
                $table->id('id_chatroomai');
                $table->string('title');
                $table->text('description')->nullable();
                $table->enum('status', ['active', 'inactive'])->default('active');
                $table->string('ai_model')->nullable();
                $table->unsignedBigInteger('created_by')->nullable();
                $table->unsignedBigInteger('fk_id_class')->nullable();
                $table->unsignedBigInteger('fk_id_discussionroom')->nullable();
                $table->timestamps();

                if (Schema::hasTable('users')) {
                    $table->foreign('created_by')->references('id_user')->on('users')->nullOnDelete();
                }
                if (Schema::hasTable('classes')) {
                    $table->foreign('fk_id_class')->references('id_class')->on('classes')->nullOnDelete();
                }
                if (Schema::hasTable('discussion_rooms')) {
                    $table->foreign('fk_id_discussionroom')->references('id_discussionroom')->on('discussion_rooms')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('chat_room_ai');
    }
};
