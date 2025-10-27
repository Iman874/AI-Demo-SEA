import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../component/window/window_message.dart';
import '../../providers/quiz_provider.dart';
import '../../component/window/window_add_material.dart';
import '../../component/card/card_material.dart';
import '../../component/card/card_question.dart';
import '../../component/window/window_add_question.dart';
import '../../component/window/window_confirmation.dart';
import '../../component/window/window_edit_question.dart';
import '../../utils/app_logger.dart';
import '../../models/material.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';

class PageMenuQuizEditorTeacher extends StatefulWidget {
  final int? quizId;
  const PageMenuQuizEditorTeacher({super.key, this.quizId});

  @override
  State<PageMenuQuizEditorTeacher> createState() => _PageMenuQuizEditorTeacherState();
}

class _PageMenuQuizEditorTeacherState extends State<PageMenuQuizEditorTeacher> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedDuration = "1 Hour 30 Minute";
  final List<String> _durations = [
    "30 Minute",
    "1 Hour",
    "1 Hour 30 Minute",
    "2 Hour",
  ];

  // Dummy material & questions (kosong, karena editor)
  final List<Question> _questions = [];
  // Local unsaved materials (kept in editor state until Save pressed). Each has at least: tmp_id, title, content, type
  final List<Map<String, dynamic>> _localMaterials = [];
  int? get _quizId => widget.quizId;
  bool _saving = false;
  String? _selectedClassId;

  void _openAddQuestionDialog({Question? editQuestion}) async {
    if (editQuestion != null) {
  // pass combined materials to the edit dialog
  final prov = Provider.of<QuizProvider>(context, listen: false);
  final persistedMaterials = prov.materials.map((m) => MaterialPdfJson.fromJson(m)).toList();
  // map local materials preserving tmp_id as id so dropdown values match
  final localMaterialsDisplay = _localMaterials.map((m) => MaterialPdf(
    id: m['tmp_id']?.toString() ?? m['id']?.toString() ?? '',
    title: m['title']?.toString() ?? '',
    content: m['content']?.toString() ?? '',
    type: m['type']?.toString() ?? 'text',
    createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(m['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      )).toList();
  final combinedMaterials = [...persistedMaterials, ...localMaterialsDisplay];

      await showDialog(
        context: context,
        builder: (context) => WindowEditQuestion(
          question: editQuestion,
          onSave: (Question q) {
            setState(() {
              final idx = _questions.indexWhere((qq) => qq.idQuestion == editQuestion.idQuestion);
              if (idx != -1) _questions[idx] = q;
            });
            AppLogger.i('Question edited: #${q.number}');
          },
          existingQuestions: _questions.where((qq) => qq.idQuestion != editQuestion.idQuestion).toList(),
          materials: combinedMaterials,
        ),
      );
    } else {
  final prov = Provider.of<QuizProvider>(context, listen: false);
  final persistedMaterials = prov.materials.map((m) => MaterialPdfJson.fromJson(m)).toList();
  final localMaterialsDisplay = _localMaterials.map((m) => MaterialPdf(
    id: m['tmp_id']?.toString() ?? m['id']?.toString() ?? '',
    title: m['title']?.toString() ?? '',
    content: m['content']?.toString() ?? '',
    type: m['type']?.toString() ?? 'text',
    createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(m['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      )).toList();
  final combinedMaterials = [...persistedMaterials, ...localMaterialsDisplay];
      await showDialog(
        context: context,
        builder: (context) => WindowAddQuestion(
          nextNumber: _questions.length + 1,
          fkIdQuiz: _quizId?.toString() ?? "new_quiz",
          onAdd: (Question q) {
            setState(() {
              _questions.add(q);
            });
            AppLogger.i('Question added: #${q.number}');
          },
          existingQuestions: _questions,
          materials: combinedMaterials,
        ),
      );
    }
  }

  void _confirmDeleteQuestion(Question q, {String? message}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WindowConfirmation(
        message: message,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    if (result == true) {
      setState(() {
        _questions.removeWhere((qq) => qq.idQuestion == q.idQuestion);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil materi dari soal yang sudah direlasikan
  final prov = Provider.of<QuizProvider>(context);
  final persistedMaterials = prov.materials.map((m) => MaterialPdfJson.fromJson(m)).toList();
  final localMaterialsDisplay = _localMaterials.map((m) {
    return MaterialPdf(
      id: m['tmp_id']?.toString() ?? m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      type: m['type']?.toString() ?? 'text',
      createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(m['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }).toList();
  final relatedMaterials = [...persistedMaterials, ...localMaterialsDisplay];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Quiz Editor",
                        style: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quiz Title",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              hint: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:0),
                                child: const Text('Quiz Title'),
                              ),
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Class",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                value: _selectedClassId,
                                isExpanded: true,
                                items: prov.classes.isEmpty
                                    ? [const DropdownMenuItem(value: null, child: Text('No classes'))]
                                    : prov.classes.map((c) => DropdownMenuItem(value: c['id_class'].toString(), child: Text(c['name'].toString()))).toList(),
                                onChanged: (val) {
                                  setState(() => _selectedClassId = val);
                                },
                                hint: const Text('Select class'),
                                 
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Quiz Duration",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                value: _selectedDuration,
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(8),
                                items: _durations.map((d) {
                                  return DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedDuration = val);
                                },
                                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black, fontSize: 14),
                                icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Quiz Material",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          relatedMaterials.isEmpty
                              ? Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No material added yet.",
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                )
                              : CardMaterialList(
                                  materials: relatedMaterials,
                                  onViewMaterial: (m) {
                                    // TODO: View material
                                  },
                                ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B6A85),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final res = await showDialog<Map<String, dynamic>?>(
                                  context: context,
                                  builder: (context) => WindowAddMaterial(fkIdQuiz: _quizId?.toString(), saveImmediately: false),
                                );
                                if (res != null) {
                                  final tmpId = DateTime.now().millisecondsSinceEpoch.toString();
                                  final mat = Map<String, dynamic>.from(res);
                                  mat['tmp_id'] = tmpId;
                                  _localMaterials.add(mat);
                                  setState(() {});
                                } else {
                                  // Dialog returned null (user cancelled or material was saved directly on the server);
                                  // reload persisted materials if editing an existing quiz.
                                  if (_quizId != null) await prov.loadMaterials(quizId: _quizId.toString());
                                  setState(() {});
                                }
                              },
                              child: const Text(
                                "Add Material",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Quiz Questions",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          CardQuestionList(
                            questions: _questions,
                            onViewDetails: (q) {
                              // TODO: View question details
                            },
                            onEdit: (q) {
                              _openAddQuestionDialog(editQuestion: q);
                            },
                            onDelete: (q) {
                              _confirmDeleteQuestion(q, message: "Hapus soal ini?");
                            },
                            materials: relatedMaterials,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B5F4B),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _openAddQuestionDialog,
                              child: const Text(
                                "Add Questions",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF50B4B4),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                // Generate questions from local materials via Gemini
                                final navigator = Navigator.of(context);
                                if (_localMaterials.isEmpty) {
                                  AppLogger.w('Generate Questions pressed but no local materials');
                                  if (!mounted) return;
                                  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'No local materials available to generate questions'));
                                  return;
                                }

                                final payload = {'materials': _localMaterials};
                                try {
                                  AppLogger.i('Requesting generated questions from AI for ${_localMaterials.length} materials');
                                  final resp = await ApiService.generateQuestions(payload);
                                    AppLogger.d('generateQuestions status=${resp.statusCode} body=${resp.body}');
                                    if (resp.statusCode == 200) {
                                      final data = jsonDecode(resp.body);
                                      final text = data['result'] ?? data.toString();
                                      // show raw result for confirmation
                                      if (!mounted) return;
                                      await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: text));
                                      // parse result into questions (simple heuristic)
                                      final parsed = _parseQuestionsFromText(text);
                                      if (parsed.isNotEmpty) {
                                        if (mounted) {
                                          setState(() {
                                            _questions.addAll(parsed);
                                          });
                                        }
                                        AppLogger.i('Parsed ${parsed.length} questions from AI result');
                                      } else {
                                        AppLogger.w('No questions parsed from AI response');
                                        if (!mounted) return;
                                        await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'AI returned text but no questions could be parsed'));
                                      }
                                    } else {
                                      AppLogger.e('AI generateQuestions failed: ${resp.statusCode}', resp.body);
                                      if (!mounted) return;
                                      await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Failed to generate questions: ${resp.statusCode}\n${resp.body}'));
                                    }
                                } catch (e, st) {
                                  AppLogger.e('Exception when calling generateQuestions', e, st);
                                  if (!mounted) return;
                                  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Failed to generate questions: $e'));
                                }
                              },
                              child: const Text(
                                "Generate Questions from Quiz Material [AI]",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80), // Spacer for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Tombol Save selalu di bawah layar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6972DF),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _saving ? null : () async {
                      await _saveQuiz();
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuiz() async {
    setState(() => _saving = true);

    // Build payload
    final title = _titleController.text.trim();
    final payload = <String, dynamic>{
      'title': title.isEmpty ? 'Untitled Quiz' : title,
      'duration': _selectedDuration,
      // optional: include quiz_id when editing existing
      if (_quizId != null) 'quiz_id': _quizId,
    };
    if (_selectedClassId != null) payload['class_ids'] = [int.tryParse(_selectedClassId!)];

    // include local unsaved materials so backend can create them together with the quiz
    if (_localMaterials.isNotEmpty) {
      payload['materials'] = _localMaterials.map((m) => {
        'tmp_id': m['tmp_id'],
        'title': m['title'],
        'content': m['content'],
        'type': m['type'],
      }).toList();
    }

    // adjust questions: ensure fk_id_material references local tmp_id when applicable
    final adjustedQuestions = _questions.map((q) {
      dynamic fkMat;
      if (q.fkIdMaterial != null) {
        // if fkIdMaterial matches a local material id or tmp id, prefer tmp_id
        final local = _localMaterials.firstWhere(
          (m) => m['id']?.toString() == q.fkIdMaterial?.toString() || m['tmp_id'] == q.fkIdMaterial,
          orElse: () => {},
        );
        if (local.isNotEmpty) {
          fkMat = local['tmp_id'];
        } else {
          fkMat = int.tryParse(q.fkIdMaterial ?? '') ?? q.fkIdMaterial;
        }
      }
      return {
        'number': q.number,
        'question_text': q.question,
        'point': q.poin,
        'fk_id_material': fkMat,
        'choices': q.answerChoices.map((c) => {
          'content': c.content,
          'is_correct': c.isCorrect,
        }).toList(),
      };
    }).toList();
    payload['questions'] = adjustedQuestions;
    if (_selectedClassId != null) {
      payload['class_ids'] = [int.tryParse(_selectedClassId!)];
    }

  final navigator = Navigator.of(context);
  try {
      // Log payload for debugging (safe encode)
      try {
        AppLogger.d('Quiz save payload: ${jsonEncode(payload)}');
      } catch (e) {
        AppLogger.w('Failed to JSON-encode quiz payload for logging', e);
      }

      final resp = await ApiService.createFullQuiz(payload);
      // Log response details for debugging
      AppLogger.d('Quiz save response status: ${resp.statusCode}');
      AppLogger.d('Quiz save response headers: ${resp.headers}');
      AppLogger.d('Quiz save response body: ${resp.body}');

  if (resp.statusCode == 201) {
        AppLogger.i('Quiz saved successfully (201)');
        if (!mounted) return;
        await showDialog(
          context: navigator.context,
          builder: (_) => WindowMessage(message: 'Quiz saved successfully', onOk: () {
            navigator.pop();
          }),
        );

        // after saving, pop back to previous page
        if (!mounted) return;
        navigator.pop(true);
      } else {
        AppLogger.e('Failed to save quiz: status=${resp.statusCode}', resp.body);
  final msg = 'Failed to save quiz: ${resp.statusCode}\n${resp.body}';
  if (!mounted) return;
  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: msg));
      }
    } catch (e, st) {
  AppLogger.e('Exception when saving quiz', e, st);
  if (!mounted) return;
  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Failed to save quiz: $e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // if quizId present, load related materials
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<QuizProvider>(context, listen: false);
      prov.loadClasses();
      if (_quizId != null) prov.loadMaterials(quizId: _quizId.toString());
    });
  }

  /// Heuristic parser: converts raw AI text into a list of Question objects.
  List<Question> _parseQuestionsFromText(String text) {
    final List<Question> out = [];
  // material titles are available via provider and _localMaterials when needed

    // Split into blocks per numbered question
    final lines = text.split(RegExp(r'\r?\n'));
    final List<int> qStarts = [];
    final qRegex = RegExp(r'^(\s*)(\d+)\s*[\.|\)]\s*(.*)');
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i].trimLeft();
      if (qRegex.hasMatch(l)) qStarts.add(i);
    }
    if (qStarts.isEmpty) {
      // fallback: treat whole text as single block
      qStarts.add(0);
    }

    for (int idx = 0; idx < qStarts.length; idx++) {
      final start = qStarts[idx];
      final end = (idx + 1 < qStarts.length) ? qStarts[idx + 1] : lines.length;
      final blockLines = lines.sublist(start, end).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (blockLines.isEmpty) continue;
      // parse header
      final headerMatch = qRegex.firstMatch(blockLines[0]);
      final number = headerMatch != null ? int.tryParse(headerMatch.group(2) ?? '') ?? (out.length + 1) : (out.length + 1);
      String qText = headerMatch != null ? (headerMatch.group(3) ?? '') : blockLines[0];
      // try to extract point and related material from header parentheses
      int point = 10;
      String? inferredRelated;
      final parenMatches = RegExp(r'\(([^)]*)\)').allMatches(qText).map((m) => m.group(1)?.trim() ?? '').where((s) => s.isNotEmpty).toList();
      if (parenMatches.isNotEmpty) {
        for (final pm in parenMatches) {
          final lower = pm.toLowerCase();
          final numMatch = RegExp(r'\b(5|10|15|20)\b').firstMatch(pm);
          if (numMatch != null) {
            point = int.parse(numMatch.group(1)!);
          } else if (lower.contains('point') || lower.contains('points')) {
            final nm = RegExp(r'(\d+)').firstMatch(pm);
            if (nm != null) point = int.parse(nm.group(1)!);
          } else {
            // treat as related material title if not numeric
            inferredRelated = pm;
          }
        }
        // remove parentheses from question text
        qText = qText.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      } else {
        final pMatch = RegExp(r'\b(5|10|15|20)\b').firstMatch(blockLines.join(' '));
        if (pMatch != null) point = int.parse(pMatch.group(1)!);
      }

      // detect related material in block
      String? fkMatId;
      // helper: normalize and fuzzy match
      final prov = Provider.of<QuizProvider>(context, listen: false);
      String normalizeTitle(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
      String? findMaterialIdByTitle(String title) {
        final needle = normalizeTitle(title);
        // search persisted first (exact normalized)
        for (final m in prov.materials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.isEmpty) continue;
          if (n == needle) return m['id_material']?.toString();
        }
        // try contains match
        for (final m in prov.materials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.contains(needle) || needle.contains(n)) return m['id_material']?.toString();
        }
        // try local materials by tmp_id
        for (final m in _localMaterials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n == needle) return m['tmp_id']?.toString();
        }
        for (final m in _localMaterials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.contains(needle) || needle.contains(n)) return m['tmp_id']?.toString();
        }
        return null;
      }

      for (final l in blockLines) {
        final rm = RegExp(r'Related\s*Material\s*[:\-]?\s*(.*)', caseSensitive: false).firstMatch(l);
        if (rm != null && (rm.group(1)?.trim().isNotEmpty ?? false)) {
          final matTitle = rm.group(1)!.trim();
          fkMatId = findMaterialIdByTitle(matTitle);
          if (fkMatId != null) break;
        }
      }

      // detect choices
      final choices = <Map<String, dynamic>>[];
      final choiceLineRegexes = [RegExp(r'^[A-Da-d]\s*[\.|\)]\s*(.*)'), RegExp(r'^\d+\)\s*(.*)'), RegExp(r'^[-\*]\s*(.*)')];
      for (int i = 1; i < blockLines.length; i++) {
        final l = blockLines[i];
        bool matched = false;
        for (final cre in choiceLineRegexes) {
          final m = cre.firstMatch(l);
          if (m != null) {
            var content = m.group(1) ?? '';
            var isCorrect = false;
            // detect (Correct) marker and remove it from content
            if (content.toLowerCase().contains('(correct)') || l.toLowerCase().contains('(correct)') || content.toLowerCase().contains('correct)')) {
              isCorrect = true;
            }
            content = content.replaceAll(RegExp(r'\(correct\)', caseSensitive: false), '').trim();
            // remove trailing dot
            if (content.endsWith('.')) content = content.substring(0, content.length - 1).trim();
            choices.add({'id': 'tmp_${out.length}_${i}_${DateTime.now().millisecondsSinceEpoch}', 'content': content, 'isCorrect': isCorrect});
            matched = true;
            break;
          }
        }
        if (!matched) {
          // inline choices like 'Choices: a) x; b) y; c) z'
          final inline = RegExp(r'Choices?\s*[:\-]?\s*(.*)', caseSensitive: false).firstMatch(l);
          if (inline != null && (inline.group(1)?.isNotEmpty ?? false)) {
            final parts = inline.group(1)!.split(RegExp(r'[;\\|/]'));
            for (final p in parts) {
              var cleaned = p.trim();
              if (cleaned.isNotEmpty) {
                final isCorrect = cleaned.toLowerCase().contains('(correct)');
                cleaned = cleaned.replaceAll(RegExp(r'\(correct\)', caseSensitive: false), '').trim();
                if (cleaned.endsWith('.')) cleaned = cleaned.substring(0, cleaned.length - 1).trim();
                choices.add({'id': 'tmp_${out.length}_${i}_${DateTime.now().millisecondsSinceEpoch}', 'content': cleaned, 'isCorrect': isCorrect});
              }
            }
          }
        }
      }

      // If no choices found, try to extract from question line (split by ';')
      if (choices.isEmpty) {
        final inlineChoices = qText.split(RegExp(r';|/|\|'));
        if (inlineChoices.length > 1) {
          for (final ic in inlineChoices.skip(1)) {
            final cleaned = ic.trim();
            if (cleaned.isNotEmpty) choices.add({'id': 'tmp_inline_${DateTime.now().millisecondsSinceEpoch}', 'content': cleaned, 'isCorrect': false});
          }
          // remove inline options from qText
          qText = inlineChoices.first.trim();
        }
      }

      // fallback ensure at least 3 choices
      while (choices.length < 3) {
        choices.add({'id': 'tmp_auto_${DateTime.now().millisecondsSinceEpoch}', 'content': 'Option', 'isCorrect': false});
      }

      // if inferredRelated exists and fkMatId not found, try to match it using same helper
      if (fkMatId == null && inferredRelated != null && inferredRelated.isNotEmpty) {
        fkMatId = findMaterialIdByTitle(inferredRelated);
      }

      final Map<String, dynamic> qMap = {
        'idQuestion': 'tmp_${out.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
        'number': number,
        'question': qText,
        'poin': point,
        'fkIdMaterial': fkMatId,
        'answerChoices': choices,
      };
      out.add(_mapToQuestion(qMap));
    }

    return out;
  }

  Question _mapToQuestion(Map<String, dynamic> m) {
    final fkQuiz = _quizId?.toString() ?? 'new_quiz';
    final createAt = DateTime.now();
    final choices = <AnswerQuestion>[];
    for (final c in (m['answerChoices'] as List<dynamic>)) {
      choices.add(AnswerQuestion(
        idAnswerChoice: c['id']?.toString() ?? 'tmp_choice',
        content: c['content']?.toString() ?? '',
        isCorrect: c['isCorrect'] == true,
        createAt: createAt,
        updateAt: createAt,
      ));
    }
    return Question(
      idQuestion: m['idQuestion']?.toString() ?? 'tmp',
      number: m['number'] ?? (DateTime.now().millisecondsSinceEpoch % 1000),
      question: m['question']?.toString() ?? '',
      poin: m['poin'] ?? 10,
      fkIdQuiz: fkQuiz,
      fkIdMaterial: m['fkIdMaterial']?.toString(),
      answerChoices: choices,
      createAt: createAt,
      updateAt: createAt,
    );
  }
}