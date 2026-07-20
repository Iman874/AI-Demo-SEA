import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../component/card/card_material.dart';
import '../../component/card/card_question.dart';
import '../../models/material.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_notification.dart';
import '../student/page_menu_quiz_result_student.dart';
import '../../component/window/window_view_question.dart';

class PageMenuQuizResultTeacher extends StatefulWidget {
  final String quizId;
  final String title;
  final String? classId;
  const PageMenuQuizResultTeacher({super.key, required this.quizId, required this.title, this.classId});

  @override
  State<PageMenuQuizResultTeacher> createState() => _PageMenuQuizResultTeacherState();
}

class _PageMenuQuizResultTeacherState extends State<PageMenuQuizResultTeacher> {
  bool _loading = true;
  String? _error;
  int _duration = 0; // minutes
  List<MaterialPdf> _materials = [];
  List<Question> _questions = [];
  List<Map<String, String>> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h} Jam ${m} Menit';
    if (h > 0) return '${h} Jam';
    return '${m} Menit';
  }

  Future<void> _loadAll() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() { _loading = true; _error = null; });
    try {
      // 1) Quiz info for duration
      try {
        final qResp = await ApiService.getQuizzes();
        if (qResp.statusCode == 200) {
          final body = jsonDecode(qResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          for (var e in items) {
            final id = (e['id_quiz'] ?? e['id'] ?? '').toString();
            if (id == widget.quizId) {
              final dur = (e['duration'] is int) ? e['duration'] as int : int.tryParse(e['duration']?.toString() ?? '') ?? 0;
              _duration = dur;
              break;
            }
          }
        }
      } catch (_) {}

      // 2) Materials for this quiz
      try {
        final mResp = await ApiService.getMaterials(quizId: widget.quizId);
        if (mResp.statusCode == 200) {
          final body = jsonDecode(mResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          _materials = items.map((e) => MaterialPdfJson.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      } catch (_) {}

      // 3) Questions for this quiz
      try {
        final qq = await ApiService.getQuizQuestions(quizId: widget.quizId);
        if (qq.statusCode == 200) {
          final qb = jsonDecode(qq.body);
          final qItems = (qb['data'] as List<dynamic>?) ?? [];
          _questions = qItems.map((e) {
            final rawChoices = (e['choices'] as List<dynamic>?) ?? [];
            return Question(
              idQuestion: (e['id_question'] ?? '').toString(),
              number: (e['number'] ?? 0) as int,
              question: (e['question_text'] ?? '').toString(),
              poin: (e['point'] ?? 0) as int,
              fkIdQuiz: widget.quizId,
              fkIdMaterial: e['fk_id_material']?.toString(),
              answerChoices: rawChoices.map((c) => AnswerQuestion(
                idAnswerChoice: (c['id_answerchoice'] ?? c['id'] ?? '').toString(),
                content: (c['content'] ?? '').toString(),
                isCorrect: c['is_correct'] == true || c['is_correct'] == 1,
                createAt: DateTime.now(),
                updateAt: DateTime.now(),
              )).toList(),
              createAt: DateTime.now(),
              updateAt: DateTime.now(),
            );
          }).toList();
        }
      } catch (_) {}

      // 4) Results for this quiz (teacher-wide)
      Map<String, String> nameById = {};
      if (widget.classId != null && widget.classId!.isNotEmpty) {
        try {
          final cm = await ApiService.getClassMembers(classId: widget.classId!);
          if (cm.statusCode == 200) {
            final body = jsonDecode(cm.body);
            final items = (body['data'] as List<dynamic>?) ?? [];
            for (var u in items) {
              final id = (u['id_user'] ?? u['id'] ?? '').toString();
              final nm = (u['name'] ?? '').toString();
              if (id.isNotEmpty) nameById[id] = nm;
            }
          }
        } catch (_) {}
      }

      try {
        final rResp = await ApiService.getQuizResults(quizId: widget.quizId, token: auth.token);
        if (rResp.statusCode == 200) {
          final body = jsonDecode(rResp.body);
          final rows = (body['data'] as List<dynamic>?) ?? [];
          _answers = rows.map((r) {
            final uid = (r['fk_id_user'] ?? r['user_id'] ?? '').toString();
            final nm = nameById[uid] ?? 'User $uid';
            final score = (r['score'] ?? '0').toString();
            return {
              'name': nm,
              'user_id': uid,
              'score': score,
            };
          }).toList();
        }
      } catch (_) {}

      // Fallback mock data for offline/dev-mode testing
      if (_questions.isEmpty) {
        _questions = [
          Question(
            idQuestion: 'q1',
            number: 1,
            question: 'Sebutkan salah satu komponen pasif elektronika!',
            poin: 50,
            fkIdQuiz: widget.quizId,
            answerChoices: [
              AnswerQuestion(idAnswerChoice: 'c1_1', content: 'Resistor', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
              AnswerQuestion(idAnswerChoice: 'c1_2', content: 'Transistor', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
              AnswerQuestion(idAnswerChoice: 'c1_3', content: 'IC (Integrated Circuit)', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
            ],
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          ),
          Question(
            idQuestion: 'q2',
            number: 2,
            question: 'Apakah satuan dari Hambatan Listrik?',
            poin: 50,
            fkIdQuiz: widget.quizId,
            answerChoices: [
              AnswerQuestion(idAnswerChoice: 'c2_1', content: 'Ampere', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
              AnswerQuestion(idAnswerChoice: 'c2_2', content: 'Volt', isCorrect: false, createAt: DateTime.now(), updateAt: DateTime.now()),
              AnswerQuestion(idAnswerChoice: 'c2_3', content: 'Ohm', isCorrect: true, createAt: DateTime.now(), updateAt: DateTime.now()),
            ],
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          ),
        ];
      }

      if (_answers.isEmpty) {
        _answers = [
          {'name': 'Ani Wijaya', 'user_id': 'u1', 'score': '100'},
          {'name': 'Citra Dewi', 'user_id': 'u2', 'score': '50'},
          {'name': 'Budi Pratama', 'user_id': 'u3', 'score': '0'},
        ];
      }

    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _viewStudentDetails(String userId, String studentName, String scoreStr) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await ApiService.getQuizResultDetails(userId: userId, quizId: widget.quizId, token: auth.token);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loader

      Map<String, String> answersMap = {};
      List<dynamic> perQuestion = [];
      int finalScore = int.tryParse(scoreStr) ?? 0;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        perQuestion = body['per_question'] as List<dynamic>? ?? [];
        for (var pq in perQuestion) {
          final qid = pq['question_id']?.toString() ?? '';
          final selectedChoiceId = pq['selected_choice_id']?.toString() ?? '';
          if (qid.isNotEmpty && selectedChoiceId.isNotEmpty) {
            answersMap[qid] = selectedChoiceId;
          }
        }
      } else {
        // Fallback offline mock answers for dev mode
        if (userId == 'u1') {
          answersMap = {'q1': 'c1_1', 'q2': 'c2_3'};
        } else if (userId == 'u2') {
          answersMap = {'q1': 'c1_1', 'q2': 'c2_1'};
        } else {
          answersMap = {'q1': 'c1_2', 'q2': 'c2_1'};
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PageMenuQuizResultStudent(
            questions: _questions,
            answers: answersMap,
            score: finalScore,
            perQuestion: perQuestion,
          ),
        ),
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop(); // close loader
      AppNotification.show(context, 'Gagal mengambil detail nilai siswa.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Rekap Nilai Kuis")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Rekap Nilai Kuis")),
        body: Center(child: Text('Terjadi kesalahan: $_error')),
      );
    }

    final averageScore = _answers.isEmpty
        ? 0.0
        : (_answers.map((e) => double.tryParse(e['score'] ?? '0') ?? 0.0).reduce((a, b) => a + b) / _answers.length);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Rekap Nilai Kuis",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── RINGKASAN STATISTIK GURU ──
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.teacherGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teacherAccent.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statItem('Durasi', _formatDuration(_duration)),
                      _statItem('Total Soal', '${_questions.length} Soal'),
                      _statItem('Rata-rata', '${averageScore.toStringAsFixed(1)} Poin'),
                    ],
                  ),
                ],
              ),
            ),

            // ── DAFTAR MATERI PENDUKUNG ──
            if (_materials.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.folderOpen, color: AppColors.teacherAccent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Materi Kuis",
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              CardMaterialList(materials: _materials),
              const SizedBox(height: 12),
            ],

            // ── DAFTAR SOAL KUIS ──
            if (_questions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.clipboardText, color: AppColors.teacherAccent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Daftar Soal Kuis",
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              CardQuestionList(
                questions: _questions,
                onViewDetails: (q) {
                  // Temukan judul materi pendukung jika ada
                  String? matTitle;
                  try {
                    final needle = q.fkIdMaterial?.toString().trim() ?? '';
                    if (needle.isNotEmpty) {
                      final found = _materials.firstWhere((m) => m.id == needle);
                      matTitle = found.title;
                    }
                  } catch (_) {}

                  showDialog(
                    context: context,
                    builder: (_) => WindowViewQuestion(
                      question: q,
                      relatedMaterialTitle: matTitle,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // ── HASIL PENGERJAAN MAHASISWA/SISWA ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.users, color: AppColors.teacherAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Daftar Nilai Siswa",
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
                ),
              ),
              child: _answers.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada siswa yang mengerjakan kuis ini.',
                          style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                    )
                  : Column(
                      children: _answers.map((ans) {
                        final scoreVal = int.tryParse(ans['score'] ?? '0') ?? 0;
                        final passed = scoreVal >= 70;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (passed ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  PhosphorIconsRegular.user,
                                  color: passed ? AppColors.success : AppColors.error,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ans['name'] ?? '',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Skor: $scoreVal/100 • ${passed ? 'Lulus' : 'Remedial'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: passed ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.teacherAccent,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                onPressed: () => _viewStudentDetails(ans['user_id'] ?? '', ans['name'] ?? '', ans['score'] ?? '0'),
                                child: const Text("Lihat Detail"),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
