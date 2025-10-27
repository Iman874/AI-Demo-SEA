class ResultUnderstanding {
  final String id;
  final String type;
  final String? fkIdSummaryDiscussion;

  ResultUnderstanding({required this.id, required this.type, this.fkIdSummaryDiscussion});

  static ResultUnderstanding fromJson(Map<String, dynamic> j) {
    return ResultUnderstanding(
      id: (j['id_resultunderstanding'] ?? j['id'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      fkIdSummaryDiscussion: (j['fk_id_summarydiscussion'] ?? j['fk_id_summarydiscussion'])?.toString(),
    );
  }
}
