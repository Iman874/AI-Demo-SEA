import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/quiz.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/staggered_slide_up.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  CardQuizList  — daftar kartu kuis dengan animasi staggered
// ──────────────────────────────────────────────────────────────────────────────
class CardQuizList extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function(Quiz)? onViewResult;
  final String buttonLabel;

  const CardQuizList({
    super.key,
    required this.quizzes,
    this.onViewResult,
    this.buttonLabel = 'Hasil Kuis',
  });

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) return const _QuizEmptyState();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: quizzes.asMap().entries.map((entry) {
          return StaggeredSlideUp(
            index: entry.key,
            child: _QuizItemCard(
              quiz: entry.value,
              onViewResult: onViewResult,
              buttonLabel: buttonLabel,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Empty state
// ──────────────────────────────────────────────────────────────────────────────
class _QuizEmptyState extends StatelessWidget {
  const _QuizEmptyState();

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
            child: Icon(PhosphorIconsRegular.clipboardText, color: accent, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Kuis',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kuis akan muncul di sini\nsetelah tersedia untuk kelas ini',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  _QuizItemCard  — kartu kuis individual
//
//  Layout:
//    ┌─╠══════════════════════════════════════╗
//    │▋║  [icon]  Judul Kuis                 ║
//    │ ║          [⏱ 30 mnt]                 ║
//    │ ╠──────────────────────────────────────╣
//    │ ║  ▶  Mulai Kuis              →       ║
//    └─╚══════════════════════════════════════╝
// ──────────────────────────────────────────────────────────────────────────────
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
    final accent = Theme.of(context).colorScheme.primary;
    final accentDark = Color.lerp(accent, Colors.black, 0.22)!;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? AppColors.borderDark : const Color(0xFFEFF2F7);
    final hasAction = onViewResult != null;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top: accent indicator + icon + info
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
                    gradient: LinearGradient(
                      colors: [accent, accentDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),

                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.clipboardText,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          _QuizBadge(
                            icon: PhosphorIconsRegular.timer,
                            label: '${quiz.duration} menit',
                            color: accent,
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

          // Action button row
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasAction ? () => onViewResult!(quiz) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.playCircle,
                      size: 15,
                      color: hasAction ? accent : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      buttonLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasAction ? accent : Colors.grey.shade400,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      PhosphorIconsRegular.arrowRight,
                      size: 14,
                      color: hasAction ? accent : Colors.grey.shade400,
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

// ──────────────────────────────────────────────────────────────────────────────
//  _QuizBadge  — pill badge kecil untuk info (durasi, dll.)
// ──────────────────────────────────────────────────────────────────────────────
class _QuizBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuizBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
