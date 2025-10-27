<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('quizzes')) {
            Schema::create('quizzes', function (Blueprint $table) {
                $table->id('id_quiz');
                $table->string('title');
                $table->integer('duration')->nullable();
                $table->unsignedBigInteger('created_by')->nullable();
                $table->timestamps();

                if (Schema::hasTable('users')) {
                    $table->foreign('created_by')->references('id_user')->on('users')->nullOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('quizzes');
    }
};
