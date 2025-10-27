class QuizResult {
  final String idResultQuiz;
  final int score;
  final String status;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String fkIdQuiz;
  final String fkIdUser;
  final DateTime createAt;
  final DateTime updateAt;

  QuizResult({
    required this.idResultQuiz,
    required this.score,
    required this.status,
    required this.startedAt,
    required this.finishedAt,
    required this.fkIdQuiz,
    required this.fkIdUser,
    required this.createAt,
    required this.updateAt,
  });
}

// Dummy data
final List<QuizResult> sampleQuizResults = [
  QuizResult(
    idResultQuiz: "r1",
    score: 80,
    status: "completed",
    startedAt: DateTime.now().subtract(const Duration(hours: 2)),
    finishedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    fkIdQuiz: "q1",
    fkIdUser: "u2",
    createAt: DateTime.now().subtract(const Duration(hours: 2)),
    updateAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
  ),
  QuizResult(
    idResultQuiz: "r2",
    score: 95,
    status: "completed",
    startedAt: DateTime.now().subtract(const Duration(hours: 3)),
    finishedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    fkIdQuiz: "q2",
    fkIdUser: "u2",
    createAt: DateTime.now().subtract(const Duration(hours: 3)),
    updateAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
  ),
];
