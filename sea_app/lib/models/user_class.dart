class UserClass {
  final String idUserClass;
  final DateTime joinedAt;
  final String fkIdClass;
  final String fkIdUser;
  final DateTime createAt;
  final DateTime updateAt;

  UserClass({
    required this.idUserClass,
    required this.joinedAt,
    required this.fkIdClass,
    required this.fkIdUser,
    required this.createAt,
    required this.updateAt,
  });
}