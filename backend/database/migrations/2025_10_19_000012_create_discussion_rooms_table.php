<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('discussion_rooms')) {
            Schema::create('discussion_rooms', function (Blueprint $table) {
                $table->id('id_discussionroom');
                $table->string('title');
                $table->text('description')->nullable();
                $table->string('tag')->nullable();
                $table->enum('status', ['open', 'closed'])->default('open');
                $table->unsignedBigInteger('created_by')->nullable();
                $table->unsignedBigInteger('fk_id_class');
                $table->timestamps();

                if (Schema::hasTable('users')) {
                    $table->foreign('created_by')->references('id_user')->on('users')->nullOnDelete();
                }
                if (Schema::hasTable('classes')) {
                    $table->foreign('fk_id_class')->references('id_class')->on('classes')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('discussion_rooms');
    }
};
