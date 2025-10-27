<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('material_quiz')) {
            Schema::table('material_quiz', function (Blueprint $table) {
                if (!Schema::hasColumn('material_quiz', 'fk_id_quiz')) {
                    $table->unsignedBigInteger('fk_id_quiz')->nullable()->after('id_material');
                }
                if (!Schema::hasColumn('material_quiz', 'fk_id_discussionroom')) {
                    $table->unsignedBigInteger('fk_id_discussionroom')->nullable()->after('fk_id_quiz');
                }
                // Add simple indexes
                $table->index('fk_id_quiz');
                $table->index('fk_id_discussionroom');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('material_quiz')) {
            Schema::table('material_quiz', function (Blueprint $table) {
                if (Schema::hasColumn('material_quiz', 'fk_id_quiz')) {
                    $table->dropIndex(['fk_id_quiz']);
                    $table->dropColumn('fk_id_quiz');
                }
                if (Schema::hasColumn('material_quiz', 'fk_id_discussionroom')) {
                    $table->dropIndex(['fk_id_discussionroom']);
                    $table->dropColumn('fk_id_discussionroom');
                }
            });
        }
    }
};
