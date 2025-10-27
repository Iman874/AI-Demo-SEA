<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('material_quiz')) {
            Schema::create('material_quiz', function (Blueprint $table) {
                $table->id('id_material');
                $table->string('title');
                $table->text('content');
                $table->enum('type', ['text', 'pdf', 'image', 'video'])->nullable();
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('material_quiz');
    }
};
