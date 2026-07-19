import 'package:flutter/material.dart';
import '../../models/summary_discussion.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardConclusionStudent extends StatelessWidget {
  final List<SummaryDiscussion> summaries;
  final void Function(SummaryDiscussion)? onView;

  const CardConclusionStudent({super.key, required this.summaries, this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summaries.isEmpty
            ? [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Text('No summaries yet.', style: AppTextStyles.bodyMd(context)),
                )
              ]
            : summaries
                .map((s) => ListTile(
                      title: Text(s.content, style: AppTextStyles.bodyMd(context)),
                      subtitle: Text('By: ${s.fkIdUser ?? 'unknown'}', style: AppTextStyles.bodySm(context)),
                      trailing: TextButton(
                        onPressed: onView != null ? () => onView!(s) : null,
                        child: const Text('View Details'),
                      ),
                    ))
                .toList(),
      ),
    );
  }
}
