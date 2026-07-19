import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../component/window/window_message.dart';
import '../../providers/quiz_provider.dart';
import '../../component/window/window_add_material.dart';
import '../../component/card/card_material.dart';
import '../../pages/teacher/page_quiz_questions_teacher.dart';
import '../../utils/app_logger.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../utils/app_notification.dart';
import '../../models/material.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';

class PageMenuQuizEditorTeacher extends StatefulWidget {
  final int? quizId;
  const PageMenuQuizEditorTeacher({super.key, this.quizId});

  @override
  State<PageMenuQuizEditorTeacher> createState() => _PageMenuQuizEditorTeacherState();
}

class _PageMenuQuizEditorTeacherState extends State<PageMenuQuizEditorTeacher> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedDuration = "1 Hour 30 Minute";
  final List<String> _durations = [
    "30 Minute",
    "1 Hour",
    "1 Hour 30 Minute",
    "2 Hour",
  ];

  // Dummy material & questions (kosong, karena editor)
  final List<Question> _questions = [];
  // Local unsaved materials (kept in editor state until Save pressed). Each has at least: tmp_id, title, content, type
  final List<Map<String, dynamic>> _localMaterials = [];
  int? get _quizId => widget.quizId;
  bool _saving = false;
  String? _selectedClassId;


  @override
  Widget build(BuildContext context) {
    // Ambil materi dari soal yang sudah direlasikan
  final prov = Provider.of<QuizProvider>(context);
  final persistedMaterials = prov.materials.map((m) => MaterialPdfJson.fromJson(m)).toList();
  final localMaterialsDisplay = _localMaterials.map((m) {
    return MaterialPdf(
      id: m['tmp_id']?.toString() ?? m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      type: m['type']?.toString() ?? 'text',
      createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(m['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }).toList();
  final relatedMaterials = [...persistedMaterials, ...localMaterialsDisplay];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _quizId != null ? "Ubah Detail Kuis" : "Buat Kuis Baru",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "Sesuaikan materi, durasi, dan bank soal",
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
                          // Card Judul Kuis
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
                                  "Judul Kuis",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _titleController,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Contoh: Kuis Harian Pemrograman Dasar",
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
                                      Icons.quiz_rounded,
                                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Card Kelas Target
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
                                  "Kelas Target",
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
                                          Icons.school_rounded,
                                          color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      value: _selectedClassId,
                                      items: prov.classes.isEmpty
                                          ? [const DropdownMenuItem(value: null, child: Text('Tidak ada kelas tersedia'))]
                                          : prov.classes.map((c) => DropdownMenuItem(value: c['id_class'].toString(), child: Text(c['name'].toString()))).toList(),
                                      onChanged: (val) {
                                        setState(() => _selectedClassId = val);
                                      },
                                      hint: const Text('Pilih kelas sasaran'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Card Durasi
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
                                  "Durasi Kerja",
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
                                          Icons.timer_rounded,
                                          color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      value: _selectedDuration,
                                      items: _durations.map((d) {
                                        return DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedDuration = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Card Dokumen Materi
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Materi Pendukung",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                                      ),
                                      onPressed: () async {
                                        final res = await showDialog<Map<String, dynamic>?>(
                                          context: context,
                                          builder: (context) => WindowAddMaterial(fkIdQuiz: _quizId?.toString(), saveImmediately: false),
                                        );
                                        if (res != null) {
                                          final tmpId = DateTime.now().millisecondsSinceEpoch.toString();
                                          final mat = Map<String, dynamic>.from(res);
                                          mat['tmp_id'] = tmpId;
                                          _localMaterials.add(mat);
                                          setState(() {});
                                        } else {
                                          if (_quizId != null) await prov.loadMaterials(quizId: _quizId.toString());
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                relatedMaterials.isEmpty
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Belum ada materi pelajaran yang dilampirkan.",
                                            style: TextStyle(fontSize: 13, color: Colors.grey),
                                          ),
                                        ),
                                      )
                                    : CardMaterialList(
                                        materials: relatedMaterials,
                                        onViewMaterial: (m) {},
                                      ),
                              ],
                            ),
                          ),

                          // Card Soal Kuis
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Daftar Soal Kuis",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_questions.length} soal tersimpan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Badge jumlah soal
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.blue.shade900.withValues(alpha: 0.4)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_questions.length}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.blue.shade300 : const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final currentMaterials = [...persistedMaterials, ...localMaterialsDisplay];
                                      final result = await Navigator.of(context).push<List<Question>>(
                                        MaterialPageRoute(
                                          builder: (_) => PageQuizQuestionsTeacher(
                                            questions: List.from(_questions),
                                            materials: currentMaterials,
                                            quizTitle: _titleController.text.isEmpty
                                                ? 'Kuis Tanpa Judul'
                                                : _titleController.text,
                                          ),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          _questions
                                            ..clear()
                                            ..addAll(result);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                                    label: Text(
                                      _questions.isEmpty
                                          ? 'Buka Editor Soal'
                                          : 'Kelola ${_questions.length} Soal',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // AI Generator Action Card
                          if (_localMaterials.isNotEmpty) ...[
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
                                    "Aksi AI (Gemini Assistant)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(
                                          color: isDark ? Colors.blue.shade800 : const Color(0xFF4B6A85),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: const Icon(Icons.auto_awesome_rounded),
                                      label: const Text(
                                        "Generate Soal dari Materi [AI]",
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () async {
                                        final navigator = Navigator.of(context);
                                        final payload = {'materials': _localMaterials};
                                        try {
                                          AppLogger.i('Requesting generated questions from AI');
                                          final resp = await ApiService.generateQuestions(payload);
                                          if (resp.statusCode == 200) {
                                            final data = jsonDecode(resp.body);
                                            final text = data['result'] ?? data.toString();
                                            if (!mounted) return;
                                            await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: text));
                                            final parsed = _parseQuestionsFromText(text);
                                            if (parsed.isNotEmpty) {
                                              if (mounted) {
                                                setState(() {
                                                  _questions.addAll(parsed);
                                                });
                                                AppNotification.show(context, 'Berhasil membuat ${parsed.length} soal lewat AI!');
                                              }
                                            } else {
                                              if (!mounted) return;
                                              await showDialog(context: navigator.context, builder: (_) => const WindowMessage(message: 'AI mengembalikan teks tetapi tidak dapat diuraikan menjadi soal format kuis'));
                                            }
                                          } else {
                                            if (!mounted) return;
                                            await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Gagal membuat soal AI: ${resp.statusCode}'));
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Gagal memproses AI: $e'));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 90), // Spacer bottom
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Tombol Simpan melayang di bawah layar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: _saving ? "Menyimpan..." : "Simpan Perubahan Kuis",
                    gradientColors: AppColors.teacherGradient,
                    onPressed: _saving ? null : () async {
                      await _saveQuiz();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuiz() async {
    setState(() => _saving = true);

    // Build payload
    final title = _titleController.text.trim();
    final payload = <String, dynamic>{
      'title': title.isEmpty ? 'Untitled Quiz' : title,
      'duration': _selectedDuration,
      // optional: include quiz_id when editing existing
      if (_quizId != null) 'quiz_id': _quizId,
    };
    if (_selectedClassId != null) payload['class_ids'] = [int.tryParse(_selectedClassId!)];

    // include local unsaved materials so backend can create them together with the quiz
    if (_localMaterials.isNotEmpty) {
      payload['materials'] = _localMaterials.map((m) => {
        'tmp_id': m['tmp_id'],
        'title': m['title'],
        'content': m['content'],
        'type': m['type'],
      }).toList();
    }

    // adjust questions: ensure fk_id_material references local tmp_id when applicable
    final adjustedQuestions = _questions.map((q) {
      dynamic fkMat;
      if (q.fkIdMaterial != null) {
        // if fkIdMaterial matches a local material id or tmp id, prefer tmp_id
        final local = _localMaterials.firstWhere(
          (m) => m['id']?.toString() == q.fkIdMaterial?.toString() || m['tmp_id'] == q.fkIdMaterial,
          orElse: () => {},
        );
        if (local.isNotEmpty) {
          fkMat = local['tmp_id'];
        } else {
          fkMat = int.tryParse(q.fkIdMaterial ?? '') ?? q.fkIdMaterial;
        }
      }
      return {
        'number': q.number,
        'question_text': q.question,
        'point': q.poin,
        'fk_id_material': fkMat,
        'choices': q.answerChoices.map((c) => {
          'content': c.content,
          'is_correct': c.isCorrect,
        }).toList(),
      };
    }).toList();
    payload['questions'] = adjustedQuestions;
    if (_selectedClassId != null) {
      payload['class_ids'] = [int.tryParse(_selectedClassId!)];
    }

  final navigator = Navigator.of(context);
  try {
      // Log payload for debugging (safe encode)
      try {
        AppLogger.d('Quiz save payload: ${jsonEncode(payload)}');
      } catch (e) {
        AppLogger.w('Failed to JSON-encode quiz payload for logging', e);
      }

      final resp = await ApiService.createFullQuiz(payload);
      // Log response details for debugging
      AppLogger.d('Quiz save response status: ${resp.statusCode}');
      AppLogger.d('Quiz save response headers: ${resp.headers}');
      AppLogger.d('Quiz save response body: ${resp.body}');

  if (resp.statusCode == 201) {
        AppLogger.i('Quiz saved successfully (201)');
        if (!mounted) return;
        await showDialog(
          context: navigator.context,
          builder: (_) => WindowMessage(message: 'Quiz saved successfully', onOk: () {
            navigator.pop();
          }),
        );

        // after saving, pop back to previous page
        if (!mounted) return;
        navigator.pop(true);
      } else {
        AppLogger.e('Failed to save quiz: status=${resp.statusCode}', resp.body);
  final msg = 'Failed to save quiz: ${resp.statusCode}\n${resp.body}';
  if (!mounted) return;
  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: msg));
      }
    } catch (e, st) {
  AppLogger.e('Exception when saving quiz', e, st);
  if (!mounted) return;
  await showDialog(context: navigator.context, builder: (_) => WindowMessage(message: 'Failed to save quiz: $e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // if quizId present, load related materials
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<QuizProvider>(context, listen: false);
      prov.loadClasses();
      if (_quizId != null) prov.loadMaterials(quizId: _quizId.toString());
    });
  }

  /// Heuristic parser: converts raw AI text into a list of Question objects.
  List<Question> _parseQuestionsFromText(String text) {
    final List<Question> out = [];
  // material titles are available via provider and _localMaterials when needed

    // Split into blocks per numbered question
    final lines = text.split(RegExp(r'\r?\n'));
    final List<int> qStarts = [];
    final qRegex = RegExp(r'^(\s*)(\d+)\s*[\.|\)]\s*(.*)');
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i].trimLeft();
      if (qRegex.hasMatch(l)) qStarts.add(i);
    }
    if (qStarts.isEmpty) {
      // fallback: treat whole text as single block
      qStarts.add(0);
    }

    for (int idx = 0; idx < qStarts.length; idx++) {
      final start = qStarts[idx];
      final end = (idx + 1 < qStarts.length) ? qStarts[idx + 1] : lines.length;
      final blockLines = lines.sublist(start, end).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (blockLines.isEmpty) continue;
      // parse header
      final headerMatch = qRegex.firstMatch(blockLines[0]);
      final number = headerMatch != null ? int.tryParse(headerMatch.group(2) ?? '') ?? (out.length + 1) : (out.length + 1);
      String qText = headerMatch != null ? (headerMatch.group(3) ?? '') : blockLines[0];
      // try to extract point and related material from header parentheses
      int point = 10;
      String? inferredRelated;
      final parenMatches = RegExp(r'\(([^)]*)\)').allMatches(qText).map((m) => m.group(1)?.trim() ?? '').where((s) => s.isNotEmpty).toList();
      if (parenMatches.isNotEmpty) {
        for (final pm in parenMatches) {
          final lower = pm.toLowerCase();
          final numMatch = RegExp(r'\b(5|10|15|20)\b').firstMatch(pm);
          if (numMatch != null) {
            point = int.parse(numMatch.group(1)!);
          } else if (lower.contains('point') || lower.contains('points')) {
            final nm = RegExp(r'(\d+)').firstMatch(pm);
            if (nm != null) point = int.parse(nm.group(1)!);
          } else {
            // treat as related material title if not numeric
            inferredRelated = pm;
          }
        }
        // remove parentheses from question text
        qText = qText.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      } else {
        final pMatch = RegExp(r'\b(5|10|15|20)\b').firstMatch(blockLines.join(' '));
        if (pMatch != null) point = int.parse(pMatch.group(1)!);
      }

      // detect related material in block
      String? fkMatId;
      // helper: normalize and fuzzy match
      final prov = Provider.of<QuizProvider>(context, listen: false);
      String normalizeTitle(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
      String? findMaterialIdByTitle(String title) {
        final needle = normalizeTitle(title);
        // search persisted first (exact normalized)
        for (final m in prov.materials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.isEmpty) continue;
          if (n == needle) return m['id_material']?.toString();
        }
        // try contains match
        for (final m in prov.materials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.contains(needle) || needle.contains(n)) return m['id_material']?.toString();
        }
        // try local materials by tmp_id
        for (final m in _localMaterials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n == needle) return m['tmp_id']?.toString();
        }
        for (final m in _localMaterials) {
          final mt = (m['title']?.toString() ?? '');
          final n = normalizeTitle(mt);
          if (n.contains(needle) || needle.contains(n)) return m['tmp_id']?.toString();
        }
        return null;
      }

      for (final l in blockLines) {
        final rm = RegExp(r'Related\s*Material\s*[:\-]?\s*(.*)', caseSensitive: false).firstMatch(l);
        if (rm != null && (rm.group(1)?.trim().isNotEmpty ?? false)) {
          final matTitle = rm.group(1)!.trim();
          fkMatId = findMaterialIdByTitle(matTitle);
          if (fkMatId != null) break;
        }
      }

      // detect choices
      final choices = <Map<String, dynamic>>[];
      final choiceLineRegexes = [RegExp(r'^[A-Da-d]\s*[\.|\)]\s*(.*)'), RegExp(r'^\d+\)\s*(.*)'), RegExp(r'^[-\*]\s*(.*)')];
      for (int i = 1; i < blockLines.length; i++) {
        final l = blockLines[i];
        bool matched = false;
        for (final cre in choiceLineRegexes) {
          final m = cre.firstMatch(l);
          if (m != null) {
            var content = m.group(1) ?? '';
            var isCorrect = false;
            // detect (Correct) marker and remove it from content
            if (content.toLowerCase().contains('(correct)') || l.toLowerCase().contains('(correct)') || content.toLowerCase().contains('correct)')) {
              isCorrect = true;
            }
            content = content.replaceAll(RegExp(r'\(correct\)', caseSensitive: false), '').trim();
            // remove trailing dot
            if (content.endsWith('.')) content = content.substring(0, content.length - 1).trim();
            choices.add({'id': 'tmp_${out.length}_${i}_${DateTime.now().millisecondsSinceEpoch}', 'content': content, 'isCorrect': isCorrect});
            matched = true;
            break;
          }
        }
        if (!matched) {
          // inline choices like 'Choices: a) x; b) y; c) z'
          final inline = RegExp(r'Choices?\s*[:\-]?\s*(.*)', caseSensitive: false).firstMatch(l);
          if (inline != null && (inline.group(1)?.isNotEmpty ?? false)) {
            final parts = inline.group(1)!.split(RegExp(r'[;\\|/]'));
            for (final p in parts) {
              var cleaned = p.trim();
              if (cleaned.isNotEmpty) {
                final isCorrect = cleaned.toLowerCase().contains('(correct)');
                cleaned = cleaned.replaceAll(RegExp(r'\(correct\)', caseSensitive: false), '').trim();
                if (cleaned.endsWith('.')) cleaned = cleaned.substring(0, cleaned.length - 1).trim();
                choices.add({'id': 'tmp_${out.length}_${i}_${DateTime.now().millisecondsSinceEpoch}', 'content': cleaned, 'isCorrect': isCorrect});
              }
            }
          }
        }
      }

      // If no choices found, try to extract from question line (split by ';')
      if (choices.isEmpty) {
        final inlineChoices = qText.split(RegExp(r';|/|\|'));
        if (inlineChoices.length > 1) {
          for (final ic in inlineChoices.skip(1)) {
            final cleaned = ic.trim();
            if (cleaned.isNotEmpty) choices.add({'id': 'tmp_inline_${DateTime.now().millisecondsSinceEpoch}', 'content': cleaned, 'isCorrect': false});
          }
          // remove inline options from qText
          qText = inlineChoices.first.trim();
        }
      }

      // fallback ensure at least 3 choices
      while (choices.length < 3) {
        choices.add({'id': 'tmp_auto_${DateTime.now().millisecondsSinceEpoch}', 'content': 'Option', 'isCorrect': false});
      }

      // if inferredRelated exists and fkMatId not found, try to match it using same helper
      if (fkMatId == null && inferredRelated != null && inferredRelated.isNotEmpty) {
        fkMatId = findMaterialIdByTitle(inferredRelated);
      }

      final Map<String, dynamic> qMap = {
        'idQuestion': 'tmp_${out.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
        'number': number,
        'question': qText,
        'poin': point,
        'fkIdMaterial': fkMatId,
        'answerChoices': choices,
      };
      out.add(_mapToQuestion(qMap));
    }

    return out;
  }

  Question _mapToQuestion(Map<String, dynamic> m) {
    final fkQuiz = _quizId?.toString() ?? 'new_quiz';
    final createAt = DateTime.now();
    final choices = <AnswerQuestion>[];
    for (final c in (m['answerChoices'] as List<dynamic>)) {
      choices.add(AnswerQuestion(
        idAnswerChoice: c['id']?.toString() ?? 'tmp_choice',
        content: c['content']?.toString() ?? '',
        isCorrect: c['isCorrect'] == true,
        createAt: createAt,
        updateAt: createAt,
      ));
    }
    return Question(
      idQuestion: m['idQuestion']?.toString() ?? 'tmp',
      number: m['number'] ?? (DateTime.now().millisecondsSinceEpoch % 1000),
      question: m['question']?.toString() ?? '',
      poin: m['poin'] ?? 10,
      fkIdQuiz: fkQuiz,
      fkIdMaterial: m['fkIdMaterial']?.toString(),
      answerChoices: choices,
      createAt: createAt,
      updateAt: createAt,
    );
  }
}