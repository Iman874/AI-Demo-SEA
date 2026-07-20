import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/quiz_result.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/staggered_slide_up.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  CardQuizResultList  — daftar kartu hasil pengerjaan kuis
// ──────────────────────────────────────────────────────────────────────────────
class CardQuizResultList extends StatelessWidget {
  final List<QuizResult> results;
  final void Function(QuizResult)? onViewDetails;

  const CardQuizResultList({
    super.key,
    required this.results,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const _QuizResultEmptyState();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: results.asMap().entries.map((entry) {
          return StaggeredSlideUp(
            index: entry.key,
            child: _QuizResultItemCard(
              result: entry.value,
              onViewDetails: onViewDetails,
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
class _QuizResultEmptyState extends StatelessWidget {
  const _QuizResultEmptyState();

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
              PhosphorIconsRegular.trophy,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Hasil Kuis',
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
            'Riwayat hasil pengerjaan kuis akan tampil di sini',
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

// ──────────────────────────────────────────────────────────────────────────────
//  _QuizResultItemCard  — kartu hasil kuis individual
// ──────────────────────────────────────────────────────────────────────────────
class _QuizResultItemCard extends StatelessWidget {
  final QuizResult result;
  final void Function(QuizResult)? onViewDetails;

  const _QuizResultItemCard({
    required this.result,
    this.onViewDetails,
  });

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthStr = months[dt.month - 1];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} $monthStr ${dt.year} • $hourStr:$minuteStr';
  }

  Color _getScoreColor(int score) {
    if (score >= 85) return const Color(0xFF10B981); // Emerald Green
    if (score >= 70) return const Color(0xFF3B82F6); // Blue
    if (score >= 55) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? AppColors.borderDark : const Color(0xFFEFF2F7);

    final scoreColor = _getScoreColor(result.score);
    final isCompleted = result.status.toLowerCase() == 'completed' || result.status.toLowerCase() == 'selesai';
    final durationMin = result.finishedAt.difference(result.startedAt).inMinutes;

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
          // ── Header: Score Badge + Details ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Inner vertical accent pill
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),

                // Circular Score Progress Ring (menentukan kepenuhan nilai 0-100%)
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: (result.score / 100).clamp(0.0, 1.0),
                          strokeWidth: 3.5,
                          backgroundColor: scoreColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${result.score}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scoreColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Nilai',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Info: Title + Status + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'Hasil Kuis',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#${result.fkIdQuiz.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: accent,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isCompleted ? AppColors.success : AppColors.warning)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isCompleted ? AppColors.success : AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCompleted ? 'Selesai' : result.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted ? AppColors.success : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.clock,
                            size: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(result.finishedAt),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (durationMin > 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              PhosphorIconsRegular.timer,
                              size: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$durationMin mnt',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
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
              onTap: onViewDetails != null ? () => onViewDetails!(result) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.chartLineUp,
                      size: 15,
                      color: onViewDetails != null ? accent : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Lihat Detail Hasil Kuis',
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
