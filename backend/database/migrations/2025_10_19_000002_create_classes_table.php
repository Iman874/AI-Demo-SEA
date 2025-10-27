<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('classes')) {
            Schema::create('classes', function (Blueprint $table) {
                $table->id('id_class');
                $table->string('code_class')->unique();
                $table->string('name');
                $table->text('description')->nullable();
                $table->string('semester')->nullable();
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
        Schema::dropIfExists('classes');
    }
};
