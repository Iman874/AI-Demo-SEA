<?php

namespace Database\Seeders;

use App\Models\ApiToken;
use App\Models\SchoolClass;
use App\Models\User;
use App\Models\UserClass;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DevUserSeeder extends Seeder
{
    /**
     * Run the dev user seeds.
     */
    public function run(): void
    {
        // 1. Guru Demo
        $teacher = User::firstOrCreate([
            'email' => 'guru@demo.com',
        ], [
            'name' => 'Budi Santoso, M.Pd (Guru Demo)',
            'password' => Hash::make('password123'),
            'role' => 'teacher',
        ]);

        // Token untuk Guru Demo
        ApiToken::firstOrCreate([
            'user_id' => $teacher->id_user ?? $teacher->id,
            'token' => 'dev-token-guru-demo-12345',
        ], [
            'expires_at' => now()->addYears(5),
        ]);

        // 2. Siswa Demo List
        $studentDemos = [
            [
                'email' => 'siswa1@demo.com',
                'name' => 'Ani Wijaya (Siswa Demo 1)',
                'token' => 'dev-token-siswa1-demo-12345',
            ],
            [
                'email' => 'siswa2@demo.com',
                'name' => 'Budi Pratama (Siswa Demo 2)',
                'token' => 'dev-token-siswa2-demo-12345',
            ],
            [
                'email' => 'siswa3@demo.com',
                'name' => 'Citra Dewi (Siswa Demo 3)',
                'token' => 'dev-token-siswa3-demo-12345',
            ],
        ];

        // Dapatkan kelas utama
        $class = SchoolClass::where('code_class', 'ELEC001')->first();
        if (! $class) {
            $class = SchoolClass::firstOrCreate([
                'code_class' => 'ELEC001',
            ], [
                'name' => 'Basic Electronics',
                'description' => 'Introduction to Basic Electronics',
                'semester' => '1',
                'created_by' => $teacher->id_user ?? $teacher->id,
            ]);
        }

        // Hubungkan Guru ke kelas
        try {
            UserClass::firstOrCreate([
                'fk_id_user' => $teacher->id_user ?? $teacher->id,
                'fk_id_class' => $class->id_class,
            ], [
                'role' => 'teacher',
                'joined_at' => now(),
            ]);
        } catch (\Throwable $e) {
        }

        foreach ($studentDemos as $sData) {
            $student = User::firstOrCreate([
                'email' => $sData['email'],
            ], [
                'name' => $sData['name'],
                'password' => Hash::make('password123'),
                'role' => 'student',
            ]);

            // Token untuk Siswa Demo
            ApiToken::firstOrCreate([
                'user_id' => $student->id_user ?? $student->id,
                'token' => $sData['token'],
            ], [
                'expires_at' => now()->addYears(5),
            ]);

            // Hubungkan Siswa ke kelas
            try {
                UserClass::firstOrCreate([
                    'fk_id_user' => $student->id_user ?? $student->id,
                    'fk_id_class' => $class->id_class,
                ], [
                    'role' => 'student',
                    'joined_at' => now(),
                ]);
            } catch (\Throwable $e) {
            }
        }
    }
}
