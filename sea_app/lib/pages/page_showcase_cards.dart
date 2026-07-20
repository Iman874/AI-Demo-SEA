import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

// Models
import '../models/class.dart';
import '../models/quiz.dart';
import '../models/discussion_room.dart';
import '../models/material.dart';
import '../models/question.dart';
import '../models/answer_question.dart';
import '../models/quiz_result.dart';
import '../models/discussion_question.dart';
import '../models/summary_discussion.dart';
import '../models/result_understanding.dart';

// Card Components
import '../component/card/card_class.dart';
import '../component/card/card_quiz.dart';
import '../component/card/card_discussion.dart';
import '../component/card/card_material.dart';
import '../component/card/card_question.dart';
import '../component/card/card_quiz_result.dart';
import '../component/card/card_answer_question_student.dart';
import '../component/card/card_conclusion_student.dart';
import '../component/card/card_percentage_understanding.dart';
import '../component/window/window_view_question.dart';

// Theme & Utils
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../utils/app_notification.dart';

class PageShowcaseCards extends StatefulWidget {
  const PageShowcaseCards({super.key});

  @override
  State<PageShowcaseCards> createState() => _PageShowcaseCardsState();
}

class _PageShowcaseCardsState extends State<PageShowcaseCards> {
  bool _showEmptyState = false;

  void _notify(String msg) {
    AppNotification.show(context, msg, isError: false);
  }

