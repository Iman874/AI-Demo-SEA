import 'package:flutter/material.dart';
import '../../models/quiz.dart';

class CardQuizList extends StatelessWidget {
  final List<Quiz> quizzes;
  final void Function(Quiz)? onViewResult;
  final String buttonLabel;

  const CardQuizList({
    super.key,
    required this.quizzes,
    this.onViewResult,
    this.buttonLabel = "View Quiz Results",
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
        height: quizzes.length > 4 ? 220 : null,
        child: ListView.builder(
          shrinkWrap: true,
          physics: quizzes.length > 4
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: quizzes.length,
          itemBuilder: (context, i) {
            final q = quizzes[i];
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
                    q.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 12,
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
                      onPressed: onViewResult != null
                          ? () => onViewResult!(q)
                          : null,
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
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
