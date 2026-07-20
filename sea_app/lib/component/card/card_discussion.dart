import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/discussion_room.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/staggered_slide_up.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  CardDiscussionList  — daftar kartu diskusi dengan animasi staggered
// ──────────────────────────────────────────────────────────────────────────────
class CardDiscussionList extends StatelessWidget {
  final List<DiscussionRoom> discussions;
  final void Function(DiscussionRoom)? onViewDetails;
  final void Function(DiscussionRoom)? onEdit;
  final void Function(DiscussionRoom)? onDetails;
  final String? buttonLabel;

  const CardDiscussionList({
    super.key,
    required this.discussions,
    this.onViewDetails,
    this.onEdit,
    this.onDetails,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (discussions.isEmpty) return const _DiscussionEmptyState();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: discussions.asMap().entries.map((entry) {
          return StaggeredSlideUp(
            index: entry.key,
            child: _DiscussionItemCard(
              discussion: entry.value,
              onViewDetails: onViewDetails,
              onEdit: onEdit,
              onDetails: onDetails,
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
class _DiscussionEmptyState extends StatelessWidget {
  const _DiscussionEmptyState();

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
            child: Icon(PhosphorIconsRegular.chatsCircle, color: accent, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum Ada Diskusi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ruang diskusi akan muncul di sini\nsetelah tersedia untuk kelas ini',
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
//  _DiscussionItemCard  — kartu diskusi individual
//
//  Layout:
//    ┌─╠══════════════════════════════════════╗
//    │▋║  [icon+dot]  Judul Diskusi          ║
//    │ ║              [● Aktif] [✦ AI Aktif] ║
//    │ ╠──────────────────────────────────────╣
//    │ ║  💬  Masuk Diskusi          →       ║
//    └─╚══════════════════════════════════════╝
// ──────────────────────────────────────────────────────────────────────────────
class _DiscussionItemCard extends StatelessWidget {
  final DiscussionRoom discussion;
  final void Function(DiscussionRoom)? onViewDetails;
  final void Function(DiscussionRoom)? onEdit;
  final void Function(DiscussionRoom)? onDetails;
  final String? buttonLabel;

  const _DiscussionItemCard({
    required this.discussion,
    this.onViewDetails,
    this.onEdit,
    this.onDetails,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final accentDark = Color.lerp(accent, Colors.black, 0.22)!;
    final isOpen = discussion.status == 'open';
    final hasAi = discussion.chatroomActive == true;

    final statusColor =
        isOpen ? AppColors.success : (isDark ? const Color(0xFF6B7A8D) : const Color(0xFF9AA5B4));
    final cardBg = isDark ? AppColors.cardDark : Colors.white;
    final borderColor = isDark ? AppColors.borderDark : const Color(0xFFE2E8F0);
    final dividerColor = isDark ? AppColors.borderDark : const Color(0xFFEFF2F7);

    final label = buttonLabel ?? (isOpen ? 'Masuk Diskusi' : 'Lihat Detail');

    void handleTap() {
      if (isOpen) {
        if (onEdit != null) return onEdit!(discussion);
        if (onViewDetails != null) return onViewDetails!(discussion);
      } else {
        if (onDetails != null) return onDetails!(discussion);
        if (onViewDetails != null) return onViewDetails!(discussion);
      }
    }

    final bool hasTap = isOpen
        ? (onEdit != null || onViewDetails != null)
        : (onDetails != null || onViewDetails != null);

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
                      colors: isOpen
                          ? [accent, accentDark]
                          : [statusColor, statusColor.withValues(alpha: 0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),

                // Icon with status dot
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (isOpen ? accent : statusColor).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIconsFill.chatsCircle,
                        color: isOpen ? accent : statusColor,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBg, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Title + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion.title,
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
                          // Status badge
                          _DiscussionBadge(
                            dot: true,
                            label: isOpen ? 'Aktif' : 'Selesai',
                            color: statusColor,
                          ),
                          // AI badge (only if active & chatroom on)
                          if (isOpen && hasAi)
                            _DiscussionBadge(
                              icon: PhosphorIconsRegular.sparkle,
                              label: 'AI Aktif',
                              color: const Color(0xFF8B5CF6),
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
              onTap: hasTap ? handleTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      isOpen
                          ? PhosphorIconsRegular.chatCircle
                          : PhosphorIconsRegular.info,
                      size: 15,
                      color: hasTap ? accent : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasTap ? accent : Colors.grey.shade400,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      PhosphorIconsRegular.arrowRight,
                      size: 14,
                      color: hasTap ? accent : Colors.grey.shade400,
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
//  _DiscussionBadge  — pill badge kecil untuk status & info
// ──────────────────────────────────────────────────────────────────────────────
class _DiscussionBadge extends StatelessWidget {
  final IconData? icon;
  final bool dot;
  final String label;
  final Color color;

  const _DiscussionBadge({
    this.icon,
    this.dot = false,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 11, color: color),
            const SizedBox(width: 4),
          ] else if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
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
