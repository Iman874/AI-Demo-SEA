class QuizStudent {
  final String idQuizStudent;
  final String fkIdClass;
  final String fkQuiz;
  final String fkIdUser;
  final DateTime createAt;
  final DateTime updateAt;

  QuizStudent({
    required this.idQuizStudent,
    required this.fkIdClass,
    required this.fkQuiz,
    required this.fkIdUser,
    required this.createAt,
    required this.updateAt,
  });
}

// dummy quiz-student data removed; quizzes should be fetched from API per-user.
