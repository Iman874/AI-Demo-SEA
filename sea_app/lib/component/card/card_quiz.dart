import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/quiz.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardQuizList extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function(Quiz)? onViewResult;
  final String buttonLabel;

  const CardQuizList({
    super.key,
    required this.quizzes,
    this.onViewResult,
    this.buttonLabel = "Hasil Kuis",
  });

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.card(context),
        child: Center(
          child: Text(
            "Belum ada kuis tersedia",
            style: AppTextStyles.bodySm(context),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: quizzes.map((q) {
          return _QuizItemCard(
            quiz: q,
            onViewResult: onViewResult,
            buttonLabel: buttonLabel,
          );
        }).toList(),
      ),
    );
  }
}

class _QuizItemCard extends StatelessWidget {
  final Quiz quiz;
  final void Function(Quiz)? onViewResult;
  final String buttonLabel;

  const _QuizItemCard({
    required this.quiz,
    this.onViewResult,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          // Icon Quiz Container
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              PhosphorIconsRegular.checkCircle,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info Quiz
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: AppTextStyles.titleMd(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.question,
                      size: 13,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${quiz.duration} Menit",
                      style: AppTextStyles.bodySm(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Icon button ringkas (bukan pill berlabel) + tooltip
          Tooltip(
            message: buttonLabel,
            child: Material(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onViewResult != null ? () => onViewResult!(quiz) : null,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  child: Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
