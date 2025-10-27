import 'package:flutter/material.dart';
import '../../models/discussion_question.dart';

class CardAnswerQuestionStudent extends StatelessWidget {
  final List<DiscussionQuestion> questions;
  final void Function(DiscussionQuestion)? onViewDetails;

  const CardAnswerQuestionStudent({super.key, required this.questions, this.onViewDetails});

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
        children: questions.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No questions yet.'),
                )
              ]
            : questions
                .map((q) => ListTile(
                      title: Text(q.content),
                      subtitle: Text('By: ${q.fkIdUser ?? 'unknown'}'),
                      trailing: TextButton(onPressed: onViewDetails != null ? () => onViewDetails!(q) : null, child: const Text('View Details')),
                    ))
                .toList(),
      ),
    );
  }
}
