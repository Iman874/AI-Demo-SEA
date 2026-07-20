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

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Soal ${_currentIndex + 1} dari ${_questions.length}',
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
                    _formatTime(_remainingSeconds),
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
        body: q == null
            ? const Center(child: Text('Tidak ada pertanyaan.'))
            : SingleChildScrollView(
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
                          fontSize: 15,
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
                          onTap: () => _selectAnswer(q.idQuestion, c.idAnswerChoice),
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
                            children: List.generate(_questions.length, (idx) {
                              final qItem = _questions[idx];
                              final isAnswered = _answers.containsKey(qItem.idQuestion);
                              final isCurrent = idx == _currentIndex;

                              return InkWell(
                                onTap: () => _gotoQuestion(idx),
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
      ),
    );
  }
}
