class DiscussionRoom {
  final String idDiscussionRoom;
  final String title;
  final String description;
  final String tag;
  final String status; // "active" atau "completed"
  final String createdBy; // fk_id_user
  final String fkIdClass;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool chatroomActive;
  final String? chatroomId;
  final int? numGroups;
  final int? studentsPerGroup;

  DiscussionRoom({
    required this.idDiscussionRoom,
    required this.title,
    required this.description,
    required this.tag,
    required this.status,
    required this.createdBy,
    required this.fkIdClass,
    required this.createdAt,
    required this.updatedAt,
    this.chatroomActive = false,
    this.chatroomId,
    this.numGroups,
    this.studentsPerGroup,
  });
}

  extension DiscussionRoomJson on DiscussionRoom {
    static DiscussionRoom fromJson(Map<String, dynamic> json) {
      final chatroom = json['chatroom'];
      final bool active = (json['chatroom_active'] == true) || (chatroom != null && (chatroom['status']?.toString() ?? '') == 'active');
      final String? chatId = chatroom != null ? (chatroom['id_chatroomai']?.toString() ?? chatroom['id']?.toString()) : null;
      return DiscussionRoom(
        idDiscussionRoom: json['idDiscussionRoom']?.toString() ?? json['id_discussionroom']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        tag: json['tag']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString() ?? '',
        fkIdClass: json['fkIdClass']?.toString() ?? json['fk_id_class']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '') ?? DateTime.now(),
        chatroomActive: active,
        chatroomId: chatId,
        numGroups: (json['numGroups'] ?? json['num_groups']) != null ? int.tryParse((json['numGroups'] ?? json['num_groups']).toString()) : null,
        studentsPerGroup: (json['studentsPerGroup'] ?? json['students_per_group']) != null ? int.tryParse((json['studentsPerGroup'] ?? json['students_per_group']).toString()) : null,
      );
    }
  }
