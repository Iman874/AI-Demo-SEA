import 'package:flutter/material.dart';
import '../../models/question.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: questions.length > 2 ? 220 : null,
        child: questions.isEmpty
            ? Container(
                alignment: Alignment.center,
                child: Text(
                  "No questions added yet.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: questions.length > 2
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, i) {
                  final q = questions[i];
                  if (itemBuilder != null) {
                    return itemBuilder!(context, q, i);
                  }
                  // Resolve related material (support persisted Map or local material objects)
                  dynamic relatedMaterial;
                  String? relatedTitle;
                  final needle = q.fkIdMaterial?.toString().trim() ?? '';
                  if (materials != null && needle.isNotEmpty) {
                    try {
                      for (final m in materials!) {
                        try {
                          // gather candidate ids for this material
                          final candidates = <String>[];
                          if (m is Map) {
                            if (m['id_material'] != null) candidates.add(m['id_material'].toString());
                            if (m['id'] != null) candidates.add(m['id'].toString());
                            if (m['tmp_id'] != null) candidates.add(m['tmp_id'].toString());
                          } else {
                            // try common property names on object
                            try {
                              final dynId = (m.id ?? (m.id_material ?? m.tmp_id));
                              if (dynId != null) candidates.add(dynId.toString());
                            } catch (_) {}
                          }
                          // normalize and compare
                          final found = candidates.map((c) => c.trim()).any((c) => c == needle);
                          if (found) {
                            relatedMaterial = m;
                            break;
                          }
                        } catch (_) {
                          // ignore and continue
                        }
                      }
                    } catch (e) {
                      relatedMaterial = null;
                    }
                    // extract title safely
                    if (relatedMaterial != null) {
                      try {
                        if (relatedMaterial is Map) {
                          relatedTitle = (relatedMaterial['title'] ?? relatedMaterial['name'] ?? '').toString();
                        } else {
                          // try to read common properties
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
                        top: questions.length > 2 ? 6 : 10,
                        bottom: questions.length > 2 ? 6 : 10,
                        right: questions.length > 2 ? 20 : 0,
                      ),
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "No. ${q.number}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "${q.poin} poin",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (relatedMaterial != null) ...[
                                          const Text(
                                            "Related Material:",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Image.asset(
                                            'assets/icon/pdf_icon.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              // compute display title defensively
                                              relatedMaterial is Map
                                                  ? (relatedMaterial['title'] ?? relatedMaterial['name'] ?? '')?.toString() ?? ''
                                                  : ((relatedMaterial.title ?? relatedMaterial.name)?.toString() ?? ''),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ] else if (q.fkIdMaterial != null) ...[
                                          // debug fallback: show the fk id so we can inspect mismatches
                                          const SizedBox(width: 8),
                                          Text(
                                            'Related id: ${q.fkIdMaterial}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ],
                                    ),
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6B6B6B),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      onPressed: onViewDetails != null ? () => onViewDetails!(q) : null,
                                      child: const Text(
                                        "Details",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Hanya tampilkan tombol Edit jika onEdit != null
                                  if (onEdit != null)
                                    SizedBox(
                                      width: 80,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF5CA1BF),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                        ),
                                        onPressed: () => onEdit!(q),
                                        child: const Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // Hanya tampilkan tombol x jika onDelete != null
                      if (onDelete != null)
                        Positioned(
                          top: questions.length > 2 ? 0 : -10,
                          right: questions.length > 2 ? 0 : -10,
                          child: InkWell(
                            onTap: () => onDelete!(q),
                            child: Image.asset(
                              'assets/icon/x_icon.png',
                              width: 32,
                              height: 32,
                            ),
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
