import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_decorations.dart';

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
  final List<TextEditingController> _choiceControllers = [TextEditingController()];
  final List<bool> _isCorrectList = [false];
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableNumbers = getAvailableNumbers();
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
                            value: _selectedNumber,
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
                        items: materialsList.map((m) {
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
                    onPressed: _submitQuestion,
                    child: Text("Add Question", style: AppTextStyles.labelLg(context)),
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
