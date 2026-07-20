import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/question.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/staggered_slide_up.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  CardQuestionList  — daftar kartu butir soal kuis
// ──────────────────────────────────────────────────────────────────────────────
class CardQuestionList extends StatelessWidget {
  final List<Question> questions;
  final void Function(Question)? onViewDetails;
  final void Function(Question)? onEdit;
  final void Function(Question)? onDelete;
  final Widget Function(BuildContext context, Question q, int i)? itemBuilder;
  final List? materials;

  const CardQuestionList({
    super.key,
    required this.questions,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.itemBuilder,
    this.materials,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const _QuestionEmptyState();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: questions.asMap().entries.map((entry) {
          final i = entry.key;
          final q = entry.value;
          if (itemBuilder != null) {
            return itemBuilder!(context, q, i);
          }
          return StaggeredSlideUp(
            index: i,
            child: _QuestionItemCard(
              question: q,
              onViewDetails: onViewDetails,
              onEdit: onEdit,
              onDelete: onDelete,
              materials: materials,
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
class _QuestionEmptyState extends StatelessWidget {
  const _QuestionEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
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
            'Belum Ada Soal',
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
            'Daftar butir soal kuis akan ditampilkan di sini',
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
//  _QuestionItemCard  — kartu butir soal individual
// ──────────────────────────────────────────────────────────────────────────────
class _QuestionItemCard extends StatelessWidget {
  final Question question;
  final void Function(Question)? onViewDetails;
  final void Function(Question)? onEdit;
  final void Function(Question)? onDelete;
  final List? materials;

  const _QuestionItemCard({
    required this.question,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.materials,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? AppColors.borderDark : const Color(0xFFEFF2F7);

    // Cari materi terkait jika ada
    String? relatedMaterialTitle;
    final needle = question.fkIdMaterial?.toString().trim() ?? '';
    if (materials != null && needle.isNotEmpty) {
      for (final m in materials!) {
        try {
          String? id;
          String? title;
          if (m is Map) {
            id = (m['id_material'] ?? m['id'] ?? m['tmp_id'])?.toString();
            title = (m['title'] ?? m['name'])?.toString();
          } else {
            try {
              id = (m.id ?? (m.id_material ?? m.tmp_id))?.toString();
            } catch (_) {}
            try {
              title = (m.title ?? m.name)?.toString();
            } catch (_) {}
          }
          if (id != null && id.trim() == needle) {
            relatedMaterialTitle = title;
            break;
          }
        } catch (_) {}
      }
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Badges: Nomor Soal + Poin ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge No Soal
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.hash,
                            size: 12,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Soal #${question.number}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge Poin
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            PhosphorIconsRegular.star,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${question.poin} Poin',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action buttons di pojok kanan atas
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        onPressed: () => onEdit!(question),
                        tooltip: 'Edit Soal',
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(PhosphorIconsRegular.trash, size: 18),
                        color: AppColors.error,
                        onPressed: () => onDelete!(question),
                        tooltip: 'Hapus Soal',
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Teks Pertanyaan Soal
                Text(
                  question.question.isNotEmpty
                      ? question.question
                      : 'Pertanyaan belum diisi',
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
                const SizedBox(height: 8),

                // Info Pilihan Jawaban & Materi Terkait
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (question.answerChoices.isNotEmpty)
                      _QuestionSubBadge(
                        icon: PhosphorIconsRegular.listChecks,
                        label: '${question.answerChoices.length} Pilihan Jawaban',
                        isDark: isDark,
                      ),
                    if (relatedMaterialTitle != null && relatedMaterialTitle.isNotEmpty)
                      _QuestionSubBadge(
                        icon: PhosphorIconsRegular.filePdf,
                        label: relatedMaterialTitle,
                        isDark: isDark,
                        color: const Color(0xFFEF4444),
                      )
                    else if (question.fkIdMaterial != null && question.fkIdMaterial!.isNotEmpty)
                      _QuestionSubBadge(
                        icon: PhosphorIconsRegular.fileText,
                        label: 'Materi ID: ${question.fkIdMaterial}',
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          if (onViewDetails != null) ...[
            Container(height: 1, color: dividerColor),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onViewDetails!(question),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.eye,
                        size: 15,
                        color: accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Lihat Detail Soal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        PhosphorIconsRegular.arrowRight,
                        size: 14,
                        color: accent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  _QuestionSubBadge  — badge info kecil (jumlah opsi / materi)
// ──────────────────────────────────────────────────────────────────────────────
class _QuestionSubBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _QuestionSubBadge({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: c,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
