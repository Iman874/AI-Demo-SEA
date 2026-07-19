import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

class WindowEditQuestion extends StatefulWidget {
  final Question question;
  final List<Question>? existingQuestions;
  final void Function(Question) onSave;
  final List<MaterialPdf>? materials;

  const WindowEditQuestion({
    super.key,
    required this.question,
    required this.onSave,
    this.existingQuestions,
    this.materials,
  });

  @override
  State<WindowEditQuestion> createState() => _WindowEditQuestionState();
}

class _WindowEditQuestionState extends State<WindowEditQuestion> {
  late int _selectedNumber;
  late int _selectedPoin;
  late TextEditingController _questionController;
  late List<TextEditingController> _choiceControllers;
  late List<bool> _isCorrectList;
  String? _selectedMaterialId;

  final List<int> _poinOptions = [5, 10, 15, 20];

  List<int> getAvailableNumbers() {
    final usedNumbers = widget.existingQuestions?.map((q) => q.number).toSet() ?? {};
    final allNums = List.generate(50, (i) => i + 1);
    final available = allNums.where((n) => !usedNumbers.contains(n)).toList();
    if (!available.contains(widget.question.number)) {
      available.insert(0, widget.question.number);
    }
    return available;
  }

  @override
  void initState() {
    super.initState();
    _selectedNumber = widget.question.number;
    _selectedPoin = widget.question.poin;
    _questionController = TextEditingController(text: widget.question.question);
    _choiceControllers = widget.question.answerChoices
        .map((a) => TextEditingController(text: a.content))
        .toList();
    _isCorrectList = widget.question.answerChoices.map((a) => a.isCorrect).toList();
    _selectedMaterialId = widget.question.fkIdMaterial;
  }

  void _addChoiceField() {
    if (_choiceControllers.length >= 5) return;
    setState(() {
      _choiceControllers.add(TextEditingController());
      _isCorrectList.add(false);
    });
  }

  void _removeChoiceField(int idx) {
    if (_choiceControllers.length <= 1) return;
    setState(() {
      _choiceControllers.removeAt(idx);
      _isCorrectList.removeAt(idx);
    });
  }

  void _setCorrect(int idx) {
    setState(() {
      for (int i = 0; i < _isCorrectList.length; i++) {
        _isCorrectList[i] = i == idx;
      }
    });
  }

