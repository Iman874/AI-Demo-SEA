import 'package:flutter/material.dart';
import '../../component/card/card_material.dart';
import '../../component/card/card_question.dart';
import '../../models/quiz.dart';
import '../../models/material.dart';
import '../../models/question.dart';

class PageMenuQuizResultTeacher extends StatelessWidget {
  const PageMenuQuizResultTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final quiz = sampleQuizzes.first;
  final materials = <MaterialPdf>[];
    final questions = [
      Question(
        idQuestion: "q1",
        number: 1,
        question: "What is integral?",
        poin: 10,
        fkIdQuiz: quiz.idQuiz,
        fkIdMaterial: "m1",
        answerChoices: [],
        createAt: DateTime.now(),
        updateAt: DateTime.now(),
      ),
      Question(
        idQuestion: "q2",
        number: 2,
        question: "Explain Newton's law.",
        poin: 10,
        fkIdQuiz: quiz.idQuiz,
        fkIdMaterial: "m2",
        answerChoices: [],
        createAt: DateTime.now(),
        updateAt: DateTime.now(),
      ),
    ];
    final answers = [
      {"name": "Tulusna", "answer": "Integral adalah ..."},
      {"name": "Hafiz Priyadi", "answer": "Newton's law ..."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Quiz - Lihat Hasil"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Information", style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Quiz Title", quiz.title),
                    _infoRow("Quiz Duration", "1 Hour 30 Minute"),
                    _infoRow("Number of Questions", "50 Questions"),
                  ],
                ),
              ),
              // Quiz Material
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Material", style: Theme.of(context).textTheme.titleMedium),
              ),
              CardMaterialList(materials: materials),
              // Quiz Questions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Questions", style: Theme.of(context).textTheme.titleMedium),
              ),
              CardQuestionList(
                questions: questions,
                onViewDetails: (q) {},
                // Hapus itemBuilder, gunakan default CardQuestionList
              ),
              // Quiz Answers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Answers", style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
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
                child: Column(
                  children: answers.map((ans) => Container(
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
                        Text("Answer from ${ans['name']}", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
                        TextButton(
                          onPressed: () {},
                          child: const Text("View Details"),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text("Generate Discussion Group [AI]"),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }
}
