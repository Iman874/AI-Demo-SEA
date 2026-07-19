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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilih Kelas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Pilih Kelas",
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
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: selectedClassId,
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
                    items: classes.map((c) {
                      return DropdownMenuItem(
                        value: c['id_class']?.toString() ?? '',
                        child: Text(c['name']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => selectedClassId = val);
                        ensureQuizzesForClass(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown Pilih Kuis Aktif
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Pilih Kuis Aktif",
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
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: selectedQuizId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        PhosphorIconsRegular.checkCircle,
                        color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      ),
                    ),
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: quizzes.map((q) {
                      final qId = q['id_quiz']?.toString() ?? q['id']?.toString() ?? '';
                      return DropdownMenuItem(
                        value: qId,
                        child: Text(q['title']?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => selectedQuizId = val);
                        await prov.loadMaterials(quizId: val);
                        if (mounted) setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Materi Kuis
            if (prov.materials.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Text(
                  "Dokumen & Materi Kuis",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              CardMaterialList(
                materials: prov.materials.map((m) {
                  return MaterialPdfJson.fromJson(m);
                }).toList(),
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: AppButton.primary(
                label: "Tambah Materi Kuis",
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

            // Daftar Kuis
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Text(
                "Daftar Kuis",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
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
                label: "Buat Kuis Baru",
                icon: PhosphorIconsRegular.clipboardText,
                gradientColors: AppColors.teacherGradient,
                onPressed: () async {
                  final parentContext = context;
                  final navigator = Navigator.of(parentContext);
                  final quizProv = Provider.of<QuizProvider>(parentContext, listen: false);
                  final id = await quizProv.createQuiz(title: 'Kuis Baru');
                  if (id != null) {
                    navigator.push(MaterialPageRoute(builder: (_) => PageMenuQuizEditorTeacher(quizId: id)));
                  } else {
                    if (!mounted) return;
                    AppNotification.show(context, 'Gagal membuat kuis baru.', isError: true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}