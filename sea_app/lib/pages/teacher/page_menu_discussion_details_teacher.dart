import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import '../../models/discussion_room.dart';
import '../../models/discussion_question.dart';
import '../../models/summary_discussion.dart';
import '../../models/result_understanding.dart';
import '../../component/card/card_answer_question_student.dart';
import '../../component/card/card_conclusion_student.dart';
import '../../component/card/card_percentage_understanding.dart';

class PageMenuDiscussionDetailsTeacher extends StatefulWidget {
  final String discussionId;
  const PageMenuDiscussionDetailsTeacher({super.key, required this.discussionId});

  @override
  State<PageMenuDiscussionDetailsTeacher> createState() => _PageMenuDiscussionDetailsTeacherState();
}

class _PageMenuDiscussionDetailsTeacherState extends State<PageMenuDiscussionDetailsTeacher> {
  DiscussionRoom? _discussion;
  List<DiscussionQuestion> _questions = [];
  List<SummaryDiscussion> _summaries = [];
  List<ResultUnderstanding> _understandings = [];
  bool _loading = true;
  String? _error;
  String? _className;
  int? _groupCount;
  int? _perGroup;
  int _pUnderstood = 0;
  int _pNotFully = 0;
  int _pNot = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dResp = await ApiService.getDiscussion(widget.discussionId);
      // DEBUG: print raw discussion response so backend payload can be inspected
      try {
        // print raw body
        print('[DEBUG] getDiscussion status=${dResp.statusCode} body=${dResp.body}');
      } catch (_) {}

      String? _resolvedChatId;
      if (dResp.statusCode == 200) {
        final body = jsonDecode(dResp.body);
        final disc = body['data']?['discussion'];
        // DEBUG: print the extracted discussion map
        try {
          print('[DEBUG] discussion payload=' + (disc != null ? disc.toString() : 'null'));
        } catch (_) {}

        if (disc != null) {
          // keep parsed model for fields the model knows about
          _discussion = DiscussionRoomJson.fromJson(disc as Map<String, dynamic>);

          // DEBUG: print specific group-related fields we expect from backend
          try {
            final numGVal = disc['numGroups'] ?? disc['num_groups'];
            final perGVal = disc['studentsPerGroup'] ?? disc['students_per_group'];
            final tag = (disc['tag'] ?? '').toString();
            print('[DEBUG] discussion.numGroups=${numGVal?.toString() ?? 'null'} studentsPerGroup=${perGVal?.toString() ?? 'null'} tag=$tag');
            // prefer server-provided numeric values if present
            if (numGVal != null) {
              try {
                _groupCount = int.tryParse(numGVal.toString());
              } catch (_) {}
            }
            if (perGVal != null) {
              try {
                _perGroup = int.tryParse(perGVal.toString());
              } catch (_) {}
            }
          } catch (_) {}

          // if still not available, try to parse group info from tag
          if (_groupCount == null || _perGroup == null) {
            try {
              final tag = (_discussion?.tag ?? '').toString();
              final nums = RegExp(r"(\d+)").allMatches(tag).map((m) => int.tryParse(m.group(0) ?? '')).where((e) => e != null).map((e) => e!).toList();
              if (nums.isNotEmpty) {
                _groupCount = nums.isNotEmpty ? nums[0] : null;
                _perGroup = nums.length > 1 ? nums[1] : null;
              }
            } catch (_) {}
          }

          // resolve chatroom id if provided in response (some endpoints return chatroomId)
          try {
            _resolvedChatId = (disc['chatroomId']?.toString()) ?? ((disc['chatroom'] != null) ? (disc['chatroom']['id_chatroomai']?.toString() ?? disc['chatroom']['id']?.toString()) : null);
          } catch (_) {}
        }
      }

      final chatId = _resolvedChatId ?? _discussion?.chatroomId;
      if (chatId != null) {
        final qResp = await ApiService.getDiscussionQuestions(chatroomId: chatId);
        if (qResp.statusCode == 200) {
          final qb = jsonDecode(qResp.body);
          final items = (qb['data'] as List<dynamic>?) ?? [];
          _questions = items.map((e) => DiscussionQuestion.fromJson(e as Map<String, dynamic>)).toList();
        }

        final sResp = await ApiService.getDiscussionSummariesDb(chatroomId: chatId);
        if (sResp.statusCode == 200) {
          final sb = jsonDecode(sResp.body);
          final items = (sb['data'] as List<dynamic>?) ?? [];
          _summaries = items.map((e) => SummaryDiscussion.fromJson(e as Map<String, dynamic>)).toList();
        }
      }

      // Fetch understanding results aggregated for the whole discussion (across all chatrooms)
      final uResp = await ApiService.getDiscussionUnderstandings(discussionId: widget.discussionId);
      if (uResp.statusCode == 200) {
        final ub = jsonDecode(uResp.body);
        final items = (ub['data'] as List<dynamic>?) ?? [];
        _understandings = items.map((e) => ResultUnderstanding.fromJson(e as Map<String, dynamic>)).toList();
        _computeUnderstandingStats();
      }

