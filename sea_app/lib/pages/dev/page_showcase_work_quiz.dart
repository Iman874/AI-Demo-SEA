import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../component/window/window_confirmation.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../student/page_menu_quiz_result_student.dart';

class PageShowcaseWorkQuiz extends StatefulWidget {
  const PageShowcaseWorkQuiz({super.key});

  @override
  State<PageShowcaseWorkQuiz> createState() => _PageShowcaseWorkQuizState();
}

class _PageShowcaseWorkQuizState extends State<PageShowcaseWorkQuiz> {
  int _remainingSeconds = 45 * 60; // 45 menit
  Timer? _timer;
  int _currentIndex = 0;
  final Map<String, String> _answers = {};

  final List<Question> _demoQuestions = [
    Question(
      idQuestion: 'q_demo_1',
      number: 1,
      question: 'Manakah dari komponen berikut yang berfungsi untuk membatasi arus listrik dalam rangkaian elektronik?',
      poin: 20,
      fkIdQuiz: 'quiz_demo',
      answerChoices: [
        AnswerQuestion(idAnswerChoice: 'c1_1', content: 'Resistor', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c1_2', content: 'Kapasitor', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c1_3', content: 'Induktor', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c1_4', content: 'Dioda', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
      ],
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    ),
    Question(
      idQuestion: 'q_demo_2',
      number: 2,
      question: 'Hukum Ohm menyatakan hubungan antara tegangan (V), arus (I), dan hambatan (R). Rumus yang tepat adalah:',
      poin: 20,
      fkIdQuiz: 'quiz_demo',
      answerChoices: [
        AnswerQuestion(idAnswerChoice: 'c2_1', content: 'V = I * R', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c2_2', content: 'V = I / R', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c2_3', content: 'I = V * R', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c2_4', content: 'R = V * I', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
      ],
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    ),
    Question(
      idQuestion: 'q_demo_3',
      number: 3,
      question: 'Komponen yang digunakan untuk menyimpan muatan listrik sementara adalah:',
      poin: 20,
      fkIdQuiz: 'quiz_demo',
      answerChoices: [
        AnswerQuestion(idAnswerChoice: 'c3_1', content: 'Kapasitor', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c3_2', content: 'Transistor', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c3_3', content: 'Relay', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c3_4', content: 'Transformator', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
      ],
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    ),
    Question(
      idQuestion: 'q_demo_4',
      number: 4,
      question: 'Komponen semikonduktor yang hanya mengalirkan arus listrik dalam satu arah saja adalah:',
      poin: 20,
      fkIdQuiz: 'quiz_demo',
      answerChoices: [
        AnswerQuestion(idAnswerChoice: 'c4_1', content: 'Dioda', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c4_2', content: 'Fuse', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c4_3', content: 'Resistor Variabel', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c4_4', content: 'LDR (Light Dependent Resistor)', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
      ],
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    ),
    Question(
      idQuestion: 'q_demo_5',
      number: 5,
      question: 'Satuan internasional (SI) untuk mengukur besarnya nilai hambatan listrik adalah:',
      poin: 20,
      fkIdQuiz: 'quiz_demo',
      answerChoices: [
        AnswerQuestion(idAnswerChoice: 'c5_1', content: 'Ohm (Ω)', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c5_2', content: 'Ampere (A)', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c5_3', content: 'Volt (V)', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
        AnswerQuestion(idAnswerChoice: 'c5_4', content: 'Farad (F)', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
      ],
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submitQuizDemo() {
    int totalScore = 0;
    for (var q in _demoQuestions) {
      final selectedChoiceId = _answers[q.idQuestion];
      if (selectedChoiceId != null) {
        final choice = q.answerChoices.firstWhere(
          (c) => c.idAnswerChoice == selectedChoiceId,
          orElse: () => q.answerChoices.first,
        );
        if (choice.isCorrect) {
          totalScore += q.poin;
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PageMenuQuizResultStudent(
          questions: _demoQuestions,
          answers: _answers,
          score: totalScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _demoQuestions[_currentIndex];
    final selectedChoice = _answers[q.idQuestion];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Showcase Pengerjaan Kuis (Dev Mode)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Soal ${_currentIndex + 1} dari ${_demoQuestions.length}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          // Timer Widget
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsRegular.timer, size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_remainingSeconds),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Indicator Panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.studentAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Soal #${q.number}',
                      style: const TextStyle(
                        color: AppColors.studentAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${q.poin} Poin',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Teks Soal Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                q.question,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Opsi Jawaban Pilihan Ganda
            const Text(
              'Pilih Jawaban:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            ...q.answerChoices.asMap().entries.map((entry) {
              final idx = entry.key;
              final c = entry.value;
              final isSelected = selectedChoice == c.idAnswerChoice;
              final letter = String.fromCharCode(65 + idx); // A, B, C, D...

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _answers[q.idQuestion] = c.idAnswerChoice;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.studentAccent.withValues(alpha: isDark ? 0.25 : 0.10)
                          : (isDark ? AppColors.cardDark : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.studentAccent
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.studentAccent : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.studentAccent
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c.content,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Tombol Navigasi Soal Bottom
            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Sebelumnya',
                      icon: PhosphorIconsRegular.arrowLeft,
                      onPressed: () {
                        setState(() => _currentIndex--);
                      },
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                if (_currentIndex < _demoQuestions.length - 1)
                  Expanded(
                    child: AppButton.primary(
                      label: 'Selanjutnya',
                      icon: PhosphorIconsRegular.arrowRight,
                      gradientColors: AppColors.studentGradient,
                      onPressed: () {
                        setState(() => _currentIndex++);
                      },
                    ),
                  )
                else
                  Expanded(
                    child: AppButton.primary(
                      label: 'Selesaikan Kuis',
                      icon: PhosphorIconsRegular.checkCircle,
                      gradientColors: AppColors.studentGradient,
                      onPressed: () async {
                        final res = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => WindowConfirmation(
                            message: 'Apakah kamu yakin ingin mengumpulkan kuis demo ini?',
                            onConfirm: () => Navigator.of(dialogContext).pop(true),
                            onCancel: () => Navigator.of(dialogContext).pop(false),
                          ),
                        );
                        if (res == true) {
                          _submitQuizDemo();
                        }
                      },
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Grid Navigasi Nomor Soal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Navigasi Nomor Soal:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_demoQuestions.length, (idx) {
                      final qItem = _demoQuestions[idx];
                      final isAnswered = _answers.containsKey(qItem.idQuestion);
                      final isCurrent = idx == _currentIndex;

                      return InkWell(
                        onTap: () => setState(() => _currentIndex = idx),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.studentAccent
                                : (isAnswered
                                    ? AppColors.success.withValues(alpha: 0.20)
                                    : (isDark ? AppColors.backgroundDark : Colors.grey.shade100)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.studentAccent
                                  : (isAnswered ? AppColors.success : Colors.grey.shade300),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? Colors.white
                                  : (isAnswered
                                      ? AppColors.success
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
