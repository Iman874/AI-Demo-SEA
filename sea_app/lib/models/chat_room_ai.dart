class ChatRoomAI {
  final String id;
  final String title;
  final String description;
  final String createdBy; // userId
  final String aiModel;
  final DateTime createdAt;

  ChatRoomAI({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.aiModel,
    required this.createdAt,
  });
}

// contoh dummy
final ChatRoomAI sampleChatRoomAI = ChatRoomAI(
  id: "c1",
  title: "AI Assistant - Physics",
  description: "Diskusi dengan AI tentang fisika dasar",
  createdBy: "u1",
  aiModel: "gemini-2.0-flash",
  createdAt: DateTime.now(),
);
