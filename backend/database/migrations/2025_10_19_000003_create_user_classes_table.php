<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('user_classes')) {
            Schema::create('user_classes', function (Blueprint $table) {
                $table->id('id_userclass');
                $table->unsignedBigInteger('fk_id_user');
                $table->unsignedBigInteger('fk_id_class');
                $table->enum('role', ['teacher', 'student'])->default('student');
                $table->timestamp('joined_at')->nullable();
                $table->timestamps();

                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->cascadeOnDelete();
                }
                if (Schema::hasTable('classes')) {
                    $table->foreign('fk_id_class')->references('id_class')->on('classes')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('user_classes');
    }
};
