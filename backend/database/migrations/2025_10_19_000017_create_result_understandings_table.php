<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('result_understandings')) {
            Schema::create('result_understandings', function (Blueprint $table) {
                $table->id('id_resultunderstanding');
                $table->string('type')->nullable();
                $table->unsignedBigInteger('fk_id_summarydiscussion');
                $table->timestamps();

                if (Schema::hasTable('summary_discussions')) {
                    $table->foreign('fk_id_summarydiscussion')->references('id_summarydiscussion')->on('summary_discussions')->cascadeOnDelete();
                }
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('result_understandings');
    }
};
