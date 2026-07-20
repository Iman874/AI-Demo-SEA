import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../component/card/card_material.dart';
import '../../component/card/card_quiz.dart';
import '../../models/material.dart';
import '../../models/quiz.dart';
import 'page_menu_quiz_editor_teacher.dart';
import 'page_menu_quiz_result_teacher.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../component/window/window_add_material.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../component/state/skeleton_loading.dart';
import '../../utils/app_notification.dart';

class PageMenuQuizTeacher extends StatefulWidget {
  const PageMenuQuizTeacher({super.key});

  @override
  State<PageMenuQuizTeacher> createState() => _PageMenuQuizTeacherState();
}

class _PageMenuQuizTeacherState extends State<PageMenuQuizTeacher> {
  String? selectedClassId;
  String? selectedQuizId;
  bool _loading = true;
  String _materialFilter = 'semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = Provider.of<QuizProvider>(context, listen: false);
      try {
        final ok = await prov.loadClasses();
        if (ok && prov.classes.isNotEmpty) {
          selectedClassId = prov.classes.first['id_class'].toString();
          await prov.loadQuizzes(classId: selectedClassId);
          if (prov.quizzes.isNotEmpty) {
            selectedQuizId = prov.quizzes.first['id_quiz']?.toString() ?? prov.quizzes.first['id']?.toString();
            await prov.loadMaterials(quizId: selectedQuizId);
          } else {
            await prov.loadMaterials();
          }
        }
      } catch (_) {
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SkeletonListContent();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prov = Provider.of<QuizProvider>(context);
    final classes = prov.classes;
    final quizzes = prov.quizzes;
    const gradient = AppColors.teacherGradient;
    const accent = AppColors.teacherAccent;

    void ensureQuizzesForClass(String? classId) async {
      if (classId != null) {
        await prov.loadQuizzes(classId: classId);
      } else {
        await prov.loadQuizzes();
      }
      if (prov.quizzes.isNotEmpty) {
        if (selectedQuizId == null || !prov.quizzes.any((q) => (q['id_quiz']?.toString() ?? q['id']?.toString()) == selectedQuizId)) {
          selectedQuizId = prov.quizzes.first['id_quiz']?.toString() ?? prov.quizzes.first['id']?.toString();
        }
        await prov.loadMaterials(quizId: selectedQuizId);
      }
    }

    return RefreshIndicator(
      color: accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      onRefresh: () async {
        final ok = await prov.loadClasses();
        if (ok && prov.classes.isNotEmpty) {
          selectedClassId ??= prov.classes.first['id_class'].toString();
          await prov.loadQuizzes(classId: selectedClassId);
          if (prov.quizzes.isNotEmpty) {
            selectedQuizId ??= prov.quizzes.first['id_quiz']?.toString() ?? prov.quizzes.first['id']?.toString();
            await prov.loadMaterials(quizId: selectedQuizId);
          }
        }
        if (mounted) setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Pilih Kelas Card ───────────────────────────────────────
            _buildMapChips(
              isDark: isDark,
              gradient: gradient,
              items: classes,
              idKey: 'id_class',
              labelKey: 'name',
              selectedId: selectedClassId,
              onSelect: (val) async {
                setState(() => selectedClassId = val);
                ensureQuizzesForClass(val);
              },
            ),
            
            // ── Pilih Kuis (chip row, untuk materi) ─────────────────────
            if (quizzes.isNotEmpty) ...[
              _buildSectionHeader('Pilih Kuis (untuk Materi)', quizzes.length, isDark, gradient),
              _buildMapChips(
                isDark: isDark,
                gradient: gradient,
                items: quizzes,
                idKey: 'id_quiz',
                labelKey: 'title',
                selectedId: selectedQuizId,
                onSelect: (val) async {
                  setState(() => selectedQuizId = val);
                  await prov.loadMaterials(quizId: val);
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 4),
            ],

            // ── Dokumen & Materi Kuis (Selalu tampil agar tidak kosong bolong) ──
            _buildSectionHeader('Dokumen & Materi Kuis', prov.materials.length, isDark, gradient),

            // Filter Chips khusus Materi (Semua, PDF, Teks)
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
              var filteredMats = prov.materials.map((m) => MaterialPdfJson.fromJson(m)).toList();
              if (_materialFilter == 'pdf') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() == 'pdf').toList();
              } else if (_materialFilter == 'teks') {
                filteredMats = filteredMats.where((m) => m.type.toLowerCase() != 'pdf').toList();
              }
              return CardMaterialList(
                materials: filteredMats,
              );
            }(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: AppButton.primary(
                label: 'Tambah Materi Kuis',
                icon: PhosphorIconsRegular.upload,
                gradientColors: AppColors.teacherGradient,
                onPressed: () async {
                  final qProv = Provider.of<QuizProvider>(context, listen: false);
                  final navigator = Navigator.of(context);
                  final res = await showDialog<bool?>(
                    context: navigator.context,
                    builder: (context) => WindowAddMaterial(fkIdQuiz: selectedQuizId),
                  );
                  if (res == true) {
                    await qProv.loadMaterials(quizId: selectedQuizId);
                    if (!mounted) return;
                    setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Daftar Kuis ──────────────────────────────────────────────
            _buildSectionHeader('Daftar Kuis', quizzes.length, isDark, gradient),
            CardQuizList(
              quizzes: quizzes.map((q) {
                return Quiz(
                  idQuiz: q['id_quiz']?.toString() ?? q['id']?.toString() ?? '',
                  title: q['title']?.toString() ?? '',
                  duration: int.tryParse(q['duration']?.toString() ?? '0') ?? 0,
                  createBy: q['created_by']?.toString() ?? '',
                  createAt: DateTime.tryParse(q['created_at']?.toString() ?? '') ?? DateTime.now(),
                  updateAt: DateTime.tryParse(q['updated_at']?.toString() ?? '') ?? DateTime.now(),
                );
              }).toList(),
              onViewResult: (quiz) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PageMenuQuizResultTeacher(
                      quizId: quiz.idQuiz,
                      title: quiz.title,
                      classId: selectedClassId,
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: AppButton.primary(
                label: 'Buat Kuis Baru',
                icon: PhosphorIconsRegular.clipboardText,
                gradientColors: AppColors.teacherGradient,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final quizProv = Provider.of<QuizProvider>(context, listen: false);
                  final id = await quizProv.createQuiz(title: 'Kuis Baru');
                  if (id != null) {
                    navigator.push(MaterialPageRoute(builder: (_) => PageMenuQuizEditorTeacher(quizId: id)));
                  } else {
                    if (context.mounted) {
                      AppNotification.show(context, 'Gagal membuat kuis baru.', isError: true);
                    }
                  }
                },
              ),
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

  // ── Card Selector Modern untuk List<Map<String,dynamic>> ────────────────
  Widget _buildMapChips({
    required bool isDark,
    required List<Color> gradient,
    required List<Map<String, dynamic>> items,
    required String idKey,
    required String labelKey,
    required String? selectedId,
    required void Function(String) onSelect,
    String title = 'Pilih Kelas',
  }) {
    final accent = gradient.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length} ${title.contains("Kelas") ? "Kelas" : "Item"}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Tidak ada data tersedia',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            )
          else
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final id = item[idKey]?.toString() ?? item['id']?.toString() ?? '';
                  final label = item[labelKey]?.toString() ?? '';
                  final isSelected = id == selectedId;
                  return Padding(
                    padding: EdgeInsets.only(right: i < items.length - 1 ? 8 : 0),
                    child: InkWell(
                      onTap: () {
                        if (isSelected) return;
                        onSelect(id);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(colors: gradient) : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
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
                                    color: gradient.first.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhosphorIconsRegular.chalkboard,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
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