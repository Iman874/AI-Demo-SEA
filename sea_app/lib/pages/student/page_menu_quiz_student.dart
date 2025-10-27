import 'package:flutter/material.dart';
import '../../component/card/card_quiz.dart';
import '../../models/quiz.dart';
// imports for quiz_student and user removed: this page is API-only and no longer uses local dummy data
import '../../models/class.dart';
// user_class removed
import '../../services/api_service.dart';
import 'page_menu_quiz_work_student.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import 'page_menu_quiz_result_student.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PageMenuQuizStudent extends StatefulWidget {
  const PageMenuQuizStudent({super.key});

  @override
  State<PageMenuQuizStudent> createState() => _PageMenuQuizStudentState();
}

class _PageMenuQuizStudentState extends State<PageMenuQuizStudent> {
  late List<ClassModel> studentClasses;
  late String selectedClassId;

  @override
  void initState() {
    super.initState();
    studentClasses = [];
    selectedClassId = '';
    _loadClasses();
    // Register listener synchronously (listen: false is safe in initState)
    Provider.of<AuthProvider>(context, listen: false).addListener(_authListener);
  }

  void _authListener() {
    if (mounted) _loadClasses();
  }

  @override
  void dispose() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      auth.removeListener(_authListener);
    } catch (_) {}
    super.dispose();
  }

  // removed local cache of all classes
  bool _loading = true;
  String? _error;
  List<Quiz> _activeQuizzes = [];
  List<Quiz> _completedQuizzes = [];

  Future<void> _loadClasses() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Use explicit user-id based API to fetch classes related to this student
      String? userId = auth.user?.id;
      final idResp = await ApiService.getUserClassIds(token: auth.token, userId: userId);
      if (idResp.statusCode == 200) {
        final idBody = jsonDecode(idResp.body);
        final ids = ((idBody['data'] as List<dynamic>?) ?? []).map((e) => e.toString()).toSet();
        if (ids.isNotEmpty) {
          final classesResp = await ApiService.getClasses();
          if (classesResp.statusCode == 200) {
            final clsBody = jsonDecode(classesResp.body);
            final itemsAll = clsBody['data'] as List<dynamic>? ?? [];
            final all = itemsAll.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
            studentClasses = all.where((c) => ids.contains(c.idClass)).toList();
            selectedClassId = studentClasses.isNotEmpty ? studentClasses.first.idClass : '';
            // load quizzes for the selected class
            if (selectedClassId.isNotEmpty) await _loadQuizzesForClass(selectedClassId);
          }
        } else {
          studentClasses = [];
          selectedClassId = '';
        }
      } else {
        studentClasses = [];
        selectedClassId = '';
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
  // Quizzes loaded from server for the selected class
  final activeQuizzes = _activeQuizzes;
  final completedQuizzes = _completedQuizzes;

    final hasClass = studentClasses.isNotEmpty;
    final dropdownValue = hasClass && studentClasses.any((c) => c.idClass == selectedClassId)
        ? selectedClassId
        : (hasClass ? studentClasses.first.idClass : null);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown kelas yang diikuti student
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  "Select Class",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // gunakan warna dari theme
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      borderRadius: BorderRadius.circular(14),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      items: hasClass
                          ? studentClasses.map((c) {
                              return DropdownMenuItem(
                                value: c.idClass,
                                child: Text(c.name),
                              );
                            }).toList()
                          : [],
                      onChanged: hasClass
                          ? (val) async {
                              if (val != null) {
                                setState(() => selectedClassId = val);
                                await _loadQuizzesForClass(val);
                                if (mounted) setState(() {});
                              }
                            }
                          : null,
                      hint: const Text("No class available"),
                    ),
                  ),
                ),
              ),
              // Active Quizzes
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  "Active Quizzes",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardQuizList(
                quizzes: activeQuizzes,
                onViewResult: (quiz) async {
                  // navigate to quiz work page
                  final navigator = Navigator.of(context);
                  final didFinish = await navigator.push(MaterialPageRoute(builder: (_) => PageMenuQuizWorkStudent(
                    quizId: quiz.idQuiz,
                    title: quiz.title,
                    duration: quiz.duration,
                  )));
                  if (didFinish == true) {
                    if (!mounted) return;
                    // refresh quizzes list
                    await _loadQuizzesForClass(selectedClassId);
                    if (mounted) setState(() {});
                  }
                },
                buttonLabel: "Start Quiz",
              ),
              // Completed Quizzes
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  "Completed Quizzes",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardQuizList(
                quizzes: completedQuizzes,
                onViewResult: (quiz) async {
                  // fetch detailed result and questions, then navigate to result page
                  final navigator = Navigator.of(context);
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final token = auth.token;
                  try {
                    final detailResp = await ApiService.getQuizResultDetails(userId: auth.user?.id ?? '', quizId: quiz.idQuiz, token: token);
                    if (detailResp.statusCode == 200) {
                      final body = jsonDecode(detailResp.body);
                      final data = body['data'] ?? {};
                      final perQ = (data['per_question'] as List<dynamic>?) ?? [];
                      final summary = data['summary'] ?? data;

                      // fetch questions to obtain choices content
                      final qResp = await ApiService.getQuizQuestions(quizId: quiz.idQuiz);
                      List<dynamic> qItems = [];
                      if (qResp.statusCode == 200) {
                        final qb = jsonDecode(qResp.body);
                        qItems = (qb['data'] as List<dynamic>?) ?? [];
                      }

                      // build Question objects similar to work page
                      final questions = qItems.map((e) {
                        final choices = (e['choices'] as List<dynamic>?)?.map((c) => AnswerQuestion(
                              idAnswerChoice: (c['id'] ?? '').toString(),
                              content: (c['content'] ?? '').toString(),
                              isCorrect: false,
                              createAt: DateTime.now(),
                              updateAt: DateTime.now(),
                            )).toList() ?? [];
                        return Question(
                          idQuestion: (e['id_question'] ?? '').toString(),
                          number: (e['number'] ?? 0) as int,
                          question: (e['question_text'] ?? '').toString(),
                          poin: (e['point'] ?? 0) as int,
                          fkIdQuiz: quiz.idQuiz,
                          fkIdMaterial: e['fk_id_material']?.toString(),
                          answerChoices: choices,
                          createAt: DateTime.now(),
                          updateAt: DateTime.now(),
                        );
                      }).toList();

                      // build answers map from per_question
                      final answers = <String, String>{};
                      for (var pq in perQ) {
                        final qid = (pq['question_id'] ?? '').toString();
                        final sel = (pq['selected_choice_id'] ?? '')?.toString() ?? '';
                        if (qid.isNotEmpty && sel.isNotEmpty) answers[qid] = sel;
                      }

                      final score = (summary['score'] is int) ? summary['score'] as int : int.tryParse((summary['score'] ?? '').toString()) ?? 0;

                      if (!mounted) return;
                      await navigator.push(MaterialPageRoute(builder: (_) => PageMenuQuizResultStudent(
                        questions: questions,
                        answers: answers,
                        score: score,
                        perQuestion: perQ,
                      )));
                    } else {
                      // fallback: show simple message
                      if (!mounted) return;
                      await showDialog(context: navigator.context, builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text('Could not load quiz result (status ${detailResp.statusCode})'),
                        actions: [TextButton(onPressed: () => Navigator.of(navigator.context).pop(), child: const Text('OK'))],
                      ));
                    }
                  } catch (e) {
                    if (!mounted) return;
                    await showDialog(context: navigator.context, builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(e.toString()),
                      actions: [TextButton(onPressed: () => Navigator.of(navigator.context).pop(), child: const Text('OK'))],
                    ));
                  }
                },
                buttonLabel: "View Quiz Results",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadQuizzesForClass(String classId) async {
    try {
      _activeQuizzes = [];
      _completedQuizzes = [];
      final resp = await ApiService.getQuizzes(classId: classId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = (body['data'] as List<dynamic>?) ?? [];
        final list = items.map((e) => {
          'id_quiz': e['id_quiz']?.toString() ?? e['id']?.toString() ?? '',
          'title': e['title']?.toString() ?? '',
          'duration': (e['duration'] is int) ? e['duration'] as int : int.tryParse(e['duration']?.toString() ?? '') ?? 0,
          'created_by': e['created_by']?.toString() ?? e['createdBy']?.toString() ?? '',
          'created_at': e['created_at']?.toString() ?? e['createdAt']?.toString() ?? DateTime.now().toString(),
          'updated_at': e['updated_at']?.toString() ?? e['updatedAt']?.toString() ?? DateTime.now().toString(),
        }).toList();

        for (var q in list) {
          final idQuiz = (q['id_quiz'] ?? '').toString();
          final title = (q['title'] ?? '').toString();
          final duration = (q['duration'] is int) ? q['duration'] as int : int.tryParse((q['duration'] ?? '').toString()) ?? 0;
          final createBy = (q['created_by'] ?? '').toString();
          final createdAtStr = (q['created_at'] ?? '').toString();
          final updatedAtStr = (q['updated_at'] ?? '').toString();
          final quiz = Quiz(
            idQuiz: idQuiz,
            title: title,
            duration: duration,
            createBy: createBy,
            createAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
            updateAt: DateTime.tryParse(updatedAtStr) ?? DateTime.now(),
          );
          // Check if user has completed this quiz by querying result-quiz
          final auth = Provider.of<AuthProvider>(context, listen: false);
          try {
            final resResp = await ApiService.getQuizResults(userId: auth.user?.id, quizId: idQuiz, token: auth.token);
            if (resResp.statusCode == 200) {
              final resBody = jsonDecode(resResp.body);
              final resItems = (resBody['data'] as List<dynamic>?) ?? [];
              if (resItems.isNotEmpty) {
                _completedQuizzes.add(quiz);
              } else {
                _activeQuizzes.add(quiz);
              }
            } else {
              _activeQuizzes.add(quiz);
            }
          } catch (_) {
            _activeQuizzes.add(quiz);
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }
}