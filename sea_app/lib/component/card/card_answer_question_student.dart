import 'package:flutter/material.dart';
import '../../models/discussion_question.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardAnswerQuestionStudent extends StatelessWidget {
  final List<DiscussionQuestion> questions;
  final void Function(DiscussionQuestion)? onViewDetails;

  const CardAnswerQuestionStudent({super.key, required this.questions, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions.isEmpty
            ? [
                Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Text('No questions yet.', style: AppTextStyles.bodyMd(context)),
                )
              ]
            : questions
                .map((q) => ListTile(
                      title: Text(q.content, style: AppTextStyles.bodyMd(context)),
                      subtitle: Text('By: ${q.fkIdUser ?? 'unknown'}', style: AppTextStyles.bodySm(context)),
                      trailing: TextButton(
                        onPressed: onViewDetails != null ? () => onViewDetails!(q) : null,
                        child: const Text('View Details'),
                      ),
                    ))
                .toList(),
      ),
    );
  }
}
