import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../component/card/card_material.dart';
import '../../models/material.dart';
import '../../component/card/card_quiz.dart';
import '../../models/quiz.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import 'page_menu_quiz_work_student.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import 'page_menu_quiz_result_student.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../component/state/skeleton_loading.dart';
import '../../theme/app_colors.dart';

class PageMenuQuizStudent extends StatefulWidget {
  const PageMenuQuizStudent({super.key});

  @override
  State<PageMenuQuizStudent> createState() => _PageMenuQuizStudentState();
}

class _PageMenuQuizStudentState extends State<PageMenuQuizStudent> {
  late List<ClassModel> studentClasses;
  late String selectedClassId;

  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    studentClasses = [];
    selectedClassId = '';
    _loadClasses();
    // Register listener synchronously (listen: false is safe in initState)
    _auth = Provider.of<AuthProvider>(context, listen: false);
    _auth?.addListener(_authListener);
  }

  void _authListener() {
    if (mounted) _loadClasses();
  }

  @override
  void dispose() {
    _auth?.removeListener(_authListener);
    super.dispose();
  }

  // removed local cache of all classes
  bool _loading = true;
  String? _error;
  List<Quiz> _activeQuizzes = [];
  List<Quiz> _completedQuizzes = [];
  List<MaterialPdf> _materials = [];
  String _materialFilter = 'semua';

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
    if (_loading) return const SkeletonListContent();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeQuizzes = _activeQuizzes;
    final completedQuizzes = _completedQuizzes;
    const gradient = AppColors.studentGradient;
    const accent = AppColors.studentAccent;

    if (_error != null) {
      return _buildErrorCard(_error!, isDark, accent, gradient);
    }

    return RefreshIndicator(
      color: accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      onRefresh: _loadClasses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Class chip selector Card ─────────────────────────────────
            _buildClassChips(isDark, gradient, accent),
            const SizedBox(height: 8),

            _buildSectionHeader(
              'Dokumen & Materi Kuis',
              _materials.length,
              isDark,
              gradient,
              subtitle: 'Kelola dokumen dan materi pendukung',
              iconData: PhosphorIconsRegular.folderOpen,
            ),

            // Filter Chips khusus Materi (Semua, PDF, Teks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  _buildSortChip(
                    context,
                    label: "Semua",
                    isSelected: _materialFilter == 'semua',
                    onTap: () => setState(() => _materialFilter = 'semua'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    context,
                    label: "Dokumen PDF",
                    isSelected: _materialFilter == 'pdf',
                    onTap: () => setState(() => _materialFilter = 'pdf'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    context,
                    label: "Catatan Teks",
                    isSelected: _materialFilter == 'teks',
                    onTap: () => setState(() => _materialFilter = 'teks'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            () {
              var filteredMats = List<MaterialPdf>.from(_materials);
              if (_materialFilter == 'pdf') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() == 'pdf').toList();
              } else if (_materialFilter == 'teks') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() != 'pdf').toList();
              }
              return CardMaterialList(
                materials: filteredMats,
              );
            }(),
            const SizedBox(height: 8),

            // ── Kuis Aktif ───────────────────────────────────────────────
            _buildSectionHeader('Kuis Aktif Kelas', activeQuizzes.length, isDark, gradient),
            CardQuizList(
              quizzes: activeQuizzes,
              onViewResult: (quiz) async {
                final navigator = Navigator.of(context);
                final didFinish = await navigator.push(
                  MaterialPageRoute(
                    builder: (_) => PageMenuQuizWorkStudent(
                      quizId: quiz.idQuiz,
                      title: quiz.title,
                      duration: quiz.duration,
                    ),
                  ),
                );
                if (didFinish == true) {
                  if (!mounted) return;
                  await _loadQuizzesForClass(selectedClassId);
                  if (mounted) setState(() {});
                }
              },
              buttonLabel: 'Mulai Kuis',
            ),

            // ── Kuis Selesai ─────────────────────────────────────────────
            _buildSectionHeader('Kuis Selesai', completedQuizzes.length, isDark, gradient),
            CardQuizList(
              quizzes: completedQuizzes,
              onViewResult: (quiz) async {
                final navigator = Navigator.of(context);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final token = auth.token;
                try {
                  final detailResp = await ApiService.getQuizResultDetails(
                    userId: auth.user?.id ?? '',
                    quizId: quiz.idQuiz,
                    token: token,
                  );
                  if (detailResp.statusCode == 200) {
                    final body = jsonDecode(detailResp.body);
                    final data = body['data'] ?? {};
                    final perQ = (data['per_question'] as List<dynamic>?) ?? [];
                    final summary = data['summary'] ?? data;
                    final qResp = await ApiService.getQuizQuestions(quizId: quiz.idQuiz);
                    List<dynamic> qItems = [];
                    if (qResp.statusCode == 200) {
                      final qb = jsonDecode(qResp.body);
                      qItems = (qb['data'] as List<dynamic>?) ?? [];
                    }
                    final questions = qItems.map((e) {
                      final choices = (e['choices'] as List<dynamic>?)
                              ?.map((c) => AnswerQuestion(
                                    idAnswerChoice: (c['id'] ?? '').toString(),
                                    content: (c['content'] ?? '').toString(),
                                    isCorrect: false,
                                    createAt: DateTime.now(),
                                    updateAt: DateTime.now(),
                                  ))
                              .toList() ??
                          [];
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
                    final score = (summary['score'] is int)
                        ? summary['score'] as int
                        : int.tryParse((summary['score'] ?? '').toString()) ?? 0;
                    if (!mounted) return;
                    await navigator.push(
                      MaterialPageRoute(
                        builder: (_) => PageMenuQuizResultStudent(
                          questions: questions,
                          answers: answers,
                          score: score,
                          perQuestion: perQ,
                        ),
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    await showDialog(
                      context: navigator.context,
                      builder: (_) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(
                            'Could not load quiz result (status ${detailResp.statusCode})'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(navigator.context).pop(),
                            child: const Text('OK'),
                          )
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  await showDialog(
                    context: navigator.context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(navigator.context).pop(),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                }
              },
              buttonLabel: 'Lihat Hasil',
            ),

            const SizedBox(height: 100), // ruang untuk bottom nav
          ],
        ),
      ),
    );
  }

  // ── Section header: Ikon Lingkaran + Judul + Subtitle + Count Badge ─────────
  Widget _buildSectionHeader(
    String title,
    int count,
    bool isDark,
    List<Color> gradient, {
    String? subtitle,
    IconData iconData = PhosphorIconsRegular.folderOpen,
  }) {
    final accent = gradient.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Selector Kelas Modern (Presisi Referensi) ─────────────────────────
  Widget _buildClassChips(bool isDark, List<Color> gradient, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row inside Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.graduationCap,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Kelas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Pilih kelas untuk melihat kuis',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${studentClasses.length} Kelas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (studentClasses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tidak ada kelas tersedia',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            )
          else
            SizedBox(
              height: 84,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: studentClasses.length,
                itemBuilder: (_, i) {
                  final c = studentClasses[i];
                  final isSelected = c.idClass == selectedClassId;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < studentClasses.length - 1 ? 10 : 0,
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (isSelected) return;
                        setState(() => selectedClassId = c.idClass);
                        await _loadQuizzesForClass(c.idClass);
                        if (mounted) setState(() {});
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: gradient.first.withValues(alpha: 0.30),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsRegular.bookOpen,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Center(
                                child: Text(
                                  c.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.1,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.textPrimaryDark : const Color(0xFF334155)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  // ── Error card dengan tombol retry ────────────────────────────────────────
  Widget _buildErrorCard(
    String error,
    bool isDark,
    Color accent,
    List<Color> gradient,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadClasses,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadQuizzesForClass(String classId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = auth.user?.id;
      final currentToken = auth.token;

      _activeQuizzes = [];
      _completedQuizzes = [];
      _materials = [];

      // Muat materi kuis/kelas jika API tersedia
      try {
        final matResp = await ApiService.getMaterials();
        if (matResp.statusCode == 200) {
          final body = jsonDecode(matResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          _materials = items.map((e) => MaterialPdfJson.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}

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
          try {
            final resResp = await ApiService.getQuizResults(userId: currentUserId, quizId: idQuiz, token: currentToken);
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

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required List<Color> gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? gradient.first : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}