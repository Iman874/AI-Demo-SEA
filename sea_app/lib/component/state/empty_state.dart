import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: cs.primary.withValues(alpha: 0.5)),
            ),
            AppSpacing.hXxl,
            Text(title, style: AppTextStyles.titleMd(context)),
            if (subtitle != null) ...[
              AppSpacing.hSm,
              Text(subtitle!, style: AppTextStyles.bodySm(context), textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              AppSpacing.hLg,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
