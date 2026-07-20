import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../component/window/window_confirmation.dart';
import '../../utils/app_logger.dart';

import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import 'page_menu_quiz_result_student.dart';

class PageMenuQuizWorkStudent extends StatefulWidget {
  final String quizId;
  final String title;
  final int duration; // minutes

  const PageMenuQuizWorkStudent({super.key, required this.quizId, required this.title, required this.duration});

  @override
  State<PageMenuQuizWorkStudent> createState() => _PageMenuQuizWorkStudentState();
}

class _PageMenuQuizWorkStudentState extends State<PageMenuQuizWorkStudent> {
  bool _loading = true;
  String? _error;
  List<Question> _questions = [];
  final Map<String, String> _answers = {}; // questionId -> answerChoiceId

  // timer
  Timer? _timer;
  int _remainingSeconds = 0;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration * 60;
    _fetchQuestions();
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
          _remainingSeconds -= 1;
        } else {
          _timer?.cancel();
          _submitQuiz(auto: true);
        }
      });
    });
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiService.getQuizQuestions(quizId: widget.quizId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = (body['data'] as List<dynamic>?) ?? [];
        final list = items.map((e) {
          final choices = (e['choices'] as List<dynamic>?)?.map((c) => AnswerQuestion(
                idAnswerChoice: (c['id'] ?? '').toString(),
                content: (c['content'] ?? '').toString(),
                isCorrect: (c['is_correct'] ?? false) == true,
                createAt: DateTime.now(),
                updateAt: DateTime.now(),
              ))
              .toList() ?? [];
          return Question(
            idQuestion: (e['id_question'] ?? '').toString(),
            number: (e['number'] ?? 0) as int,
            question: (e['question_text'] ?? '').toString(),
            poin: (e['point'] ?? 0) as int,
            fkIdQuiz: widget.quizId,
            fkIdMaterial: e['fk_id_material']?.toString(),
            answerChoices: choices,
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          );
        }).toList();
        setState(() {
          _questions = list;
        });
      } else {
        setState(() => _error = 'Failed to load questions (${resp.statusCode})');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectAnswer(String questionId, String choiceId) {
    setState(() {
      _answers[questionId] = choiceId;
    });
  }

  void _gotoQuestion(int idx) {
    if (idx < 0 || idx >= _questions.length) return;
    setState(() => _currentIndex = idx);
  }

  Future<void> _submitQuiz({bool auto = false}) async {
    _timer?.cancel();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final payload = {
      'fk_id_quiz': int.tryParse(widget.quizId) ?? widget.quizId,
      'fk_id_user': int.tryParse(auth.user?.id ?? '') ?? auth.user?.id,
      'answers': _answers,
      'started_at': DateTime.now().toIso8601String(),
      'finished_at': DateTime.now().toIso8601String(),
    };

    final parentContext = context;
    final navigator = Navigator.of(parentContext);
    try {
      final resp = await ApiService.submitQuizResult(payload, token: auth.token);
      if (resp.statusCode == 201) {
        if (!mounted) return;
        final body = jsonDecode(resp.body);
        final data = body['data'] ?? body;
        final int serverScore = (data['score'] ?? data['score'] ?? 0) as int;
        final perQuestion = (data['per_question'] as List<dynamic>?) ?? [];

        // Build a map of question -> selected choice from server result if available
        final serverAnswers = <String, String>{};
        for (var pq in perQuestion) {
          final qid = (pq['question_id'] ?? '').toString();
          final sel = (pq['selected_choice_id'] ?? '')?.toString() ?? '';
          if (qid.isNotEmpty && sel.isNotEmpty) serverAnswers[qid] = sel;
        }

        // If server returned per-question answers use that, otherwise fall back to local _answers
        final answersToShow = serverAnswers.isNotEmpty ? serverAnswers : _answers;

        if (!mounted) return;
        navigator.pushReplacement(MaterialPageRoute(builder: (_) => PageMenuQuizResultStudent(
          questions: _questions,
          answers: answersToShow,
          score: serverScore,
          perQuestion: perQuestion,
        )));
      } else {
        if (!auto) {
          if (!mounted) return;
          await showDialog(context: navigator.context, builder: (_) => AlertDialog(
            title: const Text('Submission failed'),
            content: Text('Server responded: ${resp.statusCode}'),
            actions: [TextButton(onPressed: () => navigator.pop(), child: const Text('OK'))],
          ));
        }
      }
    } catch (e) {
      if (!auto) {
        if (!mounted) return;
        await showDialog(context: navigator.context, builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [TextButton(onPressed: () => navigator.pop(), child: const Text('OK'))],
        ));
      }
    }
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
      padding: const EdgeInsets.all(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.studentAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Navigasi Soal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.studentAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$answeredCount dari $totalQuestions Terjawab',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.studentAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completionRatio,
              minHeight: 4,
              backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.studentAccent),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
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
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.studentAccent
                          : (isAnswered
                              ? AppColors.success.withValues(alpha: 0.15)
                              : (isDark ? AppColors.backgroundDark : Colors.grey.shade100)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.studentAccent
                            : (isAnswered ? AppColors.success : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppColors.studentAccent.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(PhosphorIconsRegular.wifiSlash, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Gagal memuat kuis: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchQuestions,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _questions.isNotEmpty ? _questions[_currentIndex] : null;
    final selectedChoice = q != null ? _answers[q.idQuestion] : null;
    final totalDuration = widget.duration * 60;

    return WillPopScope(
      onWillPop: () async {
        final parentContext = context;
        final navigator = Navigator.of(parentContext);
        final confirm = await showDialog<bool>(
          context: navigator.context,
          builder: (_) => WindowConfirmation(
            message: 'Apakah kamu yakin ingin meninggalkan kuis? Meninggalkan kuis akan mengirimkan semua jawaban yang telah kamu isi.',
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        );
        if (confirm == true) {
          AppLogger.i('User confirmed exit; submitting quiz');
          await _submitQuiz(auto: true);
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowLeft),
            onPressed: () async {
              final confirm = await showModalBottomSheet<bool>(
                context: context,
                builder: (bc) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsRegular.warningOctagon, color: AppColors.error, size: 40),
                      const SizedBox(height: 14),
                      const Text(
                        'Keluar Kuis?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kuis akan langsung dikumpulkan jika kamu keluar sekarang.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Batal',
                              onPressed: () => Navigator.of(bc).pop(false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton.primary(
                              label: 'Keluar',
                              gradientColors: AppColors.studentGradient,
                              onPressed: () => Navigator.of(bc).pop(true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              if (confirm == true) {
                await _submitQuiz(auto: true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          title: Text(
            widget.title,
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
        body: q == null
            ? const Center(child: Text('Tidak ada pertanyaan.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP QUESTION NAVIGATION BAR
                    _buildTopQuestionNavigation(
                      totalQuestions: _questions.length,
                      currentIndex: _currentIndex,
                      answers: _answers,
                      questions: _questions,
                      isDark: isDark,
                      onSelect: (idx) => _gotoQuestion(idx),
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
                      final letter = String.fromCharCode(65 + idx);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _selectAnswer(q.idQuestion, c.idAnswerChoice),
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
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
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

                    const SizedBox(height: 20),

                    // Tombol Navigasi Soal Bottom
                    Row(
                      children: [
                        if (_currentIndex > 0)
                          Expanded(
                            child: AppButton.secondary(
                              label: 'Sebelumnya',
                              icon: PhosphorIconsRegular.arrowLeft,
                              onPressed: () => _gotoQuestion(_currentIndex - 1),
                            ),
                          ),
                        if (_currentIndex > 0) const SizedBox(width: 12),
                        if (_currentIndex < _questions.length - 1)
                          Expanded(
                            child: AppButton.primary(
                              label: 'Selanjutnya',
                              icon: PhosphorIconsRegular.arrowRight,
                              gradientColors: AppColors.studentGradient,
                              onPressed: () => _gotoQuestion(_currentIndex + 1),
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
                                    message: 'Apakah kamu yakin ingin mengumpulkan kuis ini? Jawaban tidak dapat diubah kembali.',
                                    onConfirm: () => Navigator.of(dialogContext).pop(true),
                                    onCancel: () => Navigator.of(dialogContext).pop(false),
                                  ),
                                );
                                if (res == true) {
                                  await _submitQuiz();
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