  // ── Mock Data Definitions ──────────────────────────────────────────────────
  final List<ClassModel> _sampleClasses = [
    ClassModel(
      idClass: 'c1',
      name: 'Pemrograman Web & Mobile II',
      codeClass: 'PWM-2026',
      description: 'Materi pengembangan aplikasi web & mobile Flutter',
      semester: 'Semester 4',
      createdBy: 'u1',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ClassModel(
      idClass: 'c2',
      name: 'Kecerdasan Buatan & ML',
      codeClass: 'AI-401',
      description: 'Konsep AI, machine learning, dan integrasi Gemini API',
      semester: 'Semester 6',
      createdBy: 'u1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<Quiz> _sampleQuizzes = [
    Quiz(
      idQuiz: 'q1',
      title: 'Kuis 1: Pengenalan Flutter & Dart State Management',
      duration: 30,
      createBy: 'Dr. Hendra, M.Kom',
      createAt: DateTime.now().subtract(const Duration(days: 2)),
      updateAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Quiz(
      idQuiz: 'q2',
      title: 'Kuis 2: Integrasi REST API Laravel 11 dengan Provider',
      duration: 45,
      createBy: 'Dr. Hendra, M.Kom',
      createAt: DateTime.now().subtract(const Duration(days: 10)),
      updateAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  final List<DiscussionRoom> _sampleDiscussions = [
    DiscussionRoom(
      idDiscussionRoom: 'd1',
      title: 'Diskusi Kelompok 1: Pengolahan Citra Digital dengan Gemini AI',
      description: 'Ruang diskusi pengolahan citra',
      tag: 'Pengolahan Citra',
      status: 'open',
      createdBy: 'Student Alpha',
      fkIdClass: 'c1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      chatroomActive: true,
    ),
    DiscussionRoom(
      idDiscussionRoom: 'd2',
      title: 'Evaluasi Arsitektur Database SQLite & Migration Laravel',
      description: 'Diskusi evaluasi basis data',
      tag: 'Database',
      status: 'closed',
      createdBy: 'Guru Utama',
      fkIdClass: 'c1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      chatroomActive: false,
    ),
  ];

  final List<MaterialPdf> _sampleMaterials = [
    MaterialPdf(
      id: 'm1',
      title: 'Modul Praktikum Flutter & State Management Provider.pdf',
      content: 'assets/pdf/modul1.pdf',
      type: 'pdf',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MaterialPdf(
      id: 'm2',
      title: 'Catatan Kuliah: Dasar REST API & Authentication Header Token',
      content: 'Isi ringkas materi REST API dan header Authorization Bearer token.',
      type: 'text',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<Question> _sampleQuestions = [
    Question(
      idQuestion: 'q1',
      number: 1,
      question: 'Manakah dari berikut yang merupakan keunggulan utama Provider dibanding StatefulWidget murni?',
      poin: 10,
      fkIdQuiz: 'q1',
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      answerChoices: [
        AnswerQuestion(
          idAnswerChoice: 'a1',
          content: 'Pemisahan logika bisnis dari UI (decoupling) secara efisien',
          isCorrect: true,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        ),
        AnswerQuestion(
          idAnswerChoice: 'a2',
          content: 'Menghilangkan kebutuhan membangun widget subtree',
          isCorrect: false,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        ),
      ],
    ),
    Question(
      idQuestion: 'q2',
      number: 2,
      question: 'Apa fungsi dari parameter extendBody pada Scaffold Flutter?',
      poin: 10,
      fkIdQuiz: 'q1',
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      answerChoices: [
        AnswerQuestion(
          idAnswerChoice: 'a3',
          content: 'Memungkinkan body dirender di belakang Floating/Bottom Nav Bar',
          isCorrect: true,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        ),
      ],
    ),
  ];

  final List<QuizResult> _sampleQuizResults = [
    QuizResult(
      idResultQuiz: 'r1',
      score: 90,
      status: 'completed',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      finishedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      fkIdQuiz: 'q1',
      fkIdUser: 'u101',
      createAt: DateTime.now().subtract(const Duration(hours: 2)),
      updateAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    QuizResult(
      idResultQuiz: 'r2',
      score: 75,
      status: 'completed',
      startedAt: DateTime.now().subtract(const Duration(days: 1)),
      finishedAt: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
      fkIdQuiz: 'q2',
      fkIdUser: 'u102',
      createAt: DateTime.now().subtract(const Duration(days: 1)),
      updateAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<DiscussionQuestion> _sampleDiscussionQuestions = [
    DiscussionQuestion(
      id: 'dq1',
      fkIdUser: 'Budi Santoso',
      content: 'Bagaimana cara menangani error token expired saat request API Laravel di Provider?',
    ),
    DiscussionQuestion(
      id: 'dq2',
      fkIdUser: 'Siti Rahma',
      content: 'Apakah SQLite di Flutter aman digunakan untuk caching offline data yang besar?',
    ),
  ];

  final List<SummaryDiscussion> _sampleSummaries = [
    SummaryDiscussion(
      id: 's1',
      fkIdUser: 'AI Assistant',
      content: 'Ringkasan: Diskusi menyimpulkan bahwa penggunaan Interceptor HTTP atau ApiService wrapper sangat disarankan untuk auto-refresh token.',
    ),
  ];

  final List<ResultUnderstanding> _sampleUnderstandings = [
    ResultUnderstanding(id: 'u1', type: 'Sangat Paham (88%)'),
    ResultUnderstanding(id: 'u2', type: 'Cukup Paham (70%)'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = AppColors.teacherAccent;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(PhosphorIconsBold.cards, color: accent, size: 22),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'UI Card Showcase',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Dev Mode',
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Control Banner ───────────────────────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: AppDecorations.borderRadiusLg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 340;
                  return Flex(
                    direction: isNarrow ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: isNarrow
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: isNarrow ? 0 : 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Galeri Komponen Kartu (Card)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Uji sampel data populated vs empty state untuk 9 komponen',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isNarrow) const SizedBox(height: 10) else const SizedBox(width: 12),
                      FilterChip(
                        label: Text(_showEmptyState ? 'State: Empty' : 'State: Populated'),
                        selected: _showEmptyState,
                        selectedColor: AppColors.error.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.error,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _showEmptyState
                              ? AppColors.error
                              : (isDark ? Colors.white : AppColors.studentAccent),
                        ),
                        onSelected: (val) {
                          setState(() => _showEmptyState = val);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── 1. Card Class Showcase ───────────────────────────────────────
            _buildShowcaseSection(
              title: '1. Card Class (List Kelas)',
              filePath: 'lib/component/card/card_class.dart',
              isDark: isDark,
              child: CardClassList(
                classes: _showEmptyState ? [] : _sampleClasses,
              ),
            ),

            // ── 2. Card Quiz Showcase ────────────────────────────────────────
            _buildShowcaseSection(
              title: '2. Card Quiz (List Kuis)',
              filePath: 'lib/component/card/card_quiz.dart',
              isDark: isDark,
              child: CardQuizList(
                quizzes: _showEmptyState ? [] : _sampleQuizzes,
                onViewResult: (q) => _notify('Membuka detail kuis: ${q.title}'),
                buttonLabel: 'Mulai Kuis Demo',
              ),
            ),

            // ── 3. Card Discussion Showcase ──────────────────────────────────
            _buildShowcaseSection(
              title: '3. Card Discussion (List Diskusi)',
              filePath: 'lib/component/card/card_discussion.dart',
              isDark: isDark,
              child: CardDiscussionList(
                discussions: _showEmptyState ? [] : _sampleDiscussions,
                onViewDetails: (d) => _notify('Masuk diskusi: ${d.title}'),
                buttonLabel: 'Masuk Diskusi Demo',
              ),
            ),

            // ── 4. Card Material Showcase ────────────────────────────────────
            _buildShowcaseSection(
              title: '4. Card Material (Materi PDF & Teks)',
              filePath: 'lib/component/card/card_material.dart',
              isDark: isDark,
              child: CardMaterialList(
                materials: _showEmptyState ? [] : _sampleMaterials,
                onViewMaterial: (m) => _notify('Buka materi: ${m.title}'),
              ),
            ),

            // ── 5. Card Question Showcase ────────────────────────────────────
            _buildShowcaseSection(
              title: '5. Card Question (Daftar Butir Soal)',
              filePath: 'lib/component/card/card_question.dart',
              isDark: isDark,
              child: CardQuestionList(
                questions: _showEmptyState ? [] : _sampleQuestions,
                onViewDetails: (q) {
                  showDialog(
                    context: context,
                    builder: (_) => WindowViewQuestion(
                      question: q,
                      relatedMaterialTitle: 'Dasar Pemrograman Mobile',
                    ),
                  );
                },
                onEdit: (q) => _notify('Edit soal #${q.number}'),
                onDelete: (q) => _notify('Hapus soal #${q.number}'),
              ),
            ),

            // ── 6. Card Quiz Result Showcase ─────────────────────────────────
            _buildShowcaseSection(
              title: '6. Card Quiz Result (Hasil Kuis)',
              filePath: 'lib/component/card/card_quiz_result.dart',
              isDark: isDark,
              child: CardQuizResultList(
                results: _showEmptyState ? [] : _sampleQuizResults,
                onViewDetails: (r) => _notify('Lihat hasil kuis: Score ${r.score}'),
              ),
            ),

            // ── 7. Card Answer Question Student Showcase ─────────────────────
            _buildShowcaseSection(
              title: '7. Card Answer Question (Jawaban Diskusi Siswa)',
              filePath: 'lib/component/card/card_answer_question_student.dart',
              isDark: isDark,
              child: CardAnswerQuestionStudent(
                questions: _showEmptyState ? [] : _sampleDiscussionQuestions,
                onViewDetails: (q) => _notify('Lihat pertanyaan: ${q.content}'),
              ),
            ),

            // ── 8. Card Conclusion Student Showcase ──────────────────────────
            _buildShowcaseSection(
              title: '8. Card Conclusion (Ringkasan Diskusi Siswa)',
              filePath: 'lib/component/card/card_conclusion_student.dart',
              isDark: isDark,
              child: CardConclusionStudent(
                summaries: _showEmptyState ? [] : _sampleSummaries,
                onView: (s) => _notify('Lihat ringkasan ID: ${s.id}'),
              ),
            ),

            // ── 9. Card Percentage Understanding Showcase ────────────────────
            _buildShowcaseSection(
              title: '9. Card Percentage Understanding (Tingkat Pemahaman)',
              filePath: 'lib/component/card/card_percentage_understanding.dart',
              isDark: isDark,
              child: CardPercentageUnderstanding(
                items: _showEmptyState ? [] : _sampleUnderstandings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: Section Frame dengan Title + Path Badge ───────────────────────
  Widget _buildShowcaseSection({
    required String title,
    required String filePath,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.teacherAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  filePath,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 10),
      ],
    );
  }
}
