<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('quiz_classes')) {
            Schema::create('quiz_classes', function (Blueprint $table) {
                $table->id('id_quiz_class');
                $table->unsignedBigInteger('fk_id_quiz');
                $table->unsignedBigInteger('fk_id_class');
                $table->timestamps();

                if (Schema::hasTable('quizzes')) {
                    $table->foreign('fk_id_quiz')->references('id_quiz')->on('quizzes')->cascadeOnDelete();
                }
                if (Schema::hasTable('classes')) {
                    $table->foreign('fk_id_class')->references('id_class')->on('classes')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('quiz_classes');
    }
};
