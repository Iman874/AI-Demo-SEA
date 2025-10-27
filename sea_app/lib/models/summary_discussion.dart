class SummaryDiscussion {
  final String id;
  final String content;
  final String? fkIdUser;
  final String? fkIdChatroomAi;

  SummaryDiscussion({required this.id, required this.content, this.fkIdUser, this.fkIdChatroomAi});

  static SummaryDiscussion fromJson(Map<String, dynamic> j) {
    return SummaryDiscussion(
      id: (j['id_summarydiscussion'] ?? j['id'] ?? '').toString(),
      content: (j['content'] ?? '').toString(),
      fkIdUser: (j['fk_id_user'] ?? j['fk_id_user'])?.toString(),
      fkIdChatroomAi: (j['fk_id_chatroomai'] ?? j['fk_id_chatroomai'])?.toString(),
    );
  }
}
