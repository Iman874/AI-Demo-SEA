class MaterialPdf {
  final String id;
  final String title;
  final String content; // bisa path file / text langsung
  final String type; // "pdf", "text"
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialPdf({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });
}

extension MaterialPdfJson on MaterialPdf {
  static MaterialPdf fromJson(Map<String, dynamic> json) {
    return MaterialPdf(
      id: json['id']?.toString() ?? json['id_material']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}


