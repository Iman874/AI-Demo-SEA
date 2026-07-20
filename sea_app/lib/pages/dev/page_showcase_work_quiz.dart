import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';
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

  Widget _buildCircularTimerRing(int remainingSeconds, int totalSeconds, bool isDark) {
    final progress = (totalSeconds > 0) ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;
    final isUrgent = remainingSeconds < 300; // < 5 menit
    final timerColor = isUrgent ? AppColors.error : AppColors.studentAccent;

    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: timerColor.withValues(alpha: 0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                ),
                Icon(
                  PhosphorIconsRegular.timer,
                  size: 12,
                  color: timerColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$m:$s',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuestionNavigation({
    required int totalQuestions,
    required int currentIndex,
    required Map<String, String> answers,
    required List<Question> questions,
    required bool isDark,
    required Function(int) onSelect,
  }) {
    final answeredCount = answers.length;
    final completionRatio = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.studentAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.listNumbers,
                        size: 14,
                        color: AppColors.studentAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Navigasi Soal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.studentAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$answeredCount dari $totalQuestions Terjawab',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.studentAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          totalQuestions > 20
              ? SizedBox(
                  height: 135,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: totalQuestions,
                    itemBuilder: (context, idx) {
                      final qItem = questions[idx];
                      final isAnswered = answers.containsKey(qItem.idQuestion);
                      final isCurrent = idx == currentIndex;

                      return InkWell(
                        onTap: () => onSelect(idx),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.studentAccent
                                : (isAnswered
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : (isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC))),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.studentAccent
                                  : (isAnswered ? AppColors.success : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.studentAccent.withValues(alpha: 0.30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isCurrent
                                        ? Colors.white
                                        : (isAnswered
                                            ? AppColors.success
                                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                                  ),
                                ),
                              ),
                              if (isAnswered && !isCurrent)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: totalQuestions,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final qItem = questions[idx];
                      final isAnswered = answers.containsKey(qItem.idQuestion);
                      final isCurrent = idx == currentIndex;

                      return InkWell(
                        onTap: () => onSelect(idx),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.studentAccent
                                : (isAnswered
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : (isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC))),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent
                                  ? AppColors.studentAccent
                                  : (isAnswered ? AppColors.success : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0))),
                              width: isCurrent ? 2 : 1,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.studentAccent.withValues(alpha: 0.30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isCurrent
                                        ? Colors.white
                                        : (isAnswered
                                            ? AppColors.success
                                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                                  ),
                                ),
                              ),
                              if (isAnswered && !isCurrent)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionRatio,
                minHeight: 4,
                backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.studentAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomQuizControls({
    required int currentIndex,
    required int totalQuestions,
    required bool isDark,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
    required VoidCallback onSubmit,
  }) {
    final isLast = currentIndex == totalQuestions - 1;

    return Container(
      color: isDark ? AppColors.cardDark : Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
              ),
            ),
          ),
          child: Row(
            children: [
              // Tombol Sebelumnya
              if (currentIndex > 0)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPrevious,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.studentAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.studentAccent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              PhosphorIconsRegular.caretLeft,
                              size: 18,
                              color: AppColors.studentAccent,
                            ),
                            const SizedBox(width: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Sebelumnya',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.studentAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (currentIndex > 0) const SizedBox(width: 12),

              // Tombol Selanjutnya / Selesaikan Kuis
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLast ? onSubmit : onNext,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: isLast
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              )
                            : const LinearGradient(
                                colors: AppColors.studentGradient,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (isLast ? const Color(0xFF10B981) : AppColors.studentAccent).withValues(alpha: 0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isLast ? 'Selesaikan Kuis' : 'Selanjutnya',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isLast ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.caretRight,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _demoQuestions[_currentIndex];
    final selectedChoice = _answers[q.idQuestion];
    final totalDuration = 45 * 60;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        title: Text(
          'Showcase Kuis (Dev)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _buildCircularTimerRing(_remainingSeconds, totalDuration, isDark),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomQuizControls(
        currentIndex: _currentIndex,
        totalQuestions: _demoQuestions.length,
        isDark: isDark,
        onPrevious: () => setState(() => _currentIndex--),
        onNext: () => setState(() => _currentIndex++),
        onSubmit: () async {
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
      body: Column(
        children: [
          // STICKY TOP QUESTION NAVIGATION BAR
          _buildTopQuestionNavigation(
            totalQuestions: _demoQuestions.length,
            currentIndex: _currentIndex,
            answers: _answers,
            questions: _demoQuestions,
            isDark: isDark,
            onSelect: (idx) => setState(() => _currentIndex = idx),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teks Soal Card (Pure White)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.studentGradient,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.studentAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#SOAL ${q.number}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.studentAccent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(PhosphorIconsRegular.star, size: 12, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${q.poin} Poin',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          q.question,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Opsi Jawaban Pilihan Ganda
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.studentAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.listChecks,
                          size: 16,
                          color: AppColors.studentAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pilih Jawaban',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...q.answerChoices.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value;
                    final isSelected = selectedChoice == c.idAnswerChoice;
                    final letter = String.fromCharCode(65 + idx);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[q.idQuestion] = c.idAnswerChoice;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.studentAccent.withValues(alpha: isDark ? 0.20 : 0.08)
                                : (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.studentAccent
                                  : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.studentAccent.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.studentAccent
                                      : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.studentAccent
                                        : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                                    : Text(
                                        letter,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  c.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    height: 1.4,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.studentAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'TERPILIH',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.studentAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
