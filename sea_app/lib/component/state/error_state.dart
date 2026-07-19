import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
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
            Icon(Icons.error_outline, size: 60, color: cs.error),
            AppSpacing.hLg,
            Text(message, style: AppTextStyles.bodyMd(context).copyWith(color: cs.error), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              AppSpacing.hLg,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
