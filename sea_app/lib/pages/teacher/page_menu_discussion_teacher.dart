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
  String _sortType = 'terbaru';
  String _materialFilter = 'semua';

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

            // ── Pilih Kelas Card ─────────────────────────────────────
            _buildClassChips(classItems, effectiveClassId, isDark, gradient),
            const SizedBox(height: 8),

            // ── Ruang Diskusi Aktif (Tersortir) ─────────────────────
            () {
              final sortedOngoing = List<DiscussionRoom>.from(ongoingDiscussions);
              if (_sortType == 'abjad') {
                sortedOngoing.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              } else if (_sortType == 'z-a') {
                sortedOngoing.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
              } else {
                sortedOngoing.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Ruang Diskusi Aktif',
                    sortedOngoing.length,
                    isDark,
                    gradient,
                    subtitle: 'Kelola ruang diskusi interaktif kelas',
                    iconData: PhosphorIconsRegular.chatsCircle,
                  ),

                  // Filter Urutan khusus Diskusi Aktif
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Row(
                      children: [
                        _buildSortChip(
                          context,
                          label: "Terbaru",
                          isSelected: _sortType == 'terbaru',
                          onTap: () => setState(() => _sortType = 'terbaru'),
                          isDark: isDark,
                          gradient: gradient,
                        ),
                        const SizedBox(width: 8),
                        _buildSortChip(
                          context,
                          label: "A-Z",
                          isSelected: _sortType == 'abjad',
                          onTap: () => setState(() => _sortType = 'abjad'),
                          isDark: isDark,
                          gradient: gradient,
                        ),
                        const SizedBox(width: 8),
                        _buildSortChip(
                          context,
                          label: "Z-A",
                          isSelected: _sortType == 'z-a',
                          onTap: () => setState(() => _sortType = 'z-a'),
                          isDark: isDark,
                          gradient: gradient,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  CardDiscussionList(
                    discussions: sortedOngoing,
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
                ],
              );
            }(),

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

            // ── Dokumen Materi Diskusi (Selalu Tampil) ───────────────
            _buildSectionHeader('Dokumen Materi Diskusi', materials.length, isDark, gradient),

            // Filter Chips khusus Materi Diskusi (Semua, PDF, Teks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  _buildSortChip(
                    context,
                    label: "Semua",
                    isSelected: _materialFilter == 'semua',
                    onTap: () => setState(() => _materialFilter = 'semua'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    context,
                    label: "Dokumen PDF",
                    isSelected: _materialFilter == 'pdf',
                    onTap: () => setState(() => _materialFilter = 'pdf'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    context,
                    label: "Catatan Teks",
                    isSelected: _materialFilter == 'teks',
                    onTap: () => setState(() => _materialFilter = 'teks'),
                    isDark: isDark,
                    gradient: gradient,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            () {
              var filteredMats = List<MaterialPdf>.from(materials);
              if (_materialFilter == 'pdf') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() == 'pdf').toList();
              } else if (_materialFilter == 'teks') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() != 'pdf').toList();
              }
              return CardMaterialList(materials: filteredMats);
            }(),

            // ── Riwayat Diskusi Selesai (Tersortir) ──────────────────
            () {
              final sortedCompleted = List<DiscussionRoom>.from(completedDiscussions);
              if (_sortType == 'abjad') {
                sortedCompleted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              } else if (_sortType == 'z-a') {
                sortedCompleted.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
              } else {
                sortedCompleted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Riwayat Diskusi Selesai', sortedCompleted.length, isDark, gradient),
                  CardDiscussionList(
                    discussions: sortedCompleted,
                    onDetails: (d) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom),
                      ));
                    },
                  ),
                ],
              );
            }(),

            const SizedBox(height: 100), // ruang untuk bottom nav
          ],
        ),
      ),
    );
  }

  // ── Section header: Ikon Lingkaran + Judul + Subtitle + Count Badge ─────────
  Widget _buildSectionHeader(
    String title,
    int count,
    bool isDark,
    List<Color> gradient, {
    String? subtitle,
    IconData iconData = PhosphorIconsRegular.chatsCircle,
  }) {
    final accent = gradient.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Selector Kelas Modern (Presisi Referensi) ─────────────────────────
  Widget _buildClassChips(
    List<ClassModel> classItems,
    String? selectedId,
    bool isDark,
    List<Color> gradient,
  ) {
    final accent = gradient.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row inside Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.graduationCap,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Kelas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih kelas untuk mengelola ruang diskusi',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${classItems.length} Kelas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (classItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tidak ada kelas tersedia',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            )
          else
            SizedBox(
              height: 102,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: classItems.length,
                itemBuilder: (_, i) {
                  final c = classItems[i];
                  final isSelected = c.idClass == selectedId;
                  return Padding(
                    padding: EdgeInsets.only(right: i < classItems.length - 1 ? 10 : 0),
                    child: InkWell(
                      onTap: () async {
                        if (isSelected) return;
                        setState(() => selectedClassId = c.idClass);
                        await _loadDiscussions();
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 115,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(colors: gradient) : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: gradient.first.withValues(alpha: 0.30),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIconsRegular.bookOpen,
                              size: 24,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Center(
                                child: Text(
                                  c.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.textPrimaryDark : const Color(0xFF334155)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
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

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required List<Color> gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}