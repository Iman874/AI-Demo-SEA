import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';
import '../../theme/app_text_styles.dart';
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
    final availableNumbers = getAvailableNumbers();
    final dropdownNumber = availableNumbers.contains(_selectedNumber)
        ? _selectedNumber
        : availableNumbers.isNotEmpty ? availableNumbers.first : null;
  final List<MaterialPdf> materials = widget.materials ?? [];
  final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDecorations.borderRadiusLg),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question Number", style: AppTextStyles.labelMd(context)),
                          DropdownButton<int>(
                            value: dropdownNumber,
                            isExpanded: true,
                            items: availableNumbers.map((n) {
                              return DropdownMenuItem(value: n, child: Text(n.toString()));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedNumber = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.wLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question Poin", style: AppTextStyles.labelMd(context)),
                          DropdownButton<int>(
                            value: _selectedPoin,
                            isExpanded: true,
                            items: _poinOptions.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p.toString()));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPoin = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.hMd,
                Text("Related Materials", style: AppTextStyles.labelMd(context)),
                AppSpacing.hXs,
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppDecorations.borderRadiusSm,
                    boxShadow: AppDecorations.shadowSm(Theme.of(context).brightness),
                  ),
                  child: Padding(
                    padding: AppSpacing.horzLg,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMaterialId,
                        isExpanded: true,
                        borderRadius: AppDecorations.borderRadiusSm,
                        hint: Text("Select related material", style: AppTextStyles.bodySm(context)),
                        items: materials.map((m) {
                          return DropdownMenuItem(value: m.id, child: Text(m.title));
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedMaterialId = val);
                        },
                      ),
                    ),
                  ),
                ),
                AppSpacing.hMd,
                Text("Question", style: AppTextStyles.labelMd(context)),
                AppSpacing.hXs,
                TextField(
                  controller: _questionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Type your question here",
                  ),
                ),
                AppSpacing.hMd,
                Text("Question Choices", style: AppTextStyles.labelMd(context)),
                AppSpacing.hXs,
                Column(
                  children: List.generate(_choiceControllers.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _choiceControllers[i],
                              decoration: InputDecoration(
                                hintText: "Choice",
                              ),
                            ),
                          ),
                          AppSpacing.wSm,
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Correct", style: AppTextStyles.labelMd(context)),
                                Checkbox(
                                  value: _isCorrectList[i],
                                  onChanged: (val) {
                                    if (val == true) _setCorrect(i);
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_choiceControllers.length > 1)
                            IconButton(
                              icon: Icon(Icons.close, color: cs.error, size: 18),
                              onPressed: () => _removeChoiceField(i),
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
                    icon: const Icon(Icons.add, size: 28),
                    label: const Text("Add Choice"),
                  ),
                ),
                AppSpacing.hLg,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveQuestion,
                    child: Text("Save Question", style: AppTextStyles.labelLg(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
