import 'package:flutter/material.dart';
import '../../models/result_understanding.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardPercentageUnderstanding extends StatelessWidget {
  final List<ResultUnderstanding> items;

  const CardPercentageUnderstanding({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.card(context),
      child: items.isEmpty
          ? Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Text('No understanding results.', style: AppTextStyles.bodyMd(context)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((r) => Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Type: ${r.type}', style: AppTextStyles.bodyMd(context)),
                            Text('id: ${r.id}', style: AppTextStyles.bodySm(context)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
