import 'package:flutter/material.dart';

import '../../models/question.dart';

class PageMenuQuizResultStudent extends StatefulWidget {
  final List<Question> questions;
  final Map<String, String> answers; // qid -> choice id
  final int score; // percentage
  final List<dynamic> perQuestion; // optional server per-question detail

  const PageMenuQuizResultStudent({super.key, required this.questions, required this.answers, required this.score, this.perQuestion = const []});

  @override
  State<PageMenuQuizResultStudent> createState() => _PageMenuQuizResultStudentState();
}

class _PageMenuQuizResultStudentState extends State<PageMenuQuizResultStudent> {
  int _selectedIndex = 0;

  void _gotoQuestion(int idx) {
    if (idx < 0 || idx >= widget.questions.length) return;
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final answers = widget.answers;
    final score = widget.score;
    // Build map from perQuestion if server provided detailed per-question info
    final Map<String, Map<String, dynamic>> serverPerQ = {};
    for (var pq in widget.perQuestion) {
      try {
        final qid = (pq['question_id'] ?? '').toString();
        if (qid.isNotEmpty) serverPerQ[qid] = Map<String, dynamic>.from(pq as Map);
      } catch (_) {}
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              color: const Color(0xFFDD6A2B),
              child: Center(child: Text('Result Quiz', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white))),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('Quiz Points', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                        child: Text('$score/100 points', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Text('Question Numbers', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(questions.length, (i) {
                            final q = questions[i];
                            final answered = answers.containsKey(q.idQuestion);
                            final selected = answers[q.idQuestion];
                            // determine correctness: prefer server-provided per-question result when available
                            bool correct = false;
                            final serverInfo = serverPerQ[q.idQuestion];
                            if (serverInfo != null) {
                              correct = serverInfo['is_correct'] == true || serverInfo['is_correct'] == 1;
                            } else {
                              correct = q.answerChoices.any((c) => c.idAnswerChoice == selected && c.isCorrect);
                            }
                            return InkWell(
                              onTap: () => _gotoQuestion(i),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: i == _selectedIndex ? Colors.blue : (correct ? Colors.green : (answered ? Colors.grey.shade300 : Colors.grey.shade100)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(child: Text('${i + 1}')),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 16),
                      if (questions.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Question', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${questions[_selectedIndex].number}. ${questions[_selectedIndex].question}'),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: questions[_selectedIndex].answerChoices.map((c) {
                                      final qid = questions[_selectedIndex].idQuestion;
                                      final selected = (answers[qid] ?? '') == c.idAnswerChoice;
                                      // Prefer server-provided per-question info when available
                                      final serverInfo = serverPerQ[qid];
                                      String? correctId;
                                      if (serverInfo != null) {
                                        correctId = (serverInfo['correct_choice_id'] ?? serverInfo['correct_choice_id']?.toString())?.toString();
                                      }
                                      Color textColor = Colors.black;
                                      if (serverInfo != null) {
                                        final selId = (answers[qid] ?? '').toString();
                                        final choiceId = c.idAnswerChoice.toString();
                                        if (selId.isNotEmpty && correctId != null && selId == correctId && choiceId == correctId) {
                                          // Student selected the correct answer
                                          textColor = Colors.green;
                                        } else if (selId.isNotEmpty && correctId != null && selId != correctId && choiceId == selId) {
                                          // Student selected wrong answer
                                          textColor = Colors.red;
                                        } else if (correctId != null && choiceId == correctId) {
                                          // show the correct answer in green
                                          textColor = Colors.green;
                                        }
                                      } else {
                                        // fallback: use choice's isCorrect if available
                                        final correct = c.isCorrect;
                                        if (selected && !correct) textColor = Colors.red;
                                        if (correct) textColor = Colors.green;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Row(
                                          children: [
                                            Radio<String>(value: c.idAnswerChoice, groupValue: answers[questions[_selectedIndex].idQuestion], onChanged: null),
                                            Expanded(child: Text(c.content, style: TextStyle(color: textColor))),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
