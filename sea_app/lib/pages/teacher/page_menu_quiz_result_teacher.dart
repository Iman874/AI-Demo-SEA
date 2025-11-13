import 'package:flutter/material.dart';
import 'dart:convert';
import '../../component/card/card_material.dart';
import '../../component/card/card_question.dart';
import '../../models/quiz.dart';
import '../../models/material.dart';
import '../../models/question.dart';
import '../../services/api_service.dart';

class PageMenuQuizResultTeacher extends StatefulWidget {
  final String quizId;
  final String title;
  final String? classId;
  const PageMenuQuizResultTeacher({super.key, required this.quizId, required this.title, this.classId});

  @override
  State<PageMenuQuizResultTeacher> createState() => _PageMenuQuizResultTeacherState();
}

class _PageMenuQuizResultTeacherState extends State<PageMenuQuizResultTeacher> {
  bool _loading = true;
  String? _error;
  int _duration = 0; // minutes
  List<MaterialPdf> _materials = [];
  List<Question> _questions = [];
  List<Map<String, String>> _answers = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h} Hour ${m} Minute';
    if (h > 0) return h == 1 ? '1 Hour' : '${h} Hours';
    return '${m} Minute';
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      // 1) Quiz info for duration
      try {
        final qResp = await ApiService.getQuizzes();
        if (qResp.statusCode == 200) {
          final body = jsonDecode(qResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          for (var e in items) {
            final id = (e['id_quiz'] ?? e['id'] ?? '').toString();
            if (id == widget.quizId) {
              final dur = (e['duration'] is int) ? e['duration'] as int : int.tryParse(e['duration']?.toString() ?? '') ?? 0;
              _duration = dur;
              break;
            }
          }
        }
      } catch (_) {}

      // 2) Materials for this quiz
      try {
        final mResp = await ApiService.getMaterials(quizId: widget.quizId);
        if (mResp.statusCode == 200) {
          final body = jsonDecode(mResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          _materials = items.map((e) => MaterialPdfJson.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      } catch (_) {}

      // 3) Questions for this quiz
      try {
        final qq = await ApiService.getQuizQuestions(quizId: widget.quizId);
        if (qq.statusCode == 200) {
          final qb = jsonDecode(qq.body);
          final qItems = (qb['data'] as List<dynamic>?) ?? [];
          _questions = qItems.map((e) => Question(
            idQuestion: (e['id_question'] ?? '').toString(),
            number: (e['number'] ?? 0) as int,
            question: (e['question_text'] ?? '').toString(),
            poin: (e['point'] ?? 0) as int,
            fkIdQuiz: widget.quizId,
            fkIdMaterial: e['fk_id_material']?.toString(),
            answerChoices: const [],
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          )).toList();
        }
      } catch (_) {}

      // 4) Results for this quiz (teacher-wide)
      Map<String, String> nameById = {};
      if (widget.classId != null && widget.classId!.isNotEmpty) {
        try {
          final cm = await ApiService.getClassMembers(classId: widget.classId!);
          if (cm.statusCode == 200) {
            final body = jsonDecode(cm.body);
            final items = (body['data'] as List<dynamic>?) ?? [];
            for (var u in items) {
              final id = (u['id_user'] ?? u['id'] ?? '').toString();
              final nm = (u['name'] ?? '').toString();
              if (id.isNotEmpty) nameById[id] = nm;
            }
          }
        } catch (_) {}
      }

      try {
        final rResp = await ApiService.getQuizResults(quizId: widget.quizId);
        if (rResp.statusCode == 200) {
          final body = jsonDecode(rResp.body);
          final rows = (body['data'] as List<dynamic>?) ?? [];
          _answers = rows.map((r) {
            final uid = (r['fk_id_user'] ?? r['user_id'] ?? '').toString();
            final nm = nameById[uid] ?? 'User $uid';
            return {
              'name': nm,
              'user_id': uid,
            };
          }).toList();
        }
      } catch (_) {}

    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz - View Results")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz - View Results")),
        body: Center(child: Text('Error: $_error')),
      );
    }
    final quiz = Quiz(
      idQuiz: widget.quizId,
      title: widget.title,
      duration: _duration,
      createBy: '',
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    );

    final materials = _materials;
    final questions = _questions;
    final answers = _answers;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz - View Results"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Information", style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Quiz Title", quiz.title),
                    _infoRow("Quiz Duration", _formatDuration(_duration)),
                    _infoRow("Number of Questions", "${questions.length} Questions"),
                  ],
                ),
              ),
              // Quiz Material
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Material", style: Theme.of(context).textTheme.titleMedium),
              ),
              CardMaterialList(materials: materials),
              // Quiz Questions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Questions", style: Theme.of(context).textTheme.titleMedium),
              ),
              CardQuestionList(
                questions: questions,
                onViewDetails: (q) {},
                // Hapus itemBuilder, gunakan default CardQuestionList
              ),
              // Quiz Answers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text("Quiz Answers", style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: answers.map((ans) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Answer from ${ans['name']}", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13)),
                        TextButton(
                          onPressed: () {},
                          child: const Text("View Details"),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                    child: const Text("Generate Discussion Group [AI]"),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }
}
