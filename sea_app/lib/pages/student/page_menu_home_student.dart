import 'package:flutter/material.dart';
import '../../component/nav/bottom_navigation.dart';
import '../../component/header/top.dart';
import '../../component/card/card_class.dart';
import '../../component/card/card_quiz.dart';
import '../../component/card/card_discussion.dart';
import '../../models/class.dart';
import '../../models/quiz.dart';
import '../../models/discussion_room.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
// removed local user and user_class dummy imports
import 'page_menu_discussion_student.dart';
import 'page_menu_quiz_student.dart';
import '../page_guide.dart';
import '../../theme/dark_theme.dart';
import '../../component/window/window_join_class.dart';
import '../../component/window/window_message.dart';
import 'page_menu_discussion_detail_student.dart';
import 'page_menu_quiz_result_student.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';

class MenuHomeStudent extends StatefulWidget {
  const MenuHomeStudent({super.key});

  @override
  State<MenuHomeStudent> createState() => _MenuHomeStudentState();
}

class _MenuHomeStudentState extends State<MenuHomeStudent> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    "Home",
    "Discussion Room",
    "Quiz",
    "Guide",
  ];

  List<Widget> get _pages => [
        _HomeStudentContent(),
        PageMenuDiscussionStudent(),
    PageMenuQuizStudent(),
    // Guide
    const PageGuide(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopHeader(
              title: _titles[_currentIndex],
              backgroundColor: backgroundColorStudent,
            ),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        isStudent: true,
      ),
    );
  }
}

class _HomeStudentContent extends StatefulWidget {
  @override
  State<_HomeStudentContent> createState() => _HomeStudentContentState();
}

