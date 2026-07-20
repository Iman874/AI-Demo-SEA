import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/discussion_question.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/staggered_slide_up.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  CardAnswerQuestionStudent  — kartu pertanyaan diskusi siswa
// ──────────────────────────────────────────────────────────────────────────────
class CardAnswerQuestionStudent extends StatelessWidget {
  final List<DiscussionQuestion> questions;
  final void Function(DiscussionQuestion)? onViewDetails;

  const CardAnswerQuestionStudent({
    super.key,
    required this.questions,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const _QuestionStudentEmptyState();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: questions.asMap().entries.map((entry) {
          return StaggeredSlideUp(
            index: entry.key,
            child: _QuestionStudentItemCard(
              question: entry.value,
              onViewDetails: onViewDetails,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuestionStudentEmptyState extends StatelessWidget {
  const _QuestionStudentEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.question,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Pertanyaan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pertanyaan diskusi siswa akan tampil di sini',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuestionStudentItemCard extends StatelessWidget {
  final DiscussionQuestion question;
  final void Function(DiscussionQuestion)? onViewDetails;

  const _QuestionStudentItemCard({
    required this.question,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? AppColors.borderDark : const Color(0xFFEFF2F7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inner vertical accent pill
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),

                // User Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.user,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Question details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.content,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIconsRegular.userCircle, size: 11, color: accent),
                                const SizedBox(width: 4),
                                Text(
                                  question.fkIdUser ?? 'Anonim',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${question.id.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: dividerColor),

          // Action Button Row
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewDetails != null ? () => onViewDetails!(question) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.chatText,
                      size: 15,
                      color: onViewDetails != null ? accent : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Lihat Detail Pertanyaan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onViewDetails != null ? accent : Colors.grey.shade400,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      PhosphorIconsRegular.arrowRight,
                      size: 14,
                      color: onViewDetails != null ? accent : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
