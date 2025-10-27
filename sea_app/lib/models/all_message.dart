class MessageModel {
  final String id;
  final String chatRoomId; // bisa id_discussionroom atau id_chatroomai
  final String senderId;   // userId atau "ai"
  final String role;       // "user", "teacher", "student", "ai"
  final String content;
  final String contentType; // "text", "image", "file"
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.role,
    required this.content,
    required this.contentType,
    required this.createdAt,
  });
}

// contoh dummy message
final List<MessageModel> sampleMessages = [];
