import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class CardQuestionList extends StatelessWidget {
  final List<Question> questions;
  final void Function(Question)? onViewDetails;
  final void Function(Question)? onEdit;
  final void Function(Question)? onDelete;
  final Widget Function(BuildContext context, Question q, int i)? itemBuilder;
  final List? materials;

  const CardQuestionList({
    super.key,
    required this.questions,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.itemBuilder,
    this.materials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding, vertical: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.elevatedCard(context),
      child: SizedBox(
        height: questions.length > 2 ? 220 : null,
        child: questions.isEmpty
            ? Center(
                child: Text(
                  "No questions added yet.",
                  style: AppTextStyles.bodyMd(context),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: questions.length > 2 ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, i) {
                  final q = questions[i];
                  if (itemBuilder != null) {
                    return itemBuilder!(context, q, i);
                  }
                  dynamic relatedMaterial;
                  String? relatedTitle;
                  final needle = q.fkIdMaterial?.toString().trim() ?? '';
                  if (materials != null && needle.isNotEmpty) {
                    try {
                      for (final m in materials!) {
                        try {
                          final candidates = <String>[];
                          if (m is Map) {
                            if (m['id_material'] != null) candidates.add(m['id_material'].toString());
                            if (m['id'] != null) candidates.add(m['id'].toString());
                            if (m['tmp_id'] != null) candidates.add(m['tmp_id'].toString());
                          } else {
                            try {
                              final dynId = (m.id ?? (m.id_material ?? m.tmp_id));
                              if (dynId != null) candidates.add(dynId.toString());
                            } catch (_) {}
                          }
                          final found = candidates.map((c) => c.trim()).any((c) => c == needle);
                          if (found) {
                            relatedMaterial = m;
                            break;
                          }
                        } catch (_) {}
                      }
                    } catch (e) {
                      relatedMaterial = null;
                    }
                    if (relatedMaterial != null) {
                      try {
                        if (relatedMaterial is Map) {
                          relatedTitle = (relatedMaterial['title'] ?? relatedMaterial['name'] ?? '').toString();
                        } else {
                          try {
                            final t = relatedMaterial.title;
                            if (t != null && t.toString().isNotEmpty) relatedTitle = t.toString();
                          } catch (_) {}
                          if (relatedTitle == null) {
                            try {
                              final t2 = relatedMaterial.name;
                              if (t2 != null && t2.toString().isNotEmpty) relatedTitle = t2.toString();
                            } catch (_) {}
                          }
                          relatedTitle = relatedTitle ?? '';
                        }
                      } catch (e) {
                        relatedTitle = null;
                      }
                    }
                  }
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: questions.length > 2 ? AppSpacing.xs : AppSpacing.sm,
                          bottom: questions.length > 2 ? AppSpacing.xs : AppSpacing.sm,
                          right: questions.length > 2 ? AppSpacing.xl : 0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: AppDecorations.borderRadiusSm,
                          boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: AppDecorations.borderRadiusSm,
                                          ),
                                          child: Text(
                                            "No. ${q.number}",
                                            style: AppTextStyles.bodySm(context).copyWith(color: Colors.white),
                                          ),
                                        ),
                                        AppSpacing.wMd,
                                        Text(
                                          "${q.poin} poin",
                                          style: AppTextStyles.titleMd(context),
                                        ),
                                      ],
                                    ),
                                    AppSpacing.hMd,
                                    if (relatedMaterial != null) ...[
                                      Row(
                                        children: [
                                          Text("Related Material:", style: AppTextStyles.bodySm(context)),
                                          AppSpacing.wSm,
                                          Image.asset('assets/icon/pdf_icon.png', width: 20, height: 20),
                                          AppSpacing.wXs,
                                          Flexible(
                                            child: Text(
                                              relatedMaterial is Map
                                                  ? (relatedMaterial['title'] ?? relatedMaterial['name'] ?? '')?.toString() ?? ''
                                                  : ((relatedMaterial.title ?? relatedMaterial.name)?.toString() ?? ''),
                                              style: AppTextStyles.bodySm(context),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else if (q.fkIdMaterial != null) ...[
                                      Row(
                                        children: [
                                          AppSpacing.wSm,
                                          Text(
                                            'Related id: ${q.fkIdMaterial}',
                                            style: AppTextStyles.bodySm(context).copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: onViewDetails != null ? () => onViewDetails!(q) : null,
                                      child: const Text("Details", style: TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                  if (onEdit != null) ...[
                                    AppSpacing.hXs,
                                    SizedBox(
                                      width: 80,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.secondary,
                                        ),
                                        onPressed: () => onEdit!(q),
                                        child: const Text("Edit", style: TextStyle(fontSize: 11, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (onDelete != null)
                        Positioned(
                          top: questions.length > 2 ? 0 : -10,
                          right: questions.length > 2 ? 0 : -10,
                          child: InkWell(
                            onTap: () => onDelete!(q),
                            child: Image.asset('assets/icon/x_icon.png', width: 32, height: 32),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
