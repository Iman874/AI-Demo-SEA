class User {
  final String id;
  final String name;
  final String role; // "student" atau "teacher"
  final String email;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String idStr;
    if (json.containsKey('id_user')) {
      idStr = json['id_user'].toString();
    } else if (json.containsKey('id')) {
      idStr = json['id'].toString();
    } else {
      idStr = '';
    }
    return User(
      id: idStr,
      name: json['name'] ?? '',
      role: json['role'] ?? 'student',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'email': email,
      };
}

// NOTE: dummy user instances removed. Use AuthProvider.user instead.
