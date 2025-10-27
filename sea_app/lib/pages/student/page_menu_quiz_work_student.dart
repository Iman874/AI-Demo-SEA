import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/window/window_message.dart';
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    final q = _questions.isNotEmpty ? _questions[_currentIndex] : null;

    return WillPopScope(
      onWillPop: () async {
        // Show confirmation via WindowMessage
        final parentContext = context;
        final navigator = Navigator.of(parentContext);
        final confirm = await showDialog<bool>(context: navigator.context, builder: (_) => WindowMessage(
            message: 'Are you sure you want to leave the quiz? Leaving will end the quiz and your answers will be submitted. This action cannot be undone.',
            onOk: () {
              navigator.pop(true);
            },
          ));
        if (confirm == true) {
          AppLogger.i('User confirmed exit; submitting quiz');
          await _submitQuiz(auto: true);
          return true;
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              // top header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: const Color(0xFFDD6A2B),
                child: Center(
                  child: Text('Student Quiz', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Question Numbers', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_questions.length, (i) {
                              final id = _questions[i].idQuestion;
                              final answered = _answers.containsKey(id);
                              return InkWell(
                                onTap: () => _gotoQuestion(i),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: i == _currentIndex
                                        ? Colors.green
                                        : answered
                                            ? Colors.green.shade100
                                            : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(child: Text('${i + 1}')),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Question box with overlapping timer chip
                        Text('Question', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
                                ],
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (q != null) ...[
                                    Text('${q.number}. ${q.question}', style: const TextStyle(fontSize: 14)),
                                    const SizedBox(height: 12),
                                    Column(
                                      children: q.answerChoices.map((c) {
                                        return InkWell(
                                          onTap: () => _selectAnswer(q.idQuestion, c.idAnswerChoice),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                                            child: Row(
                                              children: [
                                                Radio<String>(
                                                  value: c.idAnswerChoice,
                                                  groupValue: _answers[q.idQuestion],
                                                  onChanged: (val) => _selectAnswer(q.idQuestion, val ?? ''),
                                                ),
                                                Expanded(child: Text(c.content)),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ] else
                                    const SizedBox.shrink(),
                                ],
                              ),
                            ),

                            // Timer chip positioned top-right (overlapping)
                            Positioned(
                              right: 0,
                              top: -40,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9DBED0),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 4))],
                                ),
                                child: Row(
                                  children: [
                                    Image.asset('assets/icon/clock_icon.png', width: 18, height: 18),
                                    const SizedBox(width: 8),
                                    Text(_formatTime(_remainingSeconds), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Prev / Next buttons below the card
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8A8A8A),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _currentIndex > 0 ? () => _gotoQuestion(_currentIndex - 1) : null,
                                child: const Text('Previous Question', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3E6D8F),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _currentIndex < _questions.length - 1 ? () => _gotoQuestion(_currentIndex + 1) : null,
                                child: const Text('Next Question', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () async {
                              final parentContext = context;
                              final navigator = Navigator.of(parentContext);
                              final confirm = await showDialog<bool>(context: parentContext, builder: (_) => WindowMessage(
                                    message: 'Are you sure you want to end the quiz? Your answers will be submitted and the quiz cannot be retaken.',
                                    onOk: () { navigator.pop(true); },
                                  ));
                                  if (confirm == true) await _submitQuiz();
                            },
                            child: const Text('End Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
}
