<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('question_answer_choices')) {
            Schema::create('question_answer_choices', function (Blueprint $table) {
                $table->id('id_questionanswerchoice');
                $table->unsignedBigInteger('fk_id_question');
                $table->unsignedBigInteger('fk_id_answerchoice');
                $table->boolean('is_correct')->default(false);
                $table->unsignedBigInteger('fk_id_resultquiz')->nullable();
                $table->timestamps();

                if (Schema::hasTable('questions')) {
                    $table->foreign('fk_id_question')->references('id_question')->on('questions')->cascadeOnDelete();
                }
                if (Schema::hasTable('answer_choices')) {
                    $table->foreign('fk_id_answerchoice')->references('id_answerchoice')->on('answer_choices')->cascadeOnDelete();
                }
                if (Schema::hasTable('result_quiz')) {
                    $table->foreign('fk_id_resultquiz')->references('id_resultquiz')->on('result_quiz')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('question_answer_choices');
    }
};
