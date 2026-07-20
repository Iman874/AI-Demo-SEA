import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/question.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';

class PageMenuQuizResultStudent extends StatefulWidget {
  final List<Question> questions;
  final Map<String, String> answers; // qid -> choice id
  final int score; // percentage
  final List<dynamic> perQuestion; // optional server per-question detail

  const PageMenuQuizResultStudent({
    super.key,
    required this.questions,
    required this.answers,
    required this.score,
    this.perQuestion = const [],
  });

  @override
  State<PageMenuQuizResultStudent> createState() => _PageMenuQuizResultStudentState();
}

class _PageMenuQuizResultStudentState extends State<PageMenuQuizResultStudent> {
  int _selectedIndex = 0;

  void _gotoQuestion(int idx) {
    if (idx < 0 || idx >= widget.questions.length) return;
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = widget.questions;
    final answers = widget.answers;
    final score = widget.score;

    // Build map from perQuestion if server provided detailed per-question info
    final Map<String, Map<String, dynamic>> serverPerQ = {};
    for (var pq in widget.perQuestion) {
      try {
        final qid = (pq['question_id'] ?? '').toString();
        if (qid.isNotEmpty) serverPerQ[qid] = Map<String, dynamic>.from(pq as Map);
      } catch (_) {}
    }

    final isPassed = score >= 70;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER DENGAN GRADIENT & SKOR ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.studentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.studentAccent.withValues(alpha: 0.20),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Kuis',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPassed ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.warningCircle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPassed ? 'LULUS' : 'BELUM LULUS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Score display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skor Anda',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPassed
                                  ? 'Luar biasa! Kamu memahami materi ini dengan sangat baik.'
                                  : 'Terus tingkatkan pemahaman belajarmu, coba lagi nanti!',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── NOMOR SOAL NAVIGASI ──
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.listChecks, size: 18, color: AppColors.studentAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Pertanyaan',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(questions.length, (i) {
                  final q = questions[i];
                  final answered = answers.containsKey(q.idQuestion);
                  final selected = answers[q.idQuestion];
                  final isCurrent = i == _selectedIndex;

                  bool correct = false;
                  final serverInfo = serverPerQ[q.idQuestion];
                  if (serverInfo != null) {
                    correct = serverInfo['is_correct'] == true || serverInfo['is_correct'] == 1;
                  } else {
                    correct = q.answerChoices.any((c) => c.idAnswerChoice == selected && c.isCorrect);
                  }

                  Color itemColor;
                  Color borderColor;
                  Color textColor;

                  if (isCurrent) {
                    itemColor = AppColors.studentAccent;
                    borderColor = AppColors.studentAccent;
                    textColor = Colors.white;
                  } else if (correct) {
                    itemColor = AppColors.success.withValues(alpha: 0.12);
                    borderColor = AppColors.success.withValues(alpha: 0.4);
                    textColor = AppColors.success;
                  } else if (answered) {
                    itemColor = AppColors.error.withValues(alpha: 0.12);
                    borderColor = AppColors.error.withValues(alpha: 0.4);
                    textColor = AppColors.error;
                  } else {
                    itemColor = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9);
                    borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
                    textColor = isDark ? Colors.white30 : const Color(0xFF64748B);
                  }

                  return InkWell(
                    onTap: () => _gotoQuestion(i),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: itemColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── DETAIL PERTANYAAN TERPILIH ──
            const SizedBox(height: 16),
            Expanded(
              child: questions.isEmpty
                  ? const Center(child: Text('Tidak ada pertanyaan.'))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                              ),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.studentAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Soal #${questions[_selectedIndex].number}',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.studentAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  questions[_selectedIndex].question,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // Choice list
                                Column(
                                  children: questions[_selectedIndex].answerChoices.map((c) {
                                    final qid = questions[_selectedIndex].idQuestion;
                                    final isSelected = answers[qid] == c.idAnswerChoice;
                                    final serverInfo = serverPerQ[qid];
                                    
                                    String? correctId;
                                    if (serverInfo != null) {
                                      correctId = (serverInfo['correct_choice_id'] ?? '').toString();
                                    }

                                    bool isChoiceCorrect = false;
                                    bool isChoiceWrong = false;

                                    if (serverInfo != null) {
                                      final choiceId = c.idAnswerChoice.toString();
                                      if (correctId != null && choiceId == correctId) {
                                        isChoiceCorrect = true;
                                      } else if (isSelected && correctId != null && choiceId != correctId) {
                                        isChoiceWrong = true;
                                      }
                                    } else {
                                      isChoiceCorrect = c.isCorrect;
                                      isChoiceWrong = isSelected && !c.isCorrect;
                                    }

                                    Color choiceBg;
                                    Color choiceBorder;
                                    Color choiceTextColor;
                                    IconData? statusIcon;

                                    if (isChoiceCorrect) {
                                      choiceBg = AppColors.success.withValues(alpha: 0.08);
                                      choiceBorder = AppColors.success.withValues(alpha: 0.35);
                                      choiceTextColor = AppColors.success;
                                      statusIcon = PhosphorIconsRegular.checkCircle;
                                    } else if (isChoiceWrong) {
                                      choiceBg = AppColors.error.withValues(alpha: 0.08);
                                      choiceBorder = AppColors.error.withValues(alpha: 0.35);
                                      choiceTextColor = AppColors.error;
                                      statusIcon = PhosphorIconsRegular.xCircle;
                                    } else {
                                      choiceBg = isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC);
                                      choiceBorder = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
                                      choiceTextColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF475569);
                                    }

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: choiceBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: choiceBorder, width: isSelected || isChoiceCorrect ? 1.5 : 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? PhosphorIconsFill.circle
                                                : PhosphorIconsRegular.circle,
                                            size: 16,
                                            color: isChoiceCorrect
                                                ? AppColors.success
                                                : (isChoiceWrong ? AppColors.error : (isDark ? Colors.white24 : const Color(0xFF94A3B8))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              c.content,
                                              style: GoogleFonts.inter(
                                                fontSize: 12.5,
                                                fontWeight: isSelected || isChoiceCorrect ? FontWeight.bold : FontWeight.normal,
                                                color: choiceTextColor,
                                              ),
                                            ),
                                          ),
                                          if (statusIcon != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(statusIcon, color: choiceTextColor, size: 18),
                                          ],
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton.primary(
                            label: 'Kembali ke Halaman Kuis',
                            icon: PhosphorIconsRegular.arrowLeft,
                            gradientColors: AppColors.studentGradient,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
