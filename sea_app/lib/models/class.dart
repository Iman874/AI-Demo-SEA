class ClassModel {
  final String idClass;
  final String codeClass;
  final String name;
  final String description;
  final String semester;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.idClass,
    required this.codeClass,
    required this.name,
    required this.description,
    required this.semester,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}

extension ClassModelJson on ClassModel {
  static ClassModel fromJson(Map<String, dynamic> json) {
    return ClassModel(
      idClass: json['idClass']?.toString() ?? json['id']?.toString() ?? json['id_class']?.toString() ?? '',
      codeClass: json['codeClass']?.toString() ?? json['code_class']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      semester: json['semester']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
