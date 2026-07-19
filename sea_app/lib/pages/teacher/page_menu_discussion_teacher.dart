import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../component/card/card_discussion.dart';
import '../../component/card/card_material.dart';
import '../../models/discussion_room.dart';
import '../../models/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_editor_teacher.dart';
import 'page_menu_discussion_details_teacher.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../component/state/skeleton_loading.dart';

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
    if (_loading) return const SkeletonListContent();
    if (_error != null) return Center(child: Text('Error: $_error'));

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              // Pilih Kelas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: Text(
                  'Pilih Kelas',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          PhosphorIconsRegular.graduationCap,
                          color: isDark ? Colors.white38 : const Color(0xFF64748B),
                        ),
                      ),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
              const SizedBox(height: 12),

              // Ruang Diskusi Aktif
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Text(
                  'Ruang Diskusi Aktif',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              CardDiscussionList(
                discussions: ongoingDiscussions,
                onEdit: (d) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
                },
                onDetails: (d) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: AppButton.primary(
                  label: 'Buat Ruang Diskusi',
                  icon: PhosphorIconsRegular.chatCircle,
                  gradientColors: AppColors.teacherGradient,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PageMenuDiscussionEditorTeacher(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Dokumen Materi Diskusi
              if (materials.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Text(
                    'Dokumen Materi Diskusi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                CardMaterialList(materials: materials),
                const SizedBox(height: 12),
              ],

              // Riwayat Diskusi Selesai
              if (completedDiscussions.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Text(
                    'Riwayat Diskusi Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                CardDiscussionList(
                  discussions: completedDiscussions,
                  onDetails: (d) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
                  },
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}