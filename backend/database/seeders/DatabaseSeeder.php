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

        /*

        // Create 1 quiz for Basic Electronics with 10 questions (English)
        $quiz = Quiz::firstOrCreate([
            'title' => 'Basic Electronics Quiz'
        ], [
            'duration' => 30,
            'created_by' => $teacher->id_user ?? $teacher->id ?? null,
        ]);

        // link quiz to class
        QuizClass::firstOrCreate([
            'fk_id_quiz' => $quiz->id_quiz,
            'fk_id_class' => $class->id_class,
        ], [
            'fk_id_quiz' => $quiz->id_quiz,
            'fk_id_class' => $class->id_class,
        ]);

        // material for quiz
        $material = MaterialQuiz::firstOrCreate([
            'title' => 'Basic Electronics - Overview'
        ], [
            'content' => "This material covers basic electronic concepts: voltage, current, resistance, Ohm's law, series and parallel circuits, passive components (resistors, capacitors, inductors).",
            'type' => 'text',
            'fk_id_discussionroom' => null,
        ]);

        // Ten English questions about basic electronics
        $questionsData = [
            ['text' => 'What is the unit of electric current?', 'point' => 5, 'correct' => 'Ampere'],
            ["text" => "Ohm's law relates voltage (V), current (I) and what other quantity?", 'point' => 5, 'correct' => 'Resistance'],
            ['text' => 'Which component stores electric charge?', 'point' => 5, 'correct' => 'Capacitor'],
            ['text' => 'What is the unit of resistance?', 'point' => 5, 'correct' => 'Ohm'],
            ['text' => 'In a series circuit, the current is ______ across components.', 'point' => 5, 'correct' => 'the same'],
            ['text' => 'A resistor with higher resistance will allow how much current compared to lower resistance under same voltage?', 'point' => 5, 'correct' => 'less current'],
            ['text' => 'Which device converts electrical energy into mechanical motion?', 'point' => 5, 'correct' => 'Motor'],
            ['text' => 'What does LED stand for?', 'point' => 5, 'correct' => 'Light Emitting Diode'],
            ['text' => 'Which instrument measures voltage?', 'point' => 5, 'correct' => 'Voltmeter'],
            ['text' => 'In parallel circuits, the total resistance is _____ than the smallest branch resistance.', 'point' => 5, 'correct' => 'smaller']
        ];

        foreach ($questionsData as $idx => $qd) {
            $qnum = $idx + 1;
            $question = Question::firstOrCreate([
                'fk_id_quiz' => $quiz->id_quiz,
                'number' => $qnum,
            ], [
                'question_text' => $qd['text'],
                'point' => $qd['point'],
                'fk_id_material' => $material->id_material ?? $material->id ?? null,
            ]);

            // create 4 answer choices; place correct answer as first then add 3 distractors
            $correct = $qd['correct'];
            $distractors = ['Option A', 'Option B', 'Option C'];
            $choices = array_merge([$correct], $distractors);
            foreach ($choices as $ci => $choiceText) {
                $isCorrect = ($ci === 0);
                $choice = AnswerChoice::firstOrCreate([
                    'content' => $choiceText
                ], [
                    'is_correct' => $isCorrect ? 1 : 0,
                ]);

                QuestionAnswerChoice::firstOrCreate([
                    'fk_id_question' => $question->id_question,
                    'fk_id_answerchoice' => $choice->id_answerchoice,
                ], [
                    'is_correct' => $isCorrect ? 1 : 0,
                ]);
            }
        }

        // create one discussion room about Basic Electronics and one chatroom with sample messages
        $discussion = DiscussionRoom::firstOrCreate([
            'title' => 'Basic Electronics - Resistors and Ohm\'s Law',
        ], [
            'description' => 'Discussion about resistors, Ohm\'s law and simple circuits',
            'tag' => 'electronics',
            'status' => 'open',
            'created_by' => $teacher->id_user ?? $teacher->id ?? null,
            'fk_id_class' => $class->id_class,
        ]);

        $chat = ChatRoomAI::firstOrCreate([
            'fk_id_discussionroom' => $discussion->id_discussionroom
        ], [
            'title' => 'Basic Electronics AI Room',
            'description' => 'AI assisted discussion for Basic Electronics',
            'status' => 'active',
            'ai_model' => 'gemini-2.0-flash',
            'created_by' => $teacher->id_user ?? $teacher->id ?? null,
            'fk_id_class' => $class->id_class,
            'fk_id_discussionroom' => $discussion->id_discussionroom,
        ]);

        */

    }
}
