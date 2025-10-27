import 'package:flutter/material.dart';
import '../../models/discussion_room.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
        height: discussions.length > 4 ? 220 : null,
        child: ListView.builder(
          shrinkWrap: true,
          physics: discussions.length > 4
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: discussions.length,
          itemBuilder: (context, i) {
            final d = discussions[i];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // preserve compatibility: prefer explicit handlers, fall back to onViewDetails
                      if (d.status == 'open') {
                        if (onEdit != null) return onEdit!(d);
                        if (onViewDetails != null) return onViewDetails!(d);
                      } else {
                        if (onDetails != null) return onDetails!(d);
                        if (onViewDetails != null) return onViewDetails!(d);
                      }
                    },
                    child: Text(
                      buttonLabel ?? (d.status == 'open' ? 'Edit' : 'Details'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[200]
                            : const Color(0xFF1B3C53),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
