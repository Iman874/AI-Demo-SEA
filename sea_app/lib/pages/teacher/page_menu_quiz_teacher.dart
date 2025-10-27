import 'package:flutter/material.dart';
import '../../component/card/card_material.dart';
import '../../component/card/card_quiz.dart';
import '../../models/material.dart';
import '../../models/quiz.dart';
// import '../../models/quiz_class.dart'; // not used after removing dummy data
import 'page_menu_quiz_editor_teacher.dart';
import 'page_menu_quiz_result_teacher.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../component/window/window_add_material.dart';

class PageMenuQuizTeacher extends StatefulWidget {
  const PageMenuQuizTeacher({super.key});

  @override
  State<PageMenuQuizTeacher> createState() => _PageMenuQuizTeacherState();
}

class _PageMenuQuizTeacherState extends State<PageMenuQuizTeacher> {
  String? selectedClassId;

  @override
  void initState() {
    super.initState();
    // Load classes from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<QuizProvider>(context, listen: false);
      prov.loadClasses().then((ok) {
        if (ok && prov.classes.isNotEmpty) {
          setState(() {
            selectedClassId = prov.classes.first['id_class'].toString();
          });
          // Load quizzes for the selected class
          prov.loadQuizzes(classId: prov.classes.first['id_class'].toString());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
  final prov = Provider.of<QuizProvider>(context);
  final classes = prov.classes;
  final quizzes = prov.quizzes;
  // if selected class changed, ensure quizzes are loaded for that class
  void ensureQuizzesForClass(String? classId) {
    if (classId != null) {
      prov.loadQuizzes(classId: classId);
    } else {
      prov.loadQuizzes();
    }
  }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Class
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Select Class",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                    value: selectedClassId,
                    borderRadius: BorderRadius.circular(14),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    items: classes.isEmpty
                        ? [
                            const DropdownMenuItem(value: null, child: Text('No classes'))
                          ]
                        : classes.map((c) {
                            return DropdownMenuItem(
                              value: c['id_class'].toString(),
                              child: Text(c['name'].toString()),
                            );
                          }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedClassId = val);
                        ensureQuizzesForClass(val);
                      }
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Quiz Material",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            // Show materials related to selected quiz or class if available
            CardMaterialList(materials: prov.materials.map((m) {
              // map backend material JSON to MaterialPdf model
              return MaterialPdfJson.fromJson(m);
            }).toList()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B6A85),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                    onPressed: () async {
                    // Capture provider and navigator before awaiting the dialog
                    final qProv = Provider.of<QuizProvider>(context, listen: false);
                    final navigator = Navigator.of(context);
                    final res = await showDialog<bool?>(
                      context: navigator.context,
                      builder: (context) => const WindowAddMaterial(),
                    );
                    if (res == true) {
                      // refresh provider materials
                      await qProv.loadMaterials();
                      if (!mounted) return;
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Text(
                "Quiz",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            CardQuizList(
              quizzes: quizzes.map((q) {
                // convert quiz map into a minimal object expected by CardQuizList
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
                    builder: (_) => const PageMenuQuizResultTeacher(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5F4B),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                    onPressed: () async {
                    // Create a new quiz immediately with a placeholder title and open editor
                    final parentContext = context;
                    final navigator = Navigator.of(parentContext);
                    final scaffold = ScaffoldMessenger.of(parentContext);
                    final quizProv = Provider.of<QuizProvider>(parentContext, listen: false);
                    final id = await quizProv.createQuiz(title: 'Untitled Quiz');
                    if (id != null) {
                      navigator.push(MaterialPageRoute(builder: (_) => PageMenuQuizEditorTeacher(quizId: id)));
                    } else {
                      if (!mounted) return;
                      scaffold.showSnackBar(const SnackBar(content: Text('Failed to create quiz')));
                    }
                  },
                  child: const Text(
                    "Add Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
}