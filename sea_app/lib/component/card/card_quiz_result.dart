import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.elevatedCard(context),
      child: results.isEmpty
          ? Center(
              child: Text(
                "No quiz results.",
                style: AppTextStyles.bodyMd(context),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: results.length > 4 ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final r = results[i];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: AppDecorations.borderRadiusSm,
                    boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quiz: ${r.fkIdQuiz} | Score: ${r.score}",
                                style: AppTextStyles.titleMd(context),
                              ),
                              Text(
                                "Status: ${r.status}",
                                style: AppTextStyles.bodySm(context),
                              ),
                              Text(
                                "Started: ${r.startedAt}",
                                style: AppTextStyles.bodySm(context),
                              ),
                              Text(
                                "Finished: ${r.finishedAt}",
                                style: AppTextStyles.bodySm(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: onViewDetails != null ? () => onViewDetails!(r) : null,
                            child: const Text("View Quiz Results", style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
