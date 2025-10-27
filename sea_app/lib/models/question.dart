import 'answer_question.dart';

class Question {
  final String idQuestion;
  final int number;
  final String question;
  final int poin;
  final String fkIdQuiz;
  final String? fkIdMaterial; // <-- tambahkan ini
  final List<AnswerQuestion> answerChoices;
  final DateTime createAt;
  final DateTime updateAt;

  Question({
    required this.idQuestion,
    required this.number,
    required this.question,
    required this.poin,
    required this.fkIdQuiz,
    this.fkIdMaterial, // <-- tambahkan ini
    required this.answerChoices,
    required this.createAt,
    required this.updateAt,
  });
}
