<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('quiz_students')) {
            Schema::create('quiz_students', function (Blueprint $table) {
                $table->id('id_quizstudent');
                $table->unsignedBigInteger('fk_id_quiz');
                $table->unsignedBigInteger('fk_id_class')->nullable();
                $table->unsignedBigInteger('fk_id_user');
                $table->timestamps();

                if (Schema::hasTable('quizzes')) {
                    $table->foreign('fk_id_quiz')->references('id_quiz')->on('quizzes')->cascadeOnDelete();
                }
                if (Schema::hasTable('classes')) {
                    $table->foreign('fk_id_class')->references('id_class')->on('classes')->nullOnDelete();
                }
                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('quiz_students');
    }
};
