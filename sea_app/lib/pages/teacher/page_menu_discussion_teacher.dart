import 'package:flutter/material.dart';
import '../../component/card/card_discussion.dart';
import '../../component/card/card_material.dart';
import '../../models/discussion_room.dart';
import '../../models/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_editor_teacher.dart';
import 'page_menu_discussion_details_teacher.dart';

class PageMenuDiscussionTeacher extends StatefulWidget {
  const PageMenuDiscussionTeacher({super.key});

  @override
  State<PageMenuDiscussionTeacher> createState() => _PageMenuDiscussionTeacherState();
}

class _PageMenuDiscussionTeacherState extends State<PageMenuDiscussionTeacher> {
  bool _loading = true;
  String? _error;
  List<ClassModel> _classes = [];
  List<DiscussionRoom> _discussions = [];
  List<MaterialPdf> _materials = [];
  String? selectedClassId;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await ApiService.getClasses();
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _classes = items.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
        if (_classes.isNotEmpty) selectedClassId = _classes.first.idClass;
        await _loadDiscussions();
        // load materials (global for now)
        final matResp = await ApiService.getMaterials();
        if (matResp.statusCode == 200) {
          final mbody = jsonDecode(matResp.body);
          final mitems = mbody['data'] as List<dynamic>? ?? [];
          _materials = mitems.map((e) => MaterialPdfJson.fromJson(e as Map<String, dynamic>)).toList();
        }
      } else {
        throw Exception('Failed to load classes (${resp.statusCode})');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDiscussions() async {
  if (selectedClassId == null || selectedClassId!.isEmpty) return;
    try {
      final resp = await ApiService.getDiscussions(classId: selectedClassId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load discussions (${resp.statusCode})');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

  final ongoingDiscussions = _discussions.where((d) => d.status == 'open').toList();
  final completedDiscussions = _discussions.where((d) => d.status == 'closed').toList();
  final materials = _materials;

    // Filter out classes with empty id and deduplicate by id to avoid Dropdown issues
    final List<ClassModel> classItems = [];
    final seen = <String>{};
    for (final c in _classes) {
      if (c.idClass.isNotEmpty && !seen.contains(c.idClass)) {
        classItems.add(c);
        seen.add(c.idClass);
      }
    }

    // Compute a safe dropdown value: must be either null or one of the item ids
    final String? dropdownValue = (selectedClassId != null && classItems.any((c) => c.idClass == selectedClassId))
        ? selectedClassId
        : (classItems.isNotEmpty ? classItems.first.idClass : null);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Class
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  'Select Class',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // gunakan warna dari theme
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      borderRadius: BorderRadius.circular(14),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      items: classItems.map((c) {
                        return DropdownMenuItem(
                          value: c.idClass,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        if (val != null) {
                          setState(() => selectedClassId = val);
                          await _loadDiscussions();
                        }
                      },
                    ),
                  ),
                ),
              ),
              // Ongoing Discussion Rooms
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: const Text(
                  'Ongoing Discussion Rooms',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: CardDiscussionList(
                  discussions: ongoingDiscussions,
                  onEdit: (d) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
                  },
                  onDetails: (d) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: SizedBox(
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PageMenuDiscussionEditorTeacher(),
                        ),
                      );
                    },
                    child: const Text(
                      'Add Discussion Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              // Discussion Materials
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: const Text(
                  'Discussion Materials',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardMaterialList(materials: materials),
              // Completed Discussion Rooms
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: const Text(
                  'Completed Discussion Rooms',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              CardDiscussionList(
                discussions: completedDiscussions,
                onDetails: (d) {
                  // For completed discussions, open the details view (read-only)
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}