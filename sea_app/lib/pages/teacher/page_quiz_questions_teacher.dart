import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../models/material.dart';
import '../../component/window/window_add_question.dart';
import '../../component/window/window_edit_question.dart';
import '../../component/window/window_confirmation.dart';
import '../../theme/app_colors.dart';

class PageQuizQuestionsTeacher extends StatefulWidget {
  final List<Question> questions;
  final List<MaterialPdf> materials;
  final String quizTitle;

  const PageQuizQuestionsTeacher({
    super.key,
    required this.questions,
    required this.materials,
    required this.quizTitle,
  });

  @override
  State<PageQuizQuestionsTeacher> createState() => _PageQuizQuestionsTeacherState();
}

class _PageQuizQuestionsTeacherState extends State<PageQuizQuestionsTeacher> {
  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.questions);
  }

  void _openAddQuestion() async {
    await showDialog(
      context: context,
      builder: (context) => WindowAddQuestion(
        nextNumber: _questions.length + 1,
        fkIdQuiz: 'local',
        onAdd: (Question q) {
          setState(() {
            _questions.add(q);
          });
        },
        existingQuestions: _questions,
        materials: widget.materials,
      ),
    );
  }

  void _openEditQuestion(Question q) async {
    await showDialog(
      context: context,
      builder: (context) => WindowEditQuestion(
        question: q,
        onSave: (Question updated) {
          setState(() {
            final idx = _questions.indexWhere((qq) => qq.idQuestion == q.idQuestion);
            if (idx != -1) _questions[idx] = updated;
          });
        },
        existingQuestions: _questions.where((qq) => qq.idQuestion != q.idQuestion).toList(),
        materials: widget.materials,
      ),
    );
  }

  void _confirmDelete(Question q) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WindowConfirmation(
        message: 'Hapus soal nomor ${q.number}?',
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (result == true) {
      setState(() {
        _questions.removeWhere((qq) => qq.idQuestion == q.idQuestion);
      });
    }
  }

  String _getMaterialTitle(Question q) {
    if (q.fkIdMaterial == null) return '';
    final needle = q.fkIdMaterial!.toString().trim();
    for (final m in widget.materials) {
      if (m.id.toString().trim() == needle) return m.title;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalPoin = _questions.fold<int>(0, (sum, q) => sum + (q.poin));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Modern ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.teacherGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(_questions),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bank Soal Kuis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.quizTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Stats pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.quiz_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '${_questions.length} Soal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary Bar ──
            if (_questions.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.list_alt_rounded,
                      label: 'Total Soal',
                      value: _questions.length.toString(),
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.star_rounded,
                      label: 'Total Poin',
                      value: totalPoin.toString(),
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                    ),
                    const Spacer(),
                    Text(
                      'Rata-rata: ${_questions.isEmpty ? 0 : (totalPoin / _questions.length).toStringAsFixed(1)} poin/soal',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Daftar Soal ──
            Expanded(
              child: _questions.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      itemCount: _questions.length,
                      itemBuilder: (context, i) {
                        final q = _questions[i];
                        final matTitle = _getMaterialTitle(q);
                        return _QuestionCard(
                          question: q,
                          index: i,
                          materialTitle: matTitle,
                          isDark: isDark,
                          onEdit: () => _openEditQuestion(q),
                          onDelete: () => _confirmDelete(q),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── FAB Tambah Soal ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddQuestion,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Soal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 6,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 60,
              color: isDark ? Colors.blue.shade300 : AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Soal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol di bawah untuk\nmenambahkan soal pertama',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Komponen StatChip ──
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Card Soal Modern ──
class _QuestionCard extends StatelessWidget {
  final Question question;
  final int index;
  final String materialTitle;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.materialTitle,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasChoices = question.answerChoices.isNotEmpty;
    final correctChoice = hasChoices
        ? question.answerChoices.where((c) => c.isCorrect).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card soal ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
                  AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.02),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                // Nomor soal
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${question.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soal #${question.number}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      if (materialTitle.isNotEmpty)
                        Text(
                          'Dari: $materialTitle',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.blue.shade300 : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Poin badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '${question.poin} poin',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Isi soal ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              question.question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.5,
              ),
            ),
          ),

          // ── Pilihan jawaban ringkas ──
          if (hasChoices)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilihan Jawaban (${question.answerChoices.length})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...question.answerChoices.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.isCorrect
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                            border: Border.all(
                              color: c.isCorrect
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                              width: 1.5,
                            ),
                          ),
                          child: c.isCorrect
                              ? const Icon(Icons.check_rounded, size: 11, color: Color(0xFF10B981))
                              : null,
                        ),
                        Expanded(
                          child: Text(
                            c.content,
                            style: TextStyle(
                              fontSize: 13,
                              color: c.isCorrect
                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
                              fontWeight: c.isCorrect ? FontWeight.w700 : FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

          // ── Jawaban benar highlight ──
          if (correctChoice != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  const Text(
                    'Jawaban: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      correctChoice.content,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── Aksi ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 15),
                    label: const Text('Edit Soal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.blue.shade300 : AppColors.primary,
                      side: BorderSide(
                        color: isDark ? Colors.blue.shade800 : AppColors.primary.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
