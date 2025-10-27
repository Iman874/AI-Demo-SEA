import 'package:flutter/material.dart';
import '../../models/summary_discussion.dart';

class CardConclusionStudent extends StatelessWidget {
  final List<SummaryDiscussion> summaries;
  final void Function(SummaryDiscussion)? onView;

  const CardConclusionStudent({super.key, required this.summaries, this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summaries.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No summaries yet.'),
                )
              ]
            : summaries
                .map((s) => ListTile(
                      title: Text(s.content),
                      subtitle: Text('By: ${s.fkIdUser ?? 'unknown'}'),
                      trailing: TextButton(onPressed: onView != null ? () => onView!(s) : null, child: const Text('View Details')),
                    ))
                .toList(),
      ),
    );
  }
}
