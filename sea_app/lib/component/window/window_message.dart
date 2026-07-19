import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class WindowMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onOk;

  const WindowMessage({super.key, required this.message, this.onOk});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: EdgeInsets.all(AppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: AppDecorations.borderRadiusLg),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppDecorations.borderRadiusLg,
            ),
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSpacing.hSm,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(message, style: AppTextStyles.bodyLg(context)),
                    ),
                    AppSpacing.hXxl,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onOk ?? () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("OK", style: AppTextStyles.labelLg(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close, color: cs.error, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
