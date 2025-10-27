<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('answer_choices')) {
            Schema::create('answer_choices', function (Blueprint $table) {
                $table->id('id_answerchoice');
                $table->text('content');
                $table->boolean('is_correct')->default(false);
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('answer_choices');
    }
};
