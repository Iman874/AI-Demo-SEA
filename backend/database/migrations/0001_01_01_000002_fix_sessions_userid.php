<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('sessions')) {
            return;
        }

        // Add user_id column if missing
        if (!Schema::hasColumn('sessions', 'user_id')) {
            Schema::table('sessions', function (Blueprint $table) {
                $table->unsignedBigInteger('user_id')->nullable()->after('last_activity');
            });
        }

        // If old column id_user exists, copy values into user_id
        if (Schema::hasColumn('sessions', 'id_user')) {
            // copy values
            DB::statement('UPDATE `sessions` SET `user_id` = `id_user` WHERE `id_user` IS NOT NULL');

            // drop foreign and column id_user if exists
            Schema::table('sessions', function (Blueprint $table) {
                // attempt to drop foreign key if it exists
                try {
                    $table->dropForeign(['id_user']);
                } catch (\Throwable $e) {
                    // ignore if constraint not found
                }
                try {
                    $table->dropColumn('id_user');
                } catch (\Throwable $e) {
                    // ignore if column drop fails
                }
            });
        }

        // Ensure foreign key to users(id_user)
        // Add constraint if not exists
        // Note: adding foreign via Schema may error if constraint exists; we try-catch
        try {
            Schema::table('sessions', function (Blueprint $table) {
                $table->foreign('user_id')->references('id_user')->on('users')->cascadeOnDelete();
            });
        } catch (\Throwable $e) {
            // ignore - constraint may already exist
        }
    }

    public function down(): void
    {
        if (!Schema::hasTable('sessions')) {
            return;
        }

        Schema::table('sessions', function (Blueprint $table) {
            try {
                $table->dropForeign(['user_id']);
            } catch (\Throwable $e) {
                // ignore
            }
            if (Schema::hasColumn('sessions', 'user_id')) {
                try {
                    $table->dropColumn('user_id');
                } catch (\Throwable $e) {
                    // ignore
                }
            }
        });
    }
};
