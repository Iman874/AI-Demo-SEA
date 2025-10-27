class QuizClass {
  final String idQuizClass;
  final String fkIdClass;
  final String fkIdQuiz;
  final DateTime createAt;
  final DateTime updateAt;

  QuizClass({
    required this.idQuizClass,
    required this.fkIdClass,
    required this.fkIdQuiz,
    required this.createAt,
    required this.updateAt,
  });
}

// Dummy data
final List<QuizClass> dummyQuizClasses = [
  QuizClass(
    idQuizClass: "qc1",
    fkIdClass: "1",
    fkIdQuiz: "q1",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  QuizClass(
    idQuizClass: "qc2",
    fkIdClass: "2",
    fkIdQuiz: "q2",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  QuizClass(
    idQuizClass: "qc3",
    fkIdClass: "1",
    fkIdQuiz: "q3",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  QuizClass(
    idQuizClass: "qc4",
    fkIdClass: "3",
    fkIdQuiz: "q4",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
];
