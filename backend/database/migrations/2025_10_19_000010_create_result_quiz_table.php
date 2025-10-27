<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('result_quiz')) {
            Schema::create('result_quiz', function (Blueprint $table) {
                $table->id('id_resultquiz');
                $table->unsignedBigInteger('fk_id_quiz');
                $table->unsignedBigInteger('fk_id_user');
                $table->float('score')->nullable();
                $table->enum('status', ['in_progress', 'finished', 'graded'])->default('in_progress');
                $table->timestamp('started_at')->nullable();
                $table->timestamp('finished_at')->nullable();
                $table->timestamps();

                if (Schema::hasTable('quizzes')) {
                    $table->foreign('fk_id_quiz')->references('id_quiz')->on('quizzes')->cascadeOnDelete();
                }
                if (Schema::hasTable('users')) {
                    $table->foreign('fk_id_user')->references('id_user')->on('users')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('result_quiz');
    }
};
