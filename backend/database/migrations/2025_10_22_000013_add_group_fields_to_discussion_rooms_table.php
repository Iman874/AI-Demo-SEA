<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('discussion_rooms')) {
            Schema::table('discussion_rooms', function (Blueprint $table) {
                if (!Schema::hasColumn('discussion_rooms', 'num_groups')) {
                    $table->unsignedInteger('num_groups')->nullable()->after('tag');
                }
                if (!Schema::hasColumn('discussion_rooms', 'students_per_group')) {
                    $table->unsignedInteger('students_per_group')->nullable()->after('num_groups');
                }
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('discussion_rooms')) {
            Schema::table('discussion_rooms', function (Blueprint $table) {
                if (Schema::hasColumn('discussion_rooms', 'students_per_group')) {
                    $table->dropColumn('students_per_group');
                }
                if (Schema::hasColumn('discussion_rooms', 'num_groups')) {
                    $table->dropColumn('num_groups');
                }
            });
        }
    }
};
