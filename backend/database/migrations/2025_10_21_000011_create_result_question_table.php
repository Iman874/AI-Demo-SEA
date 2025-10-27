<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('result_question')) {
            Schema::create('result_question', function (Blueprint $table) {
                $table->id('id_resultquestion');
                $table->unsignedBigInteger('fk_id_resultquiz');
                $table->unsignedBigInteger('fk_id_question');
                $table->unsignedBigInteger('selected_choice_id')->nullable();
                $table->unsignedBigInteger('correct_choice_id')->nullable();
                $table->boolean('is_correct')->default(false);
                $table->integer('point')->default(0);
                $table->timestamps();

                if (Schema::hasTable('result_quiz')) {
                    $table->foreign('fk_id_resultquiz')->references('id_resultquiz')->on('result_quiz')->cascadeOnDelete();
                }
                if (Schema::hasTable('questions')) {
                    $table->foreign('fk_id_question')->references('id_question')->on('questions')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('result_question');
    }
};
