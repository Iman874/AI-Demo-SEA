<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\SchoolClass;
use Illuminate\Support\Facades\Hash;
use App\Models\DiscussionRoom;
use App\Models\ChatRoomAI;
use App\Models\DiscussionMessage;
use App\Models\AIMessage;
use App\Models\DiscussionStudent;
use App\Models\DiscussionGroup;
use App\Models\SummaryDiscussion;
use App\Models\ResultUnderstanding;
use App\Models\Quiz;
use App\Models\MaterialQuiz;
use App\Models\Question;
use App\Models\AnswerChoice;
use App\Models\QuestionAnswerChoice;
use App\Models\QuizClass;
use App\Models\QuizStudent;
use App\Models\ResultQuiz;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create 6 users (including one teacher) and 30 students
        $teacher = User::firstOrCreate([
            'email' => 'herman775@example.com'
        ], [
            'name' => 'Herman Budi Santoso',
                'password' => Hash::make('pw123'),
            'role' => 'teacher'
        ]);


        // 30 Indonesian-style students
        $studentNames = [
            'Adi Santoso','Budi Hartono','Citra Dewi','Dewi Anggraini','Eka Putra','Fajar Nugroho','Gita Pratiwi','Hendra Kurniawan','Iwan Susanto','Joko Widodo',
            'Kevin Pratama','Lina Marlina','Maya Sari','Nanda Wijaya','Oni Saputra','Putu Ardana','Rina Amelia','Sari Nurul','Teguh Prasetyo','Umi Kalsum',
            'Vina Oktaviani','Wawan Setiawan','Xavier Gunawan','Yulia Rahma','Zulfan Maulana','Agus Salim','Bayu Adi','Candra Putri','Dian Kusuma','Edo Saputra'
        ];
        $students = [];
        foreach ($studentNames as $i => $name) {
            // append 3 random digits to make email unique (e.g., adisantoso883@gmail.com)
            $rand = mt_rand(100, 999);
            $email = strtolower(str_replace(' ', '.', $name)) . $rand . '@gmail.com';
            $s = User::firstOrCreate([
                'email' => $email
            ], [
                'name' => $name,
                'password' => Hash::make('pw123'),
                'role' => 'student'
            ]);
            $students[] = $s;
        }

        // Create only one class: Basic Electronics
        $class = SchoolClass::firstOrCreate([
            'code_class' => 'ELEC001'
        ], [
            'name' => 'Basic Electronics',
            'description' => 'Introduction to Basic Electronics',
            'semester' => '1',
            'created_by' => $teacher->id_user ?? $teacher->id ?? null,
        ]);

        // Enroll all students into the single class
        foreach ($students as $stu) {
            try {
                \App\Models\UserClass::firstOrCreate([
                    'fk_id_user' => $stu->id_user ?? $stu->id ?? null,
                    'fk_id_class' => $class->id_class,
                ], [
                    'role' => 'student',
                    'joined_at' => now(),
                ]);
            } catch (\Throwable $e) {
                // skip if user_class table doesn't exist
            }
        }

       // Buat data seeder untuk Quiz
       try {
            // 1) Quiz dasar untuk kelas Basic Electronics
            $quiz = Quiz::firstOrCreate([
                'title' => 'Quiz1'
            ], [
                'duration' => 45,
                'created_by' => $teacher->id_user ?? $teacher->id ?? null,
            ]);

            // Hubungkan quiz ke kelas
            QuizClass::firstOrCreate([
                'fk_id_quiz' => $quiz->id_quiz,
                'fk_id_class' => $class->id_class,
            ]);

            // Hapus pertanyaan lama (agar idempotent) lalu isi ulang
            try {
                Question::where('fk_id_quiz', $quiz->id_quiz)->delete();
            } catch (\Throwable $_) {
                // abaikan jika belum ada
            }

            // 2) Dua materi sumber (pdf)
            $mat1 = MaterialQuiz::firstOrCreate([
                'title' => 'N.N. Bhargava- Basic Electronics and linear circuits',
                'fk_id_quiz' => $quiz->id_quiz,
            ], [
                'content' => <<<TXT
About the Authors\n... (trimmed in seeder)\nCore topics include: semiconductor physics, PN junction, diodes, BJTs, FETs, biasing, small-signal amplifiers, multistage amplifiers, power amplifiers, tuned amplifiers, feedback, oscillators, and instruments.
TXT,
                'type' => 'pdf',
            ]);

            $mat2 = MaterialQuiz::firstOrCreate([
                'title' => 'Basic-Electronics-for-Diploma',
                'fk_id_quiz' => $quiz->id_quiz,
            ], [
                'content' => <<<TXT
Basic Electronics for Diploma Students\nKey topics: Ohm's law, series/parallel circuits, basic components (R, C, L, diode, transistor), measuring instruments (multimeter, oscilloscope, LCR meter, function generator), analog vs digital, circuit symbols, and safety.
TXT,
                'type' => 'pdf',
            ]);

            // 3) Bank soal: 30 soal (15 dari materi 1, 15 dari materi 2)
            $q1 = [
                // Material 1 (electronics fundamentals)
                [
                    'text' => 'What is the majority charge carrier in an N-type semiconductor?',
                    'choices' => ['Holes', 'Electrons', 'Protons', 'Neutrons'],
                    'answer' => 'Electrons', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'The PN junction region with no free charge carriers is called the:',
                    'choices' => ['Depletion region', 'Conduction band', 'Valence band', 'Base region'],
                    'answer' => 'Depletion region', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'A forward-biased diode ideally has:',
                    'choices' => ['Zero current', 'Infinite resistance', 'Very low resistance', 'Reverse breakdown'],
                    'answer' => 'Very low resistance', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'Which transistor configuration offers the highest input impedance?',
                    'choices' => ['CE', 'CB', 'CC (emitter follower)', 'Darlington CE'],
                    'answer' => 'CC (emitter follower)', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'Thermal runaway is a concern primarily in:',
                    'choices' => ['FETs', 'BJTs', 'Diodes', 'SCRs'],
                    'answer' => 'BJTs', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'In a JFET, the channel is controlled by:',
                    'choices' => ['Base current', 'Gate-source voltage', 'Collector voltage', 'Emitter current'],
                    'answer' => 'Gate-source voltage', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'The most widely used amplifier configuration for voltage gain is:',
                    'choices' => ['CE', 'CB', 'CC', 'Common gate'],
                    'answer' => 'CE', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'Negative feedback in amplifiers generally:',
                    'choices' => ['Increases gain and distortion', 'Reduces bandwidth', 'Reduces distortion and stabilizes gain', 'Increases noise'],
                    'answer' => 'Reduces distortion and stabilizes gain', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'A Class-B push-pull amplifier primarily improves:',
                    'choices' => ['Voltage gain', 'Efficiency', 'Input impedance', 'Thermal noise'],
                    'answer' => 'Efficiency', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'A tuned voltage amplifier is typically used for:',
                    'choices' => ['Audio broadband amplification', 'Narrowband RF amplification', 'DC level shifting', 'Power line filtering'],
                    'answer' => 'Narrowband RF amplification', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'The Barkhausen criterion is associated with:',
                    'choices' => ['Rectifiers', 'Filters', 'Oscillators', 'Voltage regulators'],
                    'answer' => 'Oscillators', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'An LC oscillator typically generates:',
                    'choices' => ['Square waves', 'Triangular waves', 'Sine waves', 'Pulse trains only'],
                    'answer' => 'Sine waves', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'CRO (Cathode-Ray Oscilloscope) primarily displays:',
                    'choices' => ['Frequency only', 'Waveforms over time', 'Capacitance directly', 'Resistance directly'],
                    'answer' => 'Waveforms over time', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'The dynamic resistance of a diode is measured around:',
                    'choices' => ['Its operating point', 'Zero bias only', 'Reverse breakdown only', 'Cut-off only'],
                    'answer' => 'Its operating point', 'point' => 10, 'mat' => $mat1,
                ],
                [
                    'text' => 'Why is CE configuration widely used in amplifier circuits?',
                    'choices' => ['High input and output impedance', 'Low voltage gain', 'Good voltage gain and moderate input/output impedance', 'Only for power stages'],
                    'answer' => 'Good voltage gain and moderate input/output impedance', 'point' => 10, 'mat' => $mat1,
                ],
            ];

            $q2 = [
                // Material 2 (basic electronics diploma topics)
                [
                    'text' => 'Ohm’s law states that V =',
                    'choices' => ['I/R', 'I×R', 'R/I', 'I−R'],
                    'answer' => 'I×R', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'In a series circuit, the current through each element is:',
                    'choices' => ['Different', 'Zero', 'Same', 'Random'],
                    'answer' => 'Same', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'In a parallel circuit, the voltage across each branch is:',
                    'choices' => ['Zero', 'Same', 'Half of source', 'Inversely proportional to resistance'],
                    'answer' => 'Same', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Capacitors store energy in the:',
                    'choices' => ['Magnetic field', 'Electric field', 'Mechanical stress', 'Thermal gradient'],
                    'answer' => 'Electric field', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Inductors oppose changes in:',
                    'choices' => ['Voltage', 'Current', 'Capacitance', 'Resistance'],
                    'answer' => 'Current', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'The unit of capacitance is:',
                    'choices' => ['Ohm', 'Henry', 'Farad', 'Watt'],
                    'answer' => 'Farad', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Which device can amplify or switch electronic signals?',
                    'choices' => ['Resistor', 'Capacitor', 'Transistor', 'Diode bridge only'],
                    'answer' => 'Transistor', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'A multimeter can measure:',
                    'choices' => ['Voltage, current, and resistance', 'Only frequency', 'Only capacitance', 'Only power'],
                    'answer' => 'Voltage, current, and resistance', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'An oscilloscope is primarily used to:',
                    'choices' => ['Generate signals', 'Display waveforms', 'Measure inductance directly', 'Rectify AC'],
                    'answer' => 'Display waveforms', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Three 6Ω resistors in parallel have an equivalent resistance of:',
                    'choices' => ['18Ω', '2Ω', '3Ω', '1Ω'],
                    'answer' => '2Ω', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'If V=12V and total series resistance is 12Ω, current is:',
                    'choices' => ['0.5A', '1A', '2A', '12A'],
                    'answer' => '1A', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Diodes ideally conduct current in:',
                    'choices' => ['Both directions equally', 'Forward direction', 'Reverse direction only', 'Neither direction'],
                    'answer' => 'Forward direction', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Digital electronics deals with signals that are:',
                    'choices' => ['Continuous only', 'Discrete levels', 'Analog only', 'Random noise only'],
                    'answer' => 'Discrete levels', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Which instrument generates common waveforms like sine/square?',
                    'choices' => ['LCR meter', 'Function generator', 'Logic analyzer', 'Power supply'],
                    'answer' => 'Function generator', 'point' => 10, 'mat' => $mat2,
                ],
                [
                    'text' => 'Which safety rule is always recommended when working on circuits?',
                    'choices' => ['Work on live circuits for speed', 'Use wet hands to reduce static', 'Turn off power before working', 'Bypass fuses for testing'],
                    'answer' => 'Turn off power before working', 'point' => 10, 'mat' => $mat2,
                ],
            ];

            $allQuestions = array_merge($q1, $q2);

            // 4) Simpan pertanyaan + pilihan ganda
            $createdQuestions = [];
            foreach ($allQuestions as $idx => $qd) {
                $number = $idx + 1;
                $question = Question::create([
                    'fk_id_quiz' => $quiz->id_quiz,
                    'number' => $number,
                    'question_text' => $qd['text'],
                    'point' => $qd['point'] ?? 10,
                    'fk_id_material' => $qd['mat']->id_material,
                ]);

                $choiceIds = [];
                foreach ($qd['choices'] as $choiceText) {
                    // Buat choice untuk pertanyaan ini
                    $isCorrect = ($choiceText === $qd['answer']);
                    $ac = AnswerChoice::create([
                        'content' => $choiceText,
                        'is_correct' => $isCorrect,
                    ]);

                    // Tautkan ke pertanyaan via pivot (tanpa resultquiz)
                    QuestionAnswerChoice::create([
                        'fk_id_question' => $question->id_question,
                        'fk_id_answerchoice' => $ac->id_answerchoice,
                        'is_correct' => $isCorrect,
                        'fk_id_resultquiz' => null,
                    ]);

                    $choiceIds[] = ['id' => $ac->id_answerchoice, 'is_correct' => $isCorrect];
                }

                $createdQuestions[] = ['model' => $question, 'choices' => $choiceIds];
            }

            // 5) Tandai seluruh siswa seakan sudah mengerjakan quiz
            foreach ($students as $stu) {
                $uid = $stu->id_user ?? $stu->id ?? null;
                if (!$uid) continue;

                $result = ResultQuiz::firstOrCreate([
                    'fk_id_quiz' => $quiz->id_quiz,
                    'fk_id_user' => $uid,
                ], [
                    'status' => 'finished',
                    'started_at' => now()->subMinutes(60),
                    'finished_at' => now(),
                    'score' => 0,
                ]);

                // Jika sudah pernah terisi, hapus jawaban lama pada pivot untuk result ini
                try {
                    QuestionAnswerChoice::where('fk_id_resultquiz', $result->id_resultquiz)->delete();
                } catch (\Throwable $_) {}
                // Hapus juga detail lama di result_question bila ada agar idempotent
                try {
                    if (\Illuminate\Support\Facades\Schema::hasTable('result_question')) {
                        \Illuminate\Support\Facades\DB::table('result_question')
                            ->where('fk_id_resultquiz', $result->id_resultquiz)
                            ->delete();
                    }
                } catch (\Throwable $_) {}

                $totalScore = 0;
                foreach ($createdQuestions as $bundle) {
                    $qModel = $bundle['model'];
                    $opts = $bundle['choices'];

                    // Simulasi: 60% kemungkinan menjawab benar
                    $pickCorrect = (mt_rand(1, 100) <= 60);
                    $selected = null;
                    $correct = null;
                    if ($pickCorrect) {
                        foreach ($opts as $o) { if ($o['is_correct']) { $selected = $o; $correct = $o; break; } }
                    }
                    if (!$selected) {
                        $selected = $opts[array_rand($opts)];
                    }
                    if ($correct === null) {
                        foreach ($opts as $o) { if ($o['is_correct']) { $correct = $o; break; } }
                    }

                    // Simpan jawaban siswa pada pivot (dengan fk_id_resultquiz)
                    QuestionAnswerChoice::create([
                        'fk_id_question' => $qModel->id_question,
                        'fk_id_answerchoice' => $selected['id'],
                        'is_correct' => $selected['is_correct'] ? 1 : 0,
                        'fk_id_resultquiz' => $result->id_resultquiz,
                    ]);

                    if (!empty($selected['is_correct'])) {
                        $totalScore += (int)($qModel->point ?? 0);
                    }

                    // Tulis juga ke tabel result_question agar endpoint detail dapat menyorot pilihan
                    try {
                        if (\Illuminate\Support\Facades\Schema::hasTable('result_question')) {
                            \Illuminate\Support\Facades\DB::table('result_question')->insert([
                                'fk_id_resultquiz' => $result->id_resultquiz,
                                'fk_id_question' => $qModel->id_question,
                                'selected_choice_id' => $selected['id'] ?? null,
                                'correct_choice_id' => $correct['id'] ?? null,
                                'is_correct' => !empty($selected['is_correct']) ? 1 : 0,
                                'point' => (int)($qModel->point ?? 0),
                                'created_at' => now(),
                                'updated_at' => now(),
                            ]);
                        }
                    } catch (\Throwable $_) {}
                }

                $result->score = $totalScore;
                $result->status = 'graded';
                $result->save();

                // Tandai keikutsertaan siswa pada quiz (opsional)
                QuizStudent::firstOrCreate([
                    'fk_id_quiz' => $quiz->id_quiz,
                    'fk_id_user' => $uid,
                ], [
                    'fk_id_class' => $class->id_class,
                ]);
            }
        } catch (\Throwable $e) {
            // Jangan gagalkan seeding total bila ada masalah minor
        }

        // Buat data seeder untuk Discussion Room "Diskusi1" beserta 10 grup x 3 orang
        try {
            // 1) Discussion Room utama
            $discussion = DiscussionRoom::firstOrCreate([
                'title' => 'Diskusi1',
                'fk_id_class' => $class->id_class,
            ], [
                'description' => 'Diskusi awal untuk Basic Electronics',
                'tag' => 'electronics',
                'status' => 'open',
                'created_by' => $teacher->id_user ?? $teacher->id ?? null,
                'num_groups' => 10,
                'students_per_group' => 3,
            ]);

            // 2) Kaitkan dua material quiz sebelumnya ke discussion room (bila kolom tersedia)
            try {
                if (\Illuminate\Support\Facades\Schema::hasColumn('material_quiz', 'fk_id_discussionroom')) {
                    if (isset($mat1)) {
                        $mat1->fk_id_discussionroom = $discussion->id_discussionroom;
                        $mat1->save();
                    }
                    if (isset($mat2)) {
                        $mat2->fk_id_discussionroom = $discussion->id_discussionroom;
                        $mat2->save();
                    }
                }
            } catch (\Throwable $_) {}

            // 3) Bentuk 10 grup beranggotakan 3 mahasiswa (total 30) + teacher sebagai anggota pertama
            $numGroups = 10;
            $perGroup = 3;
            $studentPool = $students; // 30 siswa dari atas
            // urutkan stabil agar idempotent (gunakan email sebagai key)
            usort($studentPool, function($a, $b) { return strcmp(($a->email ?? ''), ($b->email ?? '')); });

            $index = 0;
            for ($g = 1; $g <= $numGroups; $g++) {
                // 3a) Buat ChatRoom AI per grup
                $chat = ChatRoomAI::firstOrCreate([
                    'title' => 'Diskusi1 - Group ' . $g,
                    'fk_id_discussionroom' => $discussion->id_discussionroom,
                ], [
                    'description' => 'Chat AI untuk grup ' . $g,
                    // chat_room_ai.status enum: ['active','inactive']
                    'status' => 'active',
                    'ai_model' => 'gemini',
                    'created_by' => $teacher->id_user ?? $teacher->id ?? null,
                    'fk_id_class' => $class->id_class,
                ]);

                // 3b) Tambah teacher sebagai anggota pertama
                DiscussionStudent::firstOrCreate([
                    'fk_id_chatroomai' => $chat->id_chatroomai,
                    'fk_id_user' => $teacher->id_user ?? $teacher->id ?? null,
                ]);

                // 3c) Pilih 3 siswa untuk grup ini
                $members = [];
                for ($k = 0; $k < $perGroup && $index < count($studentPool); $k++) {
                    $members[] = $studentPool[$index++];
                }

                // 3d) Tambahkan mahasiswa sebagai anggota chat dan tulis mapping di discussion_groups
                foreach ($members as $m) {
                    $uid = $m->id_user ?? $m->id ?? null;
                    if (!$uid) continue;
                    DiscussionStudent::firstOrCreate([
                        'fk_id_chatroomai' => $chat->id_chatroomai,
                        'fk_id_user' => $uid,
                    ]);
                    DiscussionGroup::firstOrCreate([
                        'fk_id_chatroomai' => $chat->id_chatroomai,
                        'group_no' => $g,
                        'fk_id_user' => $uid,
                    ], [
                        'user_name' => $m->name ?? '',
                    ]);
                }

                // 3e) Tambahkan teacher juga ke mapping group (sebagai fasilitator)
                DiscussionGroup::firstOrCreate([
                    'fk_id_chatroomai' => $chat->id_chatroomai,
                    'group_no' => $g,
                    'fk_id_user' => $teacher->id_user ?? $teacher->id ?? null,
                ], [
                    'user_name' => $teacher->name ?? 'Teacher',
                ]);

                // 3f) Pesan awal (opsional)
                try {
                    DiscussionMessage::firstOrCreate([
                        'fk_id_chatroomai' => $chat->id_chatroomai,
                        'fk_id_user' => $teacher->id_user ?? $teacher->id ?? null,
                        'role' => 'teacher',
                        'content' => 'Selamat datang di Diskusi1 - Group ' . $g,
                    ], [
                        'content_type' => 'text',
                        'status' => 'sent',
                    ]);
                } catch (\Throwable $_) {}
            }
        } catch (\Throwable $e) {
            // abaikan error minor untuk bagian diskusi
        }

        // Tambahkan seeding ringkasan diskusi & hasil pemahaman (custom distribution)
        try {
            $this->call(DiscussionResultSeeder::class);
        } catch (\Throwable $_) {
            // jangan gagalkan keseluruhan seeding bila terjadi error minor
        }
    }
}
