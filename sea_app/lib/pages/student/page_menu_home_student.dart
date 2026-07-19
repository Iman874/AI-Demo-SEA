import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../component/nav/bottom_navigation.dart';
import '../../component/header/top.dart';
import '../../component/card/card_quiz.dart';
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
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';
import '../../component/state/skeleton_loading.dart';
import '../../component/animated_quote.dart';
import '../page_settings.dart';
import '../page_guide.dart';
import '../../component/window/window_join_class.dart';
import '../../component/window/window_message.dart';
import '../../component/ui/staggered_slide_up.dart';
import '../../component/window/window_view_list_class.dart';
import '../../component/window/window_view_list_discussion.dart';
import 'page_menu_discussion_detail_student.dart';
import 'page_menu_quiz_result_student.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import 'package:flutter/services.dart';
import '../../utils/app_notification.dart';

class MenuHomeStudent extends StatefulWidget {
  const MenuHomeStudent({super.key});

  @override
  State<MenuHomeStudent> createState() => _MenuHomeStudentState();
}

class _MenuHomeStudentState extends State<MenuHomeStudent> {
  int _currentIndex = 2;

  static const List<String> _titles = [
    "Discussion Room",
    "Quiz",
    "Home",
    "Panduan",
    "Setelan",
  ];

  static const List<String> _subtitles = [
    "Ruang diskusi kelas",
    "Kerjakan & evaluasi kuis",
    "Kelola kelas & diskusi",
    "Cara menggunakan aplikasi",
    "Preferensi & konfigurasi",
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  Widget _buildTabWrapper(int index, Widget child) {
    return Column(
      children: [
        TopHeader(
          title: _titles[index],
          subtitle: _subtitles[index],
          accentColor: AppColors.studentAccent,
        ),
        Expanded(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            _buildTabWrapper(0, PageMenuDiscussionStudent()),
            _buildTabWrapper(1, PageMenuQuizStudent()),
            _HomeStudentContent(),
            _buildTabWrapper(3, const PageGuide()),
            _buildTabWrapper(4, const PageSettings()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
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
  String _classSortType = 'terbaru';
  String _discussionSortType = 'terbaru';
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
    if (_loading) return const SkeletonHomeContent();
    if (_error != null) return Center(child: Text('Error: $_error'));
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Filter data
    final classes = (auth.token != null) ? _classes : <ClassModel>[];
    final quizzes = _activeQuizzes;
    final recentQuizzes = _completedQuizzes;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String userName = auth.user?.name ?? "Student";

    final studentQuotes = [
      "Semangat belajar hari ini!",
      "Ilmu adalah investasi masa depan",
      "Terus belajar, terus tumbuh",
      "Setiap usaha tidak sia-sia",
      "Raih mimpi lewat ilmu",
    ];

    // Greeting time based on hour
    final hour = DateTime.now().hour;
    String timeGreeting = "Selamat Hari";
    if (hour >= 5 && hour < 11) {
      timeGreeting = "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      timeGreeting = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      timeGreeting = "Selamat Sore";
    } else {
      timeGreeting = "Selamat Malam";
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── RICH DASHBOARD HEADER (STUDENT) ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 56),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.studentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: AppDecorations.shadowGlow(
                    color: AppColors.studentAccent,
                    opacity: 0.15,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top personalized bar
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$timeGreeting,",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName.toLowerCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar Gradient + Border Putih + Indikator Online
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.studentGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : "S",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -1,
                                bottom: -1,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Info aktivitas belajar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsRegular.quotes, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedQuote(
                              quotes: studentQuotes,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar derived dari kuis (completed/total) — data nyata, bukan palsu
                    _buildStudentProgress(isDark),
                  ],
                ),
              ),
              // Row Statistik berupa Kartu Putih Horizontal Melayang — HIERARCHY (angka besar)
              Positioned(
                bottom: -70,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    // Card 1: Kelas Diikuti
                    Expanded(
                      child: _StatCard(
                        icon: PhosphorIconsRegular.graduationCap,
                        iconColor: const Color(0xFF2563EB),
                        value: "${classes.length}",
                        label: "Kelas Diikuti",
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card 2: Kuis Selesai
                    Expanded(
                      child: _StatCard(
                        icon: PhosphorIconsRegular.checkCircle,
                        iconColor: const Color(0xFFF97316),
                        value: "${recentQuizzes.length}",
                        label: "Kuis Selesai",
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 90), // Jarak aman setelah Stack melayang

          // ── KELAS TERDAFTAR (DI LUAR HEADER BIRU) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kelas Terdaftar",
                  style: AppTextStyles.titleMd(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => WindowViewListClass(
                        classes: classes,
                        isTeacher: false,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        "Lihat semua",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(PhosphorIconsRegular.caretRight, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Filter Chips Kelas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildSortChip(
                  context,
                  label: "Terbaru",
                  isSelected: _classSortType == 'terbaru',
                  onTap: () => setState(() => _classSortType = 'terbaru'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "A-Z",
                  isSelected: _classSortType == 'abjad',
                  onTap: () => setState(() => _classSortType = 'abjad'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "Z-A",
                  isSelected: _classSortType == 'z-a',
                  onTap: () => setState(() => _classSortType = 'z-a'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Horizontal list kelas / Empty state border putus-putus
          classes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmptyClassCard(context),
                )
              : () {
                  final sortedClasses = List<ClassModel>.from(classes);
                  if (_classSortType == 'abjad') {
                    sortedClasses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  } else if (_classSortType == 'z-a') {
                    sortedClasses.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                  } else {
                    sortedClasses.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                  }
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedClasses.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == sortedClasses.length) {
                          return StaggeredSlideUp(
                            index: idx,
                            child: _buildJoinClassCard(context, isDark),
                          );
                        }
                        final c = sortedClasses[idx];
                        return StaggeredSlideUp(
                          index: idx,
                          child: _buildClassHorizontalCard(context, c, isDark),
                        );
                      },
                    ),
                  );
                }(),
          const SizedBox(height: 12),

          // ── KONTEN BAWAH (QUIZ & DISKUSI) ──
          // Active Quiz Section
          _buildContentSectionHeader(context, "Kuis Induvidu", "1", isDark),
          CardQuizList(quizzes: quizzes, onViewResult: (quiz) {}),
          const SizedBox(height: 24),

          // Recent Quizzes (Completed)
          if (recentQuizzes.isNotEmpty) ...[
            _buildContentSectionHeader(context, "Riwayat Kuis", "2", isDark),
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
              buttonLabel: "Hasil Kuis",
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.studentGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Diskusi Aktif",
                      style: AppTextStyles.titleMd(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => WindowViewListDiscussion(
                        discussions: _discussions,
                        isTeacher: false,
                        onTap: (d) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DiscussionDetailStudentPage(discussion: d),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text(
                        "Lihat semua",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(PhosphorIconsRegular.caretRight, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildSortChip(
                  context,
                  label: "Terbaru",
                  isSelected: _discussionSortType == 'terbaru',
                  onTap: () => setState(() => _discussionSortType = 'terbaru'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "A-Z",
                  isSelected: _discussionSortType == 'abjad',
                  onTap: () => setState(() => _discussionSortType = 'abjad'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "Z-A",
                  isSelected: _discussionSortType == 'z-a',
                  onTap: () => setState(() => _discussionSortType = 'z-a'),
                  isDark: isDark,
                  accentColor: AppColors.studentAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal scroll discussions
          () {
            final sortedDiscussions = List<DiscussionRoom>.from(_discussions);
            if (_discussionSortType == 'abjad') {
              sortedDiscussions.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
            } else if (_discussionSortType == 'z-a') {
              sortedDiscussions.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
            } else {
              sortedDiscussions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }

            return sortedDiscussions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.card(context),
                      child: Center(
                        child: Text(
                          "Belum ada ruang diskusi tersedia",
                          style: AppTextStyles.bodySm(context),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedDiscussions.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == sortedDiscussions.length) {
                          return _buildAddDiscussionCard(context, isDark, isTeacher: false);
                        }
                        final d = sortedDiscussions[idx];
                        return StaggeredSlideUp(
                          index: idx,
                          child: _buildDiscussionHorizontalCard(context, d, isDark, isTeacher: false),
                        );
                      },
                    ),
                  );
          }(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── HELPER WIDGETS FOR RICH DASHBOARD ──

  Widget _buildClassHorizontalCard(BuildContext context, ClassModel c, bool isDark) {
    final relTime = _relativeTime(c.updatedAt);
    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  PhosphorIconsRegular.bookOpenText,
                  color: AppColors.secondary,
                  size: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: c.codeClass));
                  AppNotification.show(
                    context,
                    "Kode kelas '${c.codeClass}' berhasil disalin!",
                    isError: false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.codeClass,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIconsRegular.copy,
                        size: 10,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.calendar,
                    size: 10,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      c.semester.isEmpty ? "Semester —" : c.semester,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                "Diperbarui $relTime",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white30 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinClassCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _joinClassDialog(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.plus,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Gabung",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDiscussionCard(BuildContext context, bool isDark, {required bool isTeacher}) {
    final accentColor = isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;
    return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => WindowViewListDiscussion(
                discussions: _discussions,
                isTeacher: false,
                onTap: (d) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DiscussionDetailStudentPage(discussion: d),
                    ),
                  );
                },
              ),
            );
          },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.plus,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Lihat",
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyClassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _joinClassDialog(context),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomPaint(
          painter: _DottedBorderPainter(
            color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
            radius: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsRegular.plus,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Gabung Kelas",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Mulai dengan bergabung kelas baru untuk proses belajarmu",
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSectionHeader(BuildContext context, String title, String stepNum, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -10,
                top: -12,
                child: Text(
                  stepNum,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    letterSpacing: -1,
                  ),
                ),
              ),
              Row(
                children: [
                  // Garis aksen vertikal gradient
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.studentGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: AppTextStyles.titleMd(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _joinClassDialog(BuildContext parentContext) async {
    await showDialog(
      context: parentContext,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (dialogCtx) => WindowJoinClass(
        onJoin: (code) async {
          String message = '';
          bool joined = false;

          final authProv = Provider.of<AuthProvider>(parentContext, listen: false);
          final navigator = Navigator.of(parentContext);

          try {
            final token = authProv.token;
            if (token == null) {
              final msg = 'Kamu harus masuk terlebih dahulu.';
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

            final resp = await ApiService.joinClass({'code_class': code}, token: token);
            if (resp.statusCode == 201) {
              final body = jsonDecode(resp.body);
              message = body['message'] ?? 'Berhasil bergabung dengan kelas';
              joined = true;
              authProv.bumpClassesVersion();
            } else if (resp.statusCode == 200) {
              final body = jsonDecode(resp.body);
              message = body['message'] ?? 'Sudah bergabung';
            } else if (resp.statusCode == 404) {
              message = 'Kode kelas tidak ditemukan.';
            } else {
              final body = jsonDecode(resp.body);
              message = body['message'] ?? 'Gagal bergabung dengan kelas.';
            }
          } catch (err) {
            message = 'Terjadi kesalahan: ${err.toString()}';
          }

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
                  await _loadData();
                  if (mounted) setState(() {});
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Progress belajar derived dari kuis: completed / (active + completed).
  /// Jika total 0 → tampilkan teks motivasi (bukan bar 0%).
  Widget _buildStudentProgress(bool isDark) {
    final total = _activeQuizzes.length + _completedQuizzes.length;
    if (total == 0) {
      return Row(
        children: [
          const Icon(PhosphorIconsRegular.flag, color: Colors.white70, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "Mulai kerjakan kuis pertamamu untuk melihat progress di sini",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }
    final pct = (_completedQuizzes.length / total * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress kuis minggu ini",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$pct%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? accentColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionHorizontalCard(BuildContext context, DiscussionRoom d, bool isDark, {required bool isTeacher}) {
    final isOpen = d.status == 'open';
    final accentColor = isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;

    return GestureDetector(
      onTap: () {
        if (!isTeacher) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DiscussionDetailStudentPage(discussion: d),
            ),
          );
        }
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.chatsCircle,
                    color: accentColor,
                    size: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOpen ? "AKTIF" : "SELESAI",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isOpen ? const Color(0xFF10B981) : Colors.red,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    d.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.description.isNotEmpty == true ? d.description : "Tidak ada deskripsi",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mnt lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 30) return "${diff.inDays} hari lalu";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} bln lalu";
    return "${(diff.inDays / 365).floor()} thn lalu";
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = Path();
    var distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
