import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: results.isEmpty
          ? const Center(
              child: Text(
                "No quiz results.",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: results.length > 4
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, i) {
                final r = results[i];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quiz: ${r.fkIdQuiz} | Score: ${r.score}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Status: ${r.status}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                "Started: ${r.startedAt}",
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                "Finished: ${r.finishedAt}",
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(const Color(0xFF6B6B6B)),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              ),
                            ),
                            onPressed: onViewDetails != null
                                ? () => onViewDetails!(r)
                                : null,
                            child: const Text(
                              "View Quiz Results",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
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
