import 'package:flutter/material.dart';
import '../../models/discussion_room.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';
import '../ui/app_button.dart';

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
    if (discussions.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.card(context),
        child: Center(
          child: Text(
            "Belum ada ruang diskusi tersedia",
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
        children: discussions.map((d) {
          return _DiscussionItemCard(
            discussion: d,
            onViewDetails: onViewDetails,
            onEdit: onEdit,
            onDetails: onDetails,
            buttonLabel: buttonLabel,
          );
        }).toList(),
      ),
    );
  }
}

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isOpen = discussion.status == 'open';

    final label = buttonLabel ?? (isOpen ? 'Edit' : 'Detail');

    void handleTap() {
      if (isOpen) {
        if (onEdit != null) return onEdit!(discussion);
        if (onViewDetails != null) return onViewDetails!(discussion);
      } else {
        if (onDetails != null) return onDetails!(discussion);
        if (onViewDetails != null) return onViewDetails!(discussion);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: isDark ? const Color(0xFF1F2D40) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
      ),
      child: Row(
        children: [
          // Icon Discussion Container dengan Dot Status
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (isOpen ? primaryColor : Colors.grey)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.forum_rounded,
                  color: isOpen ? primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOpen ? const Color(0xFF10B981) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Info Diskusi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion.title,
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
                    Text(
                      isOpen ? "Status: Terbuka" : "Status: Selesai",
                      style: AppTextStyles.bodySm(context).copyWith(
                        fontSize: 12,
                        color: isOpen
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // AppButton Pill
          AppButton.pill(
            label: label,
            onPressed: handleTap,
            color: isOpen ? primaryColor : Colors.grey.shade600,
            icon: isOpen ? Icons.edit_rounded : Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }
}