class _HomeStudentContentState extends State<_HomeStudentContent> {
  bool _loading = true;
  String? _error;
  List<ClassModel> _classes = [];
  List<DiscussionRoom> _discussions = [];
  List<Quiz> _activeQuizzes = [];
  List<Quiz> _completedQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.addListener(_authListener);
    });
  }

  void _authListener() {
    if (mounted) _loadData();
  }

  @override
  void dispose() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      auth.removeListener(_authListener);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Always resolve classes from the server-side user_class relation when possible
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id;
      final idResp = await ApiService.getUserClassIds(token: auth.token, userId: userId);
      if (idResp.statusCode == 200) {
        final idBody = jsonDecode(idResp.body);
        final ids = (idBody['data'] as List<dynamic>? ?? []).map((e) => e.toString()).toSet();
        // debug log: which ids were returned for this user
        // ignore: avoid_print
        print('getUserClassIds -> userId=$userId ids=$ids');
        if (ids.isNotEmpty) {
          final classesResp = await ApiService.getClasses();
          if (classesResp.statusCode == 200) {
            final clsBody = jsonDecode(classesResp.body);
            final itemsAll = clsBody['data'] as List<dynamic>? ?? [];
            final all = itemsAll.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
            // debug: print all classes returned by server (id and name)
            // ignore: avoid_print
            print('all classes returned: ${all.map((c) => '${c.idClass}:${c.name}').join(', ')}');
            // filter and deduplicate by idClass to avoid multiple entries
            final filtered = all.where((c) => ids.contains(c.idClass)).toList();
            final map = <String, ClassModel>{};
            for (var c in filtered) {
              map[c.idClass] = c;
            }
            _classes = map.values.toList();
            // debug log resolved class ids
            // ignore: avoid_print
            print('resolved classes for user: ${_classes.map((c) => c.idClass).toList()}');
          }
        } else {
          // if user has no classes, ensure we show empty
          _classes = [];
        }
      } else {
        // If server call failed, fall back to public classes list to avoid empty UI
        final classesResp = await ApiService.getClasses();
        if (classesResp.statusCode == 200) {
          final body = jsonDecode(classesResp.body);
          final items = body['data'] as List<dynamic>? ?? [];
          _classes = items.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      // Load quizzes for user's classes (combine per-class quizzes)
      _activeQuizzes = [];
      _completedQuizzes = [];
      final quizMap = <String, Quiz>{};
      for (var c in _classes) {
        try {
          final qResp = await ApiService.getQuizzes(classId: c.idClass);
          if (qResp.statusCode == 200) {
            final qb = jsonDecode(qResp.body);
            final items = (qb['data'] as List<dynamic>?) ?? [];
            for (var e in items) {
              final idQuiz = (e['id_quiz'] ?? e['id'] ?? '').toString();
              if (idQuiz.isEmpty) continue;
              if (quizMap.containsKey(idQuiz)) continue; // dedupe across classes
              final title = e['title']?.toString() ?? '';
              final duration = (e['duration'] is int)
                  ? e['duration'] as int
                  : int.tryParse(e['duration']?.toString() ?? '') ?? 0;
              final createdAtStr = (e['created_at'] ?? e['createdAt'] ?? DateTime.now().toString()).toString();
              final updatedAtStr = (e['updated_at'] ?? e['updatedAt'] ?? DateTime.now().toString()).toString();
              final quiz = Quiz(
                idQuiz: idQuiz,
                title: title,
                duration: duration,
                createBy: (e['created_by'] ?? e['createdBy'] ?? '').toString(),
                createAt: DateTime.tryParse(createdAtStr) ?? DateTime.now(),
                updateAt: DateTime.tryParse(updatedAtStr) ?? DateTime.now(),
              );
              quizMap[idQuiz] = quiz;
            }
          }
        } catch (_) {}
      }

      // Categorize quizzes into active/completed by checking result-quiz per user
      // reuse auth variable fetched earlier
      for (var quiz in quizMap.values) {
        try {
          final resResp = await ApiService.getQuizResults(userId: auth.user?.id, quizId: quiz.idQuiz, token: auth.token);
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

      final discResp = await ApiService.getDiscussions();
      if (discResp.statusCode == 200) {
        final body = jsonDecode(discResp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
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
  final auth = Provider.of<AuthProvider>(context, listen: false);

  // If logged in, classes contains only user's classes. If not logged in, no classes are shown.
  final classes = (auth.token != null) ? _classes : <ClassModel>[];
  // Quizzes loaded from server
  final quizzes = _activeQuizzes;
  final recentQuizzes = _completedQuizzes; // treat completed as recent for home display
  // Only show discussions that are open and have an AI chatroom active
  final discussions = _discussions.where((d) => d.status == "open" && d.chatroomActive == true).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "My Class",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CardClassList(classes: classes),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final parentContext = context;

                    await showDialog(
                      context: parentContext,
                      useRootNavigator: false,
                      barrierDismissible: false,
                      builder: (dialogCtx) => WindowJoinClass(
                        onJoin: (code) async {
                          String message = '';
                          bool joined = false;

                          // Capture auth provider and navigator early to avoid using BuildContext after awaits
                          final authProv = Provider.of<AuthProvider>(parentContext, listen: false);
                          final navigator = Navigator.of(parentContext);

                          try {
                            final token = authProv.token;
                            if (token == null) {
                              // not logged in — show specific message and require login
                              final msg = 'You must be logged in to join classes.';
                              navigator.pop();
                              await Future.delayed(const Duration(milliseconds: 150));
                              if (!mounted) return;
                              await showDialog(
                                context: navigator.context,
                                barrierDismissible: false,
                                useRootNavigator: false,
                                builder: (ctx2) => WindowMessage(
                                  message: msg,
                                  onOk: () => navigator.pop(),
                                ),
                              );
                              return;
                            }

                            // Call backend API to join class with Bearer token
                            final resp = await ApiService.joinClass({'code_class': code}, token: token);
                            if (resp.statusCode == 201) {
                              final body = jsonDecode(resp.body);
                              message = body['message'] ?? 'Joined class';
                              joined = true;
                              // notify app that classes changed
                              authProv.bumpClassesVersion();
                            } else if (resp.statusCode == 200) {
                              final body = jsonDecode(resp.body);
                              message = body['message'] ?? 'Already joined';
                            } else if (resp.statusCode == 404) {
                              message = 'Class code not found.';
                            } else if (resp.statusCode == 401) {
                              message = 'You must be logged in to join classes.';
                            } else {
                              // For any non-success code from API, show the returned message
                              final body = jsonDecode(resp.body);
                              message = body['message'] ?? 'Failed to join class.';
                            }
                          } catch (err) {
                            message = 'An error occurred while joining the class: ${err.toString()}';
                          }

                          // Close WindowJoinClass using captured navigator
                          navigator.pop();

                          await Future.delayed(const Duration(milliseconds: 150));

                          if (!mounted) return;
                          await showDialog(
                            context: navigator.context,
                            barrierDismissible: false,
                            useRootNavigator: false,
                            builder: (ctx2) => WindowMessage(
                              message: message,
                              onOk: () async {
                                navigator.pop();
                                if (joined && mounted) {
                                  // Reload data on home to reflect new joined class
                                  await _loadData();
                                  if (mounted) setState(() {});
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: Text(
                    "Join with Class Code",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Active Quizzes",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CardQuizList(quizzes: quizzes, onViewResult: (quiz) {}),

            if (recentQuizzes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  "Recent Quizzes",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              CardQuizList(
                quizzes: recentQuizzes,
                onViewResult: (quiz) async {
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

                      // build Question objects similar to quiz menu page
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
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Active Discussions",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            CardDiscussionList(
              discussions: discussions,
              onViewDetails: (discussion) async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionDetailStudentPage(discussion: discussion)));
              },
              buttonLabel: "Join Discussion",
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
