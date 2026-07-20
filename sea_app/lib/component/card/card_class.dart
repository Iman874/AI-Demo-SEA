import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/class.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardClassList extends StatelessWidget {
  final List<ClassModel> classes;

  const CardClassList({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
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
                PhosphorIconsRegular.chalkboardTeacher,
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum Ada Kelas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Daftar kelas pembelajaran Anda akan tampil di sini',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: classes.map((c) => _ClassItemCard(classModel: c)).toList(),
      ),
    );
  }
}

class _ClassItemCard extends StatelessWidget {
  final ClassModel classModel;

  const _ClassItemCard({required this.classModel});

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mnt lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 30) return "${diff.inDays} hari lalu";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} bln lalu";
    return "${(diff.inDays / 365).floor()} thn lalu";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final relTime = _relativeTime(classModel.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          // Icon Container Aksen
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              PhosphorIconsRegular.bookOpenText,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info Kelas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classModel.name,
                  style: AppTextStyles.titleMd(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Row metadata: kode + semester + last updated
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    // Kode kelas badge abu neutral
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        classModel.codeClass,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (classModel.semester.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsRegular.calendar,
                            size: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            classModel.semester,
                            style: AppTextStyles.bodySm(context).copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.clock,
                          size: 11,
                          color: isDark ? Colors.white30 : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "Diperbarui $relTime",
                          style: AppTextStyles.bodySm(context).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white30 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge Chip "Aktif" — hijau (semantic), bukan biru
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(PhosphorIconsRegular.circle, size: 6, color: Color(0xFF10B981)),
                SizedBox(width: 5),
                Text(
                  "Aktif",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