  void _saveQuestion() {
    final questionText = _questionController.text.trim();
    final choices = <AnswerQuestion>[];
    for (int i = 0; i < _choiceControllers.length; i++) {
      final text = _choiceControllers[i].text.trim();
      if (text.isNotEmpty) {
        choices.add(
          AnswerQuestion(
            idAnswerChoice: widget.question.answerChoices.length > i
                ? widget.question.answerChoices[i].idAnswerChoice
                : UniqueKey().toString(),
            content: text,
            isCorrect: _isCorrectList[i],
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          ),
        );
      }
    }
    if (questionText.isEmpty || choices.isEmpty) return;
    final updatedQuestion = Question(
      idQuestion: widget.question.idQuestion,
      number: _selectedNumber,
      question: questionText,
      poin: _selectedPoin,
      fkIdQuiz: widget.question.fkIdQuiz,
      fkIdMaterial: _selectedMaterialId,
      answerChoices: choices,
      createAt: widget.question.createAt,
      updateAt: DateTime.now(),
    );
    widget.onSave(updatedQuestion);
    AppLogger.i('Saved edited question #${updatedQuestion.number}');
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (var c in _choiceControllers) {
      c.dispose();
    }
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableNumbers = getAvailableNumbers();
    final dropdownNumber = availableNumbers.contains(_selectedNumber)
        ? _selectedNumber
        : availableNumbers.isNotEmpty ? availableNumbers.first : null;
    final List<MaterialPdf> materials = widget.materials ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDecorations.borderRadiusXl),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2F) : Colors.white,
          borderRadius: AppDecorations.borderRadiusXl,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _numberPoinRow(context, availableNumbers, dropdownNumber, isDark),
                    AppSpacing.hLg,
                    _materialDropdown(context, materials, isDark),
                    AppSpacing.hLg,
                    _questionField(context, isDark),
                    AppSpacing.hLg,
                    _choicesSection(context, isDark),
                    AppSpacing.hLg,
                    _submitButton(context),
                    AppSpacing.hSm,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.teacherGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(PhosphorIconsRegular.pencil, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Soal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ubah soal yang sudah ada',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberPoinRow(BuildContext context, List<int> availableNumbers, int? dropdownNumber, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _styledDropdown<int>(
            label: 'Nomor Soal',
            icon: PhosphorIconsRegular.hash,
            value: dropdownNumber,
            items: availableNumbers.map((n) => DropdownMenuItem(value: n, child: Text(n.toString()))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedNumber = val);
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _styledDropdown<int>(
            label: 'Poin',
            icon: PhosphorIconsFill.star,
            value: _selectedPoin,
            items: _poinOptions.map((p) => DropdownMenuItem(value: p, child: Text(p.toString()))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedPoin = val);
            },
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey.shade500)),
          ],
        ),
        AppSpacing.hXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            borderRadius: AppDecorations.borderRadiusSm,
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              isDense: true,
              borderRadius: AppDecorations.borderRadiusSm,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _materialDropdown(BuildContext context, List<MaterialPdf> materials, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.fileText, size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
            const SizedBox(width: 5),
            Text('Materi Terkait', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey.shade500)),
          ],
        ),
        AppSpacing.hXs,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            borderRadius: AppDecorations.borderRadiusSm,
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMaterialId,
              isExpanded: true,
              isDense: true,
              borderRadius: AppDecorations.borderRadiusSm,
              hint: Text('Pilih materi (opsional)', style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade500)),
              items: materials.map((m) => DropdownMenuItem(value: m.id, child: Text(m.title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)))).toList(),
              onChanged: (val) {
                setState(() => _selectedMaterialId = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.question, size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
            const SizedBox(width: 5),
            Text('Pertanyaan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey.shade500)),
          ],
        ),
        AppSpacing.hXs,
        TextField(
          controller: _questionController,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Tulis pertanyaan di sini...',
            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AppDecorations.borderRadiusSm,
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDecorations.borderRadiusSm,
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDecorations.borderRadiusSm,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _choicesSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.listDashes, size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
            const SizedBox(width: 5),
            Text('Pilihan Jawaban', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white54 : Colors.grey.shade500)),
            const Spacer(),
            Text('${_choiceControllers.length}/5', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade500)),
          ],
        ),
        AppSpacing.hXs,
        Column(
          children: List.generate(_choiceControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _setCorrect(i),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCorrectList[i]
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                        border: Border.all(
                          color: _isCorrectList[i]
                              ? const Color(0xFF10B981)
                              : (isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFCBD5E1)),
                          width: 1.5,
                        ),
                      ),
                      child: _isCorrectList[i]
                          ? const Icon(PhosphorIconsRegular.check, size: 13, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _choiceControllers[i],
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Pilihan ${String.fromCharCode(65 + i)}',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: AppDecorations.borderRadiusSm,
                          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppDecorations.borderRadiusSm,
                          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppDecorations.borderRadiusSm,
                          borderSide: BorderSide(color: _isCorrectList[i] ? const Color(0xFF10B981) : AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  if (_choiceControllers.length > 1)
                    IconButton(
                      icon: Icon(PhosphorIconsRegular.x, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 18),
                      onPressed: () => _removeChoiceField(i),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            );
          }),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _choiceControllers.length < 5 ? _addChoiceField : null,
            icon: const Icon(PhosphorIconsRegular.plus, size: 18),
            label: const Text('Tambah Pilihan', style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _saveQuestion,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.teacherGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.check, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Simpan Perubahan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
