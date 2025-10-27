class DiscussionQuestion {
  final String id;
  final String? fkIdChatroomAi;
  final String? fkIdUser;
  final String content;

  DiscussionQuestion({required this.id, this.fkIdChatroomAi, this.fkIdUser, required this.content});

  static DiscussionQuestion fromJson(Map<String, dynamic> j) {
    return DiscussionQuestion(
      id: (j['id_discussionquestion'] ?? j['id'] ?? '').toString(),
      fkIdChatroomAi: (j['fk_id_chatroomai'] ?? j['fk_id_chatroomai'])?.toString(),
      fkIdUser: (j['fk_id_user'] ?? j['fk_id_user'])?.toString(),
      content: (j['content'] ?? '').toString(),
    );
  }
}
