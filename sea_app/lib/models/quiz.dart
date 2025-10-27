class Quiz {
  final String idQuiz;
  final String title;
  final int duration; // in minutes
  final String createBy; // fk_id_user
  final DateTime createAt;
  final DateTime updateAt;

  Quiz({
    required this.idQuiz,
    required this.title,
    required this.duration,
    required this.createBy,
    required this.createAt,
    required this.updateAt,
  });
}

// contoh dummy data
final List<Quiz> sampleQuizzes = [
  Quiz(
    idQuiz: "q1",
    title: "Quiz 1",
    duration: 30,
    createBy: "u1",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  Quiz(
    idQuiz: "q2",
    title: "Quiz 2",
    duration: 45,
    createBy: "u1",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  Quiz(
    idQuiz: "q3",
    title: "Quiz 3",
    duration: 40,
    createBy: "u1",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
  Quiz(
    idQuiz: "q4",
    title: "Quiz 4",
    duration: 25,
    createBy: "u1",
    createAt: DateTime.now(),
    updateAt: DateTime.now(),
  ),
];
