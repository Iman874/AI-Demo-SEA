import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../../component/card/card_material.dart';
import '../../models/material.dart';
import '../../services/api_service.dart';
import '../../component/window/window_message.dart';
import '../../component/window/window_add_material.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header App Bar Gradient Modern Melengkung
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.teacherGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.arrowLeft, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? "Ubah Diskusi AI" : "Buat Diskusi AI Baru",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Kelompokkan siswa secara otomatis dengan AI",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Kelas Diskusi
                      Container(
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kelas Diskusi",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      PhosphorIconsRegular.graduationCap,
                                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  value: (selectedClassId?.isNotEmpty ?? false) ? selectedClassId : null,
                                  hint: const Text('Pilih Kelas Sasaran'),
                                  items: classes
                                      .where((c) => (c['id'] ?? c['id_class']) != null && (c['id'] ?? c['fk_id_class']).toString().trim().isNotEmpty)
                                      .map((c) => DropdownMenuItem(
                                            value: (c['id'] ?? c['id_class']).toString(),
                                            child: Text(c['name'] ?? c['title'] ?? ''),
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
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                (selectedClassId != null && selectedClassId!.trim().isNotEmpty)
                                    ? "✓ Kelas telah dipilih"
                                    : "⚠️ Kelas wajib dipilih terlebih dahulu",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (selectedClassId != null && selectedClassId!.trim().isNotEmpty)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Card Hasil Kuis (AI Referensi)
                      if (quizResults.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hasil Kuis (AI Referensi)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        PhosphorIconsRegular.chartBar,
                                        color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    value: selectedQuizResultId,
                                    hint: const Text('Pilih Hasil Kuis'),
                                    items: quizResults
                                        .map((q) => DropdownMenuItem(
                                              value: (q['id_quiz'] ?? q['id'])?.toString(),
                                              child: Text(q['title'] ?? ''),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedQuizResultId = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Card Informasi Diskusi
                      Container(
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama Ruang Diskusi",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _roomNameController,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: "Contoh: Grup Diskusi Algoritma",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(
                                  PhosphorIconsRegular.chatsCircle,
                                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Deskripsi Singkat",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: "Tuliskan petunjuk atau topik diskusi...",
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Card Pembagian Kelompok AI
                      Container(
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jumlah Pembagian Kelompok AI",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                          border: InputBorder.none,
                                          labelText: "Jumlah Grup",
                                          labelStyle: TextStyle(
                                            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        value: selectedGroupCount,
                                        items: List<int>.generate((classMembers.isNotEmpty ? classMembers.length : 30), (i) => i + 1)
                                            .map((n) => DropdownMenuItem(value: n, child: Text('$n Grup')))
                                            .toList(),
                                        onChanged: _isEditMode ? null : (val) {
                                          if (val == null) return;
                                          setState(() {
                                            selectedGroupCount = val;
                                            final mc = (classMembers.isNotEmpty ? classMembers.length : 30);
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
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<int>(
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                          border: InputBorder.none,
                                          labelText: "Siswa Per Grup",
                                          labelStyle: TextStyle(
                                            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                            fontSize: 12,
                                          ),
                                        ),
                                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        value: selectedPerGroup,
                                        items: List<int>.generate((classMembers.isNotEmpty ? classMembers.length : 30), (i) => i + 1)
                                            .map((n) => DropdownMenuItem(value: n, child: Text('$n Siswa')))
                                            .toList(),
                                        onChanged: _isEditMode ? null : (val) {
                                          if (val == null) return;
                                          setState(() {
                                            selectedPerGroup = val;
                                            final mc = (classMembers.isNotEmpty ? classMembers.length : 30);
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
                            const SizedBox(height: 18),
                            // Aksi Grup AI
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AppButton.primary(
                                    label: isLoadingAI ? "Memproses AI..." : "Buat Grup via AI",
                                    gradientColors: AppColors.teacherGradient,
                                    onPressed: _isEditMode ? null : ((selectedClassId != null && selectedClassId!.trim().isNotEmpty) ? _generateGroups : null),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(
                                        color: isDark ? Colors.white10 : Colors.black12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const Icon(PhosphorIconsRegular.users),
                                    label: const Text("Lihat Anggota Kelompok"),
                                    onPressed: () async => await showDialog(
                                      context: context,
                                      builder: (_) => WindowMessage(
                                        message: aiResultText.isEmpty ? 'Kelompok AI belum terbentuk.' : aiResultText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ChatRoom AI Switch
                      if (_isEditMode) ...[
                        Row(
                          children: [
                            Text(
                              'Aktifkan AI Chatroom',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value: _chatroomActive,
                              activeColor: const Color(0xFF4B6A85),
                              onChanged: (v) {
                                setState(() {
                                  _chatroomActive = v;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Materi Pembelajaran Pendukung
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Materi Pendukung Diskusi",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.plusCircle,
                              color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                            ),
                            onPressed: _addMaterial,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CardMaterialList(materials: localMaterials.map((m) => MaterialPdfJson.fromJson(m)).toList()),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(18),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: AppButton.primary(
              label: _isEditMode ? "Simpan Perubahan Diskusi" : "Buat Diskusi Sekarang",
              gradientColors: AppColors.teacherGradient,
              onPressed: (selectedClassId != null && selectedClassId!.trim().isNotEmpty) ? _saveDiscussion : null,
            ),
          ),
        ),
      ),
    );
  }
}
