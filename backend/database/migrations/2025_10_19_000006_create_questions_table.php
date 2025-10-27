<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('questions')) {
            Schema::create('questions', function (Blueprint $table) {
                $table->id('id_question');
                $table->unsignedBigInteger('fk_id_quiz');
                $table->integer('number');
                $table->text('question_text');
                $table->integer('point')->default(0);
                $table->unsignedBigInteger('fk_id_material')->nullable();
                $table->timestamps();

                if (Schema::hasTable('quizzes')) {
                    $table->foreign('fk_id_quiz')->references('id_quiz')->on('quizzes')->cascadeOnDelete();
                }
                if (Schema::hasTable('material_quiz')) {
                    $table->foreign('fk_id_material')->references('id_material')->on('material_quiz')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
