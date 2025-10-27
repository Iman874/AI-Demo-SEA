import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../../component/card/card_material.dart';
import '../../models/material.dart';
import '../../services/api_service.dart';
import '../../component/window/window_message.dart';
import '../../component/window/window_add_material.dart';

class PageMenuDiscussionEditorTeacher extends StatefulWidget {
  final String? discussionId; // optional id when editing
  const PageMenuDiscussionEditorTeacher({super.key, this.discussionId});

  @override
  State<PageMenuDiscussionEditorTeacher> createState() => _PageMenuDiscussionEditorTeacherState();
}

class _PageMenuDiscussionEditorTeacherState extends State<PageMenuDiscussionEditorTeacher> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> classMembers = [];
  List<Map<String, dynamic>> quizResults = [];

  String? selectedClassId;
  String? selectedQuizResultId;
  int selectedGroupCount = 2;
  int selectedPerGroup = 3;
  bool classChosen = false; // tracks if user explicitly selected a class

  String aiResultText = '';
  List<Map<String, dynamic>> localMaterials = [];
  bool isLoadingAI = false;
  bool _isEditMode = false;
  bool _chatroomActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadClasses();
      if (widget.discussionId != null) {
        _isEditMode = true;
        await _loadDiscussion(widget.discussionId!);
      }
    });
  }

  Future<void> _loadDiscussion(String id) async {
    try {
      final resp = await ApiService.getDiscussion(id);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final d = data['data']?['discussion'];
        final chat = data['data']?['chat'];
        final materials = data['data']?['materials'] ?? [];
        if (d != null) {
          setState(() {
            _roomNameController.text = d['title'] ?? '';
            _descriptionController.text = d['description'] ?? '';
            selectedClassId = (d['fkIdClass'] ?? d['fk_id_class'])?.toString();
            aiResultText = d['ai_generated_groups']?.toString() ?? '';
            // we intentionally do not populate classMembers here; leave that to user if needed
          });
        }
        if (chat != null) {
          setState(() { _chatroomActive = (chat['status']?.toString() ?? 'active') == 'active'; });
        }
        // load materials into localMaterials for display (do not persist yet)
        try {
          final mats = List<Map<String, dynamic>>.from(materials as List<dynamic>);
          setState(() { localMaterials = mats; });
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Parse AI generated groups text into a flat list of student maps
  /// Expected AI lines (examples):
  /// 1, (123, John Doe)
  /// 2, (124, Jane)
  /// or: no_grup, (id_user, nama_user)
  List<Map<String, dynamic>> _convertAiGroupsToStudents(String aiText) {
    if (aiText.trim().isEmpty) return [];
    final students = <Map<String, dynamic>>[];
    final seen = <String>{};

    // Normalize line breaks and split
    final lines = aiText.replaceAll('\r', '').split('\n');
  final re = RegExp(r'\(?\s*([0-9A-Za-z_-]+)\s*,\s*([^\)]+)\s*\)?');

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      // Try to extract the pair inside parentheses first
      var match = re.firstMatch(line);
      if (match != null && match.groupCount >= 2) {
        final idPart = match.group(1)?.trim() ?? '';
        final namePart = match.group(2)?.trim() ?? '';
        if (idPart.isNotEmpty) {
          if (!seen.contains(idPart)) {
            seen.add(idPart);
            students.add({'id_user': idPart, 'name': namePart});
          }
          continue;
        }
      }

      // Fallback: try to parse patterns like: 1, (123, John Doe)
      final commaIdx = line.indexOf(',');
      if (commaIdx > -1) {
        final right = line.substring(commaIdx + 1).trim();
        // remove parentheses if present
        final cleaned = right.replaceAll('(', '').replaceAll(')', '').trim();
        final parts = cleaned.split(',');
        if (parts.length >= 2) {
          final idPart = parts[0].trim();
          final namePart = parts.sublist(1).join(',').trim();
          if (idPart.isNotEmpty && !seen.contains(idPart)) {
            seen.add(idPart);
            students.add({'id_user': idPart, 'name': namePart});
          }
        }
      }
    }

    return students;
  }

  Future<void> _loadClasses() async {
    try {
      final resp = await ApiService.getClasses();
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() {
          classes = List<Map<String, dynamic>>.from(data['data'] ?? []);
          selectedClassId = null;
        });
      }
    } catch (_) {}
  }

  Future<void> _onClassSelected(String? val) async {
    // selectedClassId is set by the dropdown handler already; only load details here
    if (val == null) return;
    try {
      final resp = await ApiService.getClassMembers(classId: val);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final members = List<Map<String, dynamic>>.from(data['data'] ?? []);
        setState(() {
          classMembers = members;
          // recompute sensible defaults for group counts based on member count
          final mc = (members.isNotEmpty ? members.length : 30);
          // ensure selectedGroupCount is within range
          if (selectedGroupCount > mc) selectedGroupCount = mc;
          if (selectedGroupCount < 1) selectedGroupCount = 1;
          // compute per-group as floor division
          final per = (mc / selectedGroupCount).floor();
          selectedPerGroup = per >= 1 ? per : 1;
        });
      }
    } catch (_) {}

    try {
      final qresp = await ApiService.getQuizzes(classId: val);
      if (qresp.statusCode == 200) {
        final qdata = jsonDecode(qresp.body);
        setState(() { quizResults = List<Map<String, dynamic>>.from(qdata['data'] ?? []); });
      }
    } catch (_) {}
  }

  Future<void> _generateGroups() async {
    if (_isEditMode) {
      await showDialog(context: context, builder: (_) => WindowMessage(message: 'Group generation is disabled in edit mode'));
      return;
    }

    if (selectedClassId == null || selectedClassId!.trim().isEmpty) {
      await showDialog(context: context, builder: (_) => WindowMessage(message: 'Please select a class first'));
      return;
    }

    setState(() { isLoadingAI = true; });
    try {
      final students = classMembers.map((m) => {
        'id_user': m['id_user'] ?? m['id'],
        'name': m['name'] ?? m['full_name'] ?? m['username'] ?? '',
      }).toList();

      final body = {
        'class_id': selectedClassId,
        'group_count': selectedGroupCount,
        'per_group': selectedPerGroup,
        if (selectedQuizResultId != null) 'quiz_id': selectedQuizResultId,
        'students': students,
      };

      final resp = await ApiService.generateGroups(body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final resultText = data['result'] ?? data['data'] ?? resp.body;
        if (mounted) {
          setState(() { aiResultText = resultText.toString(); });
        }
        if (!mounted) return;
        await showDialog(context: context, builder: (_) => WindowMessage(message: aiResultText));
      } else {
        if (!mounted) return;
        await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to generate groups: ${resp.statusCode}\n${resp.body}'));
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to generate groups: $e'));
    } finally {
      if (mounted) setState(() { isLoadingAI = false; });
    }
  }

  Future<void> _addMaterial() async {
    final res = await showDialog(context: context, builder: (_) => const WindowAddMaterial(saveImmediately: false));
    if (res != null && res is Map<String, dynamic>) {
      final tmpId = 'tmp_${DateTime.now().millisecondsSinceEpoch}';
      final local = {...res, 'tmp_id': tmpId};
      if (mounted) {
        setState(() { localMaterials.add(local); });
      }
    }
  }

  Future<void> _saveDiscussion() async {
    if (selectedClassId == null || selectedClassId!.trim().isEmpty) {
      await showDialog(context: context, builder: (_) => WindowMessage(message: 'Please select class before saving'));
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final createdBy = auth.user?.id;

    if (_isEditMode && widget.discussionId != null) {
      // In edit mode, do not alter groups. We allow editing title, description, materials (new ones), and chatroom active flag.
      final payload = {
        'title': _roomNameController.text.trim().isEmpty ? 'Discussion' : _roomNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'chatroom_active': _chatroomActive,
        // send new materials for backend to attach to discussion
        'materials': localMaterials.map((m) => {
          'title': m['title'],
          'content': m['content'],
          'type': m['type'],
          'created_by': createdBy,
        }).toList(),
      };

      try {
        final resp = await ApiService.updateDiscussion(widget.discussionId!, payload);
        if (!mounted) return;
        if (resp.statusCode == 200) {
          await showDialog(context: context, builder: (_) => WindowMessage(message: 'Discussion updated successfully'));
        } else {
          await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to update discussion: ${resp.statusCode}\n${resp.body}'));
        }
      } catch (e) {
        if (!mounted) return;
        await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to update discussion: $e'));
      }
      return;
    }

    // Create mode
    final createdMaterialIds = <dynamic>[];
  for (final m in localMaterials) {
      try {
        final payload = {
          'title': m['title'],
          'content': m['content'],
          'type': m['type'],
          'fk_id_discussionroom': null,
        };
        final resp = await ApiService.createMaterial(payload);
        if (resp.statusCode == 201) {
          final data = jsonDecode(resp.body);
          createdMaterialIds.add(data['data']?['id'] ?? data['id']);
        }
      } catch (_) {}
    }

    if (aiResultText.isEmpty) {
      await _generateGroups();
      if (!mounted) return;
    }

    // prepare students payload by converting AI-generated groups (if present)
    final studentsPayload = _convertAiGroupsToStudents(aiResultText);

    final discussionPayload = {
      'title': _roomNameController.text.trim().isEmpty ? 'Discussion' : _roomNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'fk_id_class': selectedClassId,
      'created_by': createdBy,
      'students': studentsPayload,
      'materials': createdMaterialIds,
      'ai_generated_groups': aiResultText,
    };

    try {
      final resp = await ApiService.createDiscussion(discussionPayload);
      if (!mounted) return;
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        await showDialog(context: context, builder: (_) => WindowMessage(message: 'Discussion created successfully'));
        if (mounted) setState(() { localMaterials.clear(); aiResultText = ''; });
      } else {
        await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to create discussion: ${resp.statusCode}\n${resp.body}'));
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog(context: context, builder: (_) => WindowMessage(message: 'Failed to create discussion: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: Text(_isEditMode ? 'Edit Discussion' : 'Create Discussion')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text('Select Discussion Room Class', style: Theme.of(context).textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: (selectedClassId?.isNotEmpty ?? false) ? selectedClassId : null,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Select Class'),
                      ),
                      items: classes
                          .where((c) => (c['id'] ?? c['id_class']) != null && (c['id'] ?? c['fk_id_class']).toString().trim().isNotEmpty)
                          .map((c) => DropdownMenuItem(
                                value: (c['id'] ?? c['id_class']).toString(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(c['name'] ?? c['title'] ?? ''),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedClassId = val;
                          classChosen = true;
                          classMembers = [];
                          quizResults = [];
                        });
                        _onClassSelected(val);
                      },
                    ),
                  ),
                ),
              ),
              // Helper label: require explicit user selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  'please select class',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: (selectedClassId != null && selectedClassId!.trim().isNotEmpty) ? Colors.green : Colors.red),
                ),
              ),

              if (quizResults.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6), child: Text('Select Quiz Result', style: Theme.of(context).textTheme.titleMedium)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedQuizResultId,
                        isExpanded: true,
                        hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Select Quiz Result')),
                        items: quizResults.map((q) => DropdownMenuItem(value: (q['id_quiz'] ?? q['id'])?.toString(), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(q['title'] ?? '')))).toList(),
                        onChanged: (val) { setState(() { selectedQuizResultId = val; }); },
                      ),
                    ),
                  ),
                ),
              ],

              Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6), child: Text('Discussion Room Name', style: Theme.of(context).textTheme.titleMedium)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: TextField(controller: _roomNameController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: 'Discussion Room Name', fillColor: Theme.of(context).cardColor, filled: true)),
              ),

              // Description field (new)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6), child: Text('Description', style: Theme.of(context).textTheme.titleMedium)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: TextField(controller: _descriptionController, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), hintText: 'Description', fillColor: Theme.of(context).cardColor, filled: true)),
              ),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6), child: Text('Number of Discussion Groups', style: Theme.of(context).textTheme.titleMedium)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedGroupCount,
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            items: List<int>.generate((classMembers.isNotEmpty ? classMembers.length : 30), (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$n Groups')))).toList(),
                              onChanged: _isEditMode ? null : (val) {
                                if (val == null) return;
                                setState(() {
                                  selectedGroupCount = val;
                                  final mc = (classMembers.isNotEmpty ? classMembers.length : 30);
                                  // recompute per-group as floor(mc / groupCount)
                                  final per = (mc / selectedGroupCount).floor();
                                  selectedPerGroup = per >= 1 ? per : 1;
                                });
                              },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedPerGroup,
                            borderRadius: BorderRadius.circular(10),
                            isExpanded: true,
                            items: List<int>.generate((classMembers.isNotEmpty ? classMembers.length : 30), (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$n/Per-Groups')))).toList(),
                            onChanged: _isEditMode ? null : (val) {
                              if (val == null) return;
                              setState(() {
                                selectedPerGroup = val;
                                final mc = (classMembers.isNotEmpty ? classMembers.length : 30);
                                // recompute groupCount as floor(mc / perGroup)
                                final grp = (mc / selectedPerGroup).floor();
                                selectedGroupCount = grp >= 1 ? grp : 1;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(children: [
                  Expanded(child: ElevatedButton(onPressed: () async => await showDialog(context: context, builder: (_) => WindowMessage(message: aiResultText.isEmpty ? 'No groups generated yet.' : aiResultText)), style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text('View Result Generate Groups'))),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isEditMode ? null : ((selectedClassId != null && selectedClassId!.trim().isNotEmpty) ? _generateGroups : null),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: isLoadingAI ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)) : const Text('Create Discussion Groups [AI]'),
                    ),
                  ),
                ]),
              ),

              // ChatRoom AI Active toggle (edit mode)
              if (_isEditMode) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Row(children: [
                  const Text('ChatRoom AI Active', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Switch(value: _chatroomActive, onChanged: (v) { setState(() { _chatroomActive = v; }); }),
                ]),
              ),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6), child: Text('Discussion Materials', style: Theme.of(context).textTheme.titleMedium)),
              CardMaterialList(materials: localMaterials.map((m) => MaterialPdfJson.fromJson(m)).toList()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addMaterial, child: const Text('Add Discussion Material'))),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (selectedClassId != null && selectedClassId!.trim().isNotEmpty) ? _saveDiscussion : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Save'),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
