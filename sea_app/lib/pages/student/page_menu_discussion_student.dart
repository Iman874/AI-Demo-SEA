import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../component/card/card_material.dart';
import '../../models/material.dart';
import '../../component/card/card_discussion.dart';
import '../../models/discussion_room.dart';
import '../../models/class.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_detail_student.dart';
import '../../component/state/skeleton_loading.dart';
import '../../theme/app_colors.dart';

class PageMenuDiscussionStudent extends StatefulWidget {
  const PageMenuDiscussionStudent({super.key});

  @override
  State<PageMenuDiscussionStudent> createState() => _PageMenuDiscussionStudentState();
}

class _PageMenuDiscussionStudentState extends State<PageMenuDiscussionStudent> {
  late List<ClassModel> studentClasses;
  late String selectedClassId;
  // removed local/all-classes cache; we fetch classes as needed from API
  List<DiscussionRoom> _discussions = [];
  List<MaterialPdf> _materials = [];
  bool _loading = true;
  String? _error;
  String _sortType = 'terbaru';
  String _materialFilter = 'semua';

  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    // Ambil kelas yang diikuti oleh studentUser (handled in _loadAll)
    studentClasses = [];
    selectedClassId = '';
    _loadAll();
    // register listener after first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = Provider.of<AuthProvider>(context, listen: false);
      _auth?.addListener(_authListener);
    });
  }

  void _authListener() {
    // reload classes when auth signals change
    if (mounted) _loadAll();
  }

  @override
  void dispose() {
    // remove listener
    _auth?.removeListener(_authListener);
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      // Prefer explicit user_id API call (server-side user_class) to ensure we return classes related to the student
      String? userId = auth.user?.id;
      final idResp = await ApiService.getUserClassIds(token: auth.token, userId: userId);
      if (idResp.statusCode == 200) {
        final idBody = jsonDecode(idResp.body);
        final ids = ((idBody['data'] as List<dynamic>?) ?? []).map((e) => e.toString()).toSet();
        if (ids.isNotEmpty) {
          final classesResp = await ApiService.getClasses();
          if (classesResp.statusCode == 200) {
            final clsBody = jsonDecode(classesResp.body);
            final itemsAll = clsBody['data'] as List<dynamic>? ?? [];
            final all = itemsAll.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
            studentClasses = all.where((c) => ids.contains(c.idClass)).toList();
            selectedClassId = studentClasses.isNotEmpty ? studentClasses.first.idClass : '';
            if (selectedClassId.isNotEmpty) await _loadDiscussions();
          }
        } else {
          // no classes for this user
          studentClasses = [];
          selectedClassId = '';
        }
      } else {
        // failed to fetch ids: clear
        studentClasses = [];
        selectedClassId = '';
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadDiscussions() async {
    if (selectedClassId.isEmpty) return;
    try {
      // Muat materi diskusi
      try {
        final matResp = await ApiService.getMaterials();
        if (matResp.statusCode == 200) {
          final body = jsonDecode(matResp.body);
          final items = (body['data'] as List<dynamic>?) ?? [];
          _materials = items.map((e) => MaterialPdfJson.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}

      final resp = await ApiService.getDiscussions(classId: selectedClassId);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeDiscussions = _discussions
        .where((d) => d.status == 'open' && d.chatroomActive == true)
        .toList();
    final completedDiscussions =
        _discussions.where((d) => d.status == 'closed').toList();
    const gradient = AppColors.studentGradient;
    const accent = AppColors.studentAccent;

    if (_error != null) {
      return _buildErrorCard(_error!, isDark, accent, gradient);
    }

    final content = RefreshIndicator(
      color: accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Class chip selector Card ────────────────────────────────
            _buildClassChips(isDark, gradient, accent),
            const SizedBox(height: 8),

            // ── Diskusi Aktif (Tersortir) ────────────────────────────────
            () {
              final sortedActive = List<DiscussionRoom>.from(activeDiscussions);
              if (_sortType == 'abjad') {
                sortedActive.sort(
                  (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );
              } else if (_sortType == 'z-a') {
                sortedActive.sort(
                  (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
                );
              } else {
                sortedActive.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Ruang Diskusi Aktif',
                    sortedActive.length,
                    isDark,
                    gradient,
                    subtitle: 'Diskusi kelompok interaktif berbasis AI',
                    iconData: PhosphorIconsRegular.chatsCircle,
                  ),

                  // Filter Urutan khusus Diskusi Aktif
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                  ),
                  const SizedBox(height: 6),

                  CardDiscussionList(
                    discussions: sortedActive,
                    onViewDetails: (d) async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiscussionDetailStudentPage(discussion: d),
                        ),
                      );
                      if (!mounted) return;
                      await _loadDiscussions();
                    },
                    buttonLabel: 'Masuk Obrolan',
                  ),
                ],
              );
            }(),

            // ── Dokumen Materi Diskusi (Selalu Tampil) ───────────────
            _buildSectionHeader(
              'Dokumen Materi Diskusi',
              _materials.length,
              isDark,
              gradient,
            ),

            // Filter Chips khusus Materi Diskusi (Semua, PDF, Teks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
            ),
            const SizedBox(height: 6),

            () {
              var filteredMats = List<MaterialPdf>.from(_materials);
              if (_materialFilter == 'pdf') {
                filteredMats =
                    filteredMats.where((m) => m.type.toLowerCase() == 'pdf').toList();
              } else if (_materialFilter == 'teks') {
                filteredMats = filteredMats
                    .where((m) => m.type.toLowerCase() != 'pdf')
                    .toList();
              }
              return CardMaterialList(materials: filteredMats);
            }(),
            const SizedBox(height: 8),

            // ── Riwayat Diskusi Selesai (Tersortir) ─────────────────────
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
                  _buildSectionHeader(
                    'Riwayat Diskusi Selesai',
                    sortedCompleted.length,
                    isDark,
                    gradient,
                  ),
                  CardDiscussionList(
                    discussions: sortedCompleted,
                    onViewDetails: (d) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiscussionDetailStudentPage(discussion: d),
                        ),
                      );
                    },
                    buttonLabel: 'Detail Diskusi',
                  ),
                ],
              );
            }(),

            const SizedBox(height: 100), // ruang untuk bottom nav
          ],
        ),
      ),
    );

    return content;
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
  Widget _buildClassChips(bool isDark, List<Color> gradient, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.graduationCap,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Kelas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Pilih kelas untuk ruang diskusi',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${studentClasses.length} Kelas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (studentClasses.isEmpty)
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
              height: 84,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: studentClasses.length,
                itemBuilder: (_, i) {
                  final c = studentClasses[i];
                  final isSelected = c.idClass == selectedClassId;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < studentClasses.length - 1 ? 10 : 0,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (isSelected) return;
                          setState(() => selectedClassId = c.idClass);
                          await _loadDiscussions();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(14),
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
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Center(
                                child: Text(
                                  c.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    height: 1.1,
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
                  ),
                );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── Error card dengan tombol retry ───────────────────────────────────────
  Widget _buildErrorCard(
    String error,
    bool isDark,
    Color accent,
    List<Color> gradient,
  ) {
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
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 30,
              ),
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
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? gradient.first : (isDark ? AppColors.cardDark : Colors.white),
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
      ),
    );
  }
}