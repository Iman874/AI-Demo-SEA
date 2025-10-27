class AnswerQuestion {
  final String idAnswerChoice;
  final String content;
  final bool isCorrect;
  final DateTime createAt;
  final DateTime updateAt;

  AnswerQuestion({
    required this.idAnswerChoice,
    required this.content,
    required this.isCorrect,
    required this.createAt,
    required this.updateAt,
  });
}
