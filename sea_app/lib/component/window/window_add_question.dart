import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';

class WindowAddQuestion extends StatefulWidget {
  final int nextNumber;
  final String fkIdQuiz;
  final void Function(Question) onAdd;
  final List<Question>? existingQuestions;
  final List<MaterialPdf>? materials;

  const WindowAddQuestion({
    super.key,
    required this.nextNumber,
    required this.fkIdQuiz,
    required this.onAdd,
    this.existingQuestions,
    this.materials,
  });

  @override
  State<WindowAddQuestion> createState() => _WindowAddQuestionState();
}

class _WindowAddQuestionState extends State<WindowAddQuestion> {
  int _selectedNumber = 1;
  int _selectedPoin = 10;
  final List<int> _poinOptions = [5, 10, 15, 20];
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _choiceControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<bool> _isCorrectList = [true, false];
  String? _selectedMaterialId;

  List<MaterialPdf> get materialsList => widget.materials ?? [];

  List<int> getAvailableNumbers() {
    final usedNumbers = widget.existingQuestions?.map((q) => q.number).toSet() ?? {};
    if (usedNumbers.isEmpty) return [1];
    final maxNum = usedNumbers.isEmpty ? 1 : usedNumbers.length + 1;
    final allNums = List.generate(maxNum + 10, (i) => i + 1);
    return allNums.where((n) => !usedNumbers.contains(n)).toList();
  }

  @override
  void initState() {
    super.initState();
    final availableNumbers = getAvailableNumbers();
    _selectedNumber = availableNumbers.isNotEmpty ? availableNumbers.first : 1;
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
      // Ensure at least one choice is marked correct if possible
      if (!_isCorrectList.contains(true) && _isCorrectList.isNotEmpty) {
        _isCorrectList[0] = true;
      }
    });
  }

  void _setCorrect(int idx) {
    setState(() {
      for (int i = 0; i < _isCorrectList.length; i++) {
        _isCorrectList[i] = i == idx;
      }
    });
  }

  void _submitQuestion() {
    final questionText = _questionController.text.trim();
    final choices = <AnswerQuestion>[];
    for (int i = 0; i < _choiceControllers.length; i++) {
      final text = _choiceControllers[i].text.trim();
      if (text.isNotEmpty) {
        choices.add(
          AnswerQuestion(
            idAnswerChoice: UniqueKey().toString(),
            content: text,
            isCorrect: _isCorrectList[i],
            createAt: DateTime.now(),
            updateAt: DateTime.now(),
          ),
        );
      }
    }
    if (questionText.isEmpty || choices.isEmpty) return;
    final question = Question(
      idQuestion: UniqueKey().toString(),
      number: _selectedNumber,
      question: questionText,
      poin: _selectedPoin,
      fkIdQuiz: widget.fkIdQuiz,
      fkIdMaterial: _selectedMaterialId,
      answerChoices: choices,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    );
    widget.onAdd(question);
    AppLogger.i('Added question #${question.number}');
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
          maxWidth: 540,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context, isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Nomor Soal & Poin Chips
                      _numberAndPoinSection(context, availableNumbers, isDark),
                      const SizedBox(height: 20),

                      // Section 2: Teks Pertanyaan
                      _questionField(context, isDark),
                      const SizedBox(height: 20),

                      // Section 3: Materi Terkait (Optional)
                      if (materialsList.isNotEmpty) ...[
                        _materialDropdown(context, isDark),
                        const SizedBox(height: 20),
                      ],

                      // Section 4: Pilihan Jawaban
                      _choicesSection(context, isDark),
                    ],
                  ),
                ),
              ),
              _footerActionBar(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teacherAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsRegular.notePencil,
              color: AppColors.teacherAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Soal Kuis',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Susun butir pertanyaan dan tentukan kunci jawaban',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.x,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberAndPoinSection(BuildContext context, List<int> availableNumbers, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Nomor Soal Dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.hash, size: 14, color: AppColors.teacherAccent),
                      const SizedBox(width: 6),
                      Text(
                        'Nomor Soal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedNumber,
                        isExpanded: true,
                        icon: Icon(
                          PhosphorIconsRegular.caretDown,
                          size: 16,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        items: availableNumbers
                            .map(
                              (n) => DropdownMenuItem(
                                value: n,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.teacherAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '#$n',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.teacherAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Soal No. $n',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedNumber = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Poin Chips Selector
        Row(
          children: [
            Icon(PhosphorIconsFill.star, size: 14, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            Text(
              'Bobot Poin',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _poinOptions.map((poin) {
            final isSelected = _selectedPoin == poin;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPoin = poin),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.teacherAccent.withValues(alpha: 0.25) : AppColors.teacherAccent.withValues(alpha: 0.12))
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.teacherAccent
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$poin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? AppColors.teacherAccent
                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'pt',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? AppColors.teacherAccent
                                : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
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
            Icon(PhosphorIconsRegular.chatText, size: 14, color: AppColors.teacherAccent),
            const SizedBox(width: 6),
            Text(
              'Pertanyaan Soal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _questionController,
          maxLines: 4,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Tuliskan butir pertanyaan di sini...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.teacherAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _materialDropdown(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsRegular.filePdf, size: 14, color: AppColors.teacherAccent),
            const SizedBox(width: 6),
            Text(
              'Materi Belajar Terkait (Opsional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMaterialId,
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              hint: Text(
                'Pilih materi referensi...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                ),
              ),
              items: materialsList
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(
                        m.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedMaterialId = val);
              },
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
            Icon(PhosphorIconsRegular.listChecks, size: 14, color: AppColors.teacherAccent),
            const SizedBox(width: 6),
            Text(
              'Pilihan Jawaban',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_choiceControllers.length}/5 Opsi',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tandai lingkaran di kiri sebagai Kunci Jawaban Benar.',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 14),

        // Choice Cards List
        Column(
          children: List.generate(_choiceControllers.length, (i) {
            final isCorrect = _isCorrectList[i];
            final optionLetter = String.fromCharCode(65 + i);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? (isDark ? const Color(0xFF10B981).withValues(alpha: 0.12) : const Color(0xFFECFDF5))
                    : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                  width: isCorrect ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Radio Selector (Kunci Jawaban)
                  GestureDetector(
                    onTap: () => _setCorrect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
                            size: 16,
                            color: isCorrect ? Colors.white : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            optionLetter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isCorrect ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Answer TextField
                  Expanded(
                    child: TextField(
                      controller: _choiceControllers[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Isi pilihan $optionLetter...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Delete Choice Button
                  if (_choiceControllers.length > 1)
                    GestureDetector(
                      onTap: () => _removeChoiceField(i),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsRegular.trash,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // Add Choice Button
        if (_choiceControllers.length < 5)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addChoiceField,
              icon: const Icon(PhosphorIconsRegular.plus, size: 16),
              label: const Text(
                'Tambah Pilihan Jawaban',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teacherAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: AppColors.teacherAccent.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _footerActionBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton.primary(
              label: 'Simpan Soal',
              icon: PhosphorIconsRegular.check,
              gradientColors: AppColors.teacherGradient,
              onPressed: _submitQuestion,
            ),
          ),
        ],
      ),
    );
  }
}