      // try resolve class name from classes endpoint if fkIdClass available
      if (_discussion != null && _discussion!.fkIdClass.isNotEmpty) {
        try {
          final cResp = await ApiService.getClasses();
          if (cResp.statusCode == 200) {
            final cb = jsonDecode(cResp.body);
            final clist = (cb['data'] as List<dynamic>?) ?? [];
            final found = clist.cast<Map<String, dynamic>>().firstWhere(
              (m) => (m['idClass']?.toString() ?? m['id']?.toString() ?? '') == _discussion!.fkIdClass,
              orElse: () => {},
            );
            if (found.isNotEmpty) {
              _className = (found['name'] ?? found['title'] ?? '')?.toString();
            }
          }
        } catch (_) {}
      }

      // compute understanding percentages from fetched understandings
      _computeUnderstandingStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _computeUnderstandingStats() {
    final total = _understandings.length;
    int u = 0, nf = 0, n = 0;
    for (final item in _understandings) {
      final t = item.type.toLowerCase();
      if (t.contains('not fully') || t.contains('partial') || t.contains('not_fully')) {
        nf++;
      } else if (t.contains('not') || t.contains('notunderstood') || t.contains('not_understood')) {
        n++;
      } else if (t.contains('understand') || t.contains('understood')) {
        u++;
      } else {
        nf++;
      }
    }
    if (total > 0) {
      _pUnderstood = ((u / total) * 100).round();
      _pNotFully = ((nf / total) * 100).round();
      _pNot = ((n / total) * 100).round();
    } else {
      _pUnderstood = 0;
      _pNotFully = 0;
      _pNot = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_discussion == null) return const Center(child: Text('Discussion not found'));

    return Scaffold(
      appBar: AppBar(title: const Text('Discussion Room Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ====== Section: Discussion Room Info ======
              _DiscussionInfoCard(
                discussion: _discussion!,
                className: _className,
                pUnderstood: _pUnderstood,
                pNotFully: _pNotFully,
                pNot: _pNot,
                groupCount: _groupCount,
                perGroup: _perGroup,
              ),
              const SizedBox(height: 24),

              // ====== Section: Questions / Answers ======
              const _SectionHeading(title: 'Questions / Answers'),
              const SizedBox(height: 8),
              CardAnswerQuestionStudent(questions: _questions),
              const SizedBox(height: 24),

              // ====== Section: Student Conclusions ======
              const _SectionHeading(title: 'Student Conclusions'),
              const SizedBox(height: 8),
              CardConclusionStudent(summaries: _summaries),
              const SizedBox(height: 24),

              // ====== Section: Understanding Results ======
              const _SectionHeading(title: 'Understanding Results'),
              const SizedBox(height: 8),
              CardPercentageUnderstanding(items: _understandings),
            ],
          ),
        ),
      ),
    );
  }
}

/// reusable heading widget biar konsisten antar section
class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class _DiscussionInfoCard extends StatelessWidget {
  final DiscussionRoom discussion;
  final String? className;
  final int pUnderstood;
  final int pNotFully;
  final int pNot;
  final int? groupCount;
  final int? perGroup;

  const _DiscussionInfoCard({required this.discussion, this.className, this.pUnderstood = 0, this.pNotFully = 0, this.pNot = 0, this.groupCount, this.perGroup});

  @override
  Widget build(BuildContext context) {
  final classLabel = className ?? (discussion.fkIdClass.isNotEmpty ? 'Class ${discussion.fkIdClass}' : 'No data');
    final name = discussion.title.isNotEmpty ? discussion.title : 'Discussion';
  // use provided group/properties if available
  final groupCount = this.groupCount != null ? '${this.groupCount} Groups' : 'No data';
  final perGroup = this.perGroup != null ? '${this.perGroup} Per-Groups' : 'No data';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const _SectionHeading(title: 'Discussion Room Info'),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discussion Room Class', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(classLabel),
                  ),
                  const SizedBox(height: 12),
                  const Text('Discussion Room Name',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(name),
                  ),
                  const SizedBox(height: 12),
                  const Text('Number of Discussion Groups',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(groupCount),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(perGroup),
                            ),
                          ],
                        ),
                  const SizedBox(height: 12),
                  const Text('Percentage of Material Understanding',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // show percent labels above the bar when we have data
                        if (pUnderstood + pNotFully + pNot > 0) ...[
                          Row(
                            children: [
                              Expanded(child: Center(child: Text('$pUnderstood%'))),
                              Expanded(child: Center(child: Text('$pNotFully%'))),
                              Expanded(child: Center(child: Text('$pNot%'))),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(child: Text('No data')),
                          ),
                        ],

                        Row(
                          children: [
                            if (pUnderstood + pNotFully + pNot == 0)
                              Expanded(child: Container(height: 10, color: Colors.grey.shade300))
                            else ...[
                              Expanded(flex: pUnderstood, child: Container(height: 10, color: Colors.green)),
                              Expanded(flex: pNotFully, child: Container(height: 10, color: Colors.yellow.shade700)),
                              Expanded(flex: pNot, child: Container(height: 10, color: Colors.red)),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(pUnderstood > 0 ? 'Understood' : 'No data', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10)),
                            Text(pNotFully > 0 ? 'Not Fully Understood' : 'No data', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10)),
                            Text(pNot > 0 ? 'Not Understood' : 'No data', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

