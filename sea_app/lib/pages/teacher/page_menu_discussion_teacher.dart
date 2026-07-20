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
    if (_error != null) {
      final isDarkErr = Theme.of(context).brightness == Brightness.dark;
      return _buildErrorCard(_error!, isDarkErr);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ongoingDiscussions = _discussions.where((d) => d.status == 'open').toList();
    final completedDiscussions = _discussions.where((d) => d.status == 'closed').toList();
    final materials = _materials;
    const gradient = AppColors.teacherGradient;
    const accent = AppColors.teacherAccent;

    // Deduplicate & filter empty class ids for chip row
    final List<ClassModel> classItems = [];
    final seen = <String>{};
    for (final c in _classes) {
      if (c.idClass.isNotEmpty && !seen.contains(c.idClass)) {
        classItems.add(c);
        seen.add(c.idClass);
      }
    }
    // Ensure safe selectedClassId
    final effectiveClassId = (selectedClassId != null && classItems.any((c) => c.idClass == selectedClassId))
        ? selectedClassId
        : (classItems.isNotEmpty ? classItems.first.idClass : null);

    return RefreshIndicator(
      color: accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      onRefresh: _loadClasses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Pilih Kelas (chip row) ───────────────────────────────
            _buildSectionHeader('Pilih Kelas', classItems.length, isDark, gradient),
            _buildClassChips(classItems, effectiveClassId, isDark, gradient),
            const SizedBox(height: 8),

            // ── Ruang Diskusi Aktif ─────────────────────────────────
            _buildSectionHeader('Ruang Diskusi Aktif', ongoingDiscussions.length, isDark, gradient),
            CardDiscussionList(
              discussions: ongoingDiscussions,
              onEdit: (d) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom),
                ));
              },
              onDetails: (d) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom),
                ));
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

            // ── Dokumen Materi Diskusi ──────────────────────────────
            if (materials.isNotEmpty) ...[
              _buildSectionHeader('Dokumen Materi Diskusi', materials.length, isDark, gradient),
              CardMaterialList(materials: materials),
            ],

            // ── Riwayat Diskusi Selesai ────────────────────────────
            _buildSectionHeader('Riwayat Diskusi Selesai', completedDiscussions.length, isDark, gradient),
            CardDiscussionList(
              discussions: completedDiscussions,
              onDetails: (d) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom),
                ));
              },
            ),

            const SizedBox(height: 100), // ruang untuk bottom nav
          ],
        ),
      ),
    );
  }

  // ── Section header: accent bar + judul + count badge ────────────────────
  Widget _buildSectionHeader(
    String title,
    int count,
    bool isDark,
    List<Color> gradient,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gradient.first.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: gradient.first,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal chip row untuk kelas ────────────────────────────────────
  Widget _buildClassChips(
    List<ClassModel> classItems,
    String? selectedId,
    bool isDark,
    List<Color> gradient,
  ) {
    if (classItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.graduationCap,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Tidak ada kelas tersedia',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: classItems.length,
        itemBuilder: (_, i) {
          final c = classItems[i];
          final isSelected = c.idClass == selectedId;
          return Padding(
            padding: EdgeInsets.only(right: i < classItems.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () async {
                if (isSelected) return;
                setState(() => selectedClassId = c.idClass);
                await _loadDiscussions();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(colors: gradient) : null,
                  color: isSelected
                      ? null
                      : (isDark ? AppColors.cardDark : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  c.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Error card dengan tombol retry ───────────────────────────────────
  Widget _buildErrorCard(String error, bool isDark) {
    const gradient = AppColors.teacherGradient;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadClasses,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}