import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';

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

  // List of controllers and isCorrect for each choice field
  final List<TextEditingController> _choiceControllers = [TextEditingController()];
  final List<bool> _isCorrectList = [false];

  String? _selectedMaterialId;

  List<MaterialPdf> get materialsList => widget.materials ?? [];

  List<int> getAvailableNumbers() {
    final usedNumbers = widget.existingQuestions?.map((q) => q.number).toSet() ?? {};
    if (usedNumbers.isEmpty) {
      return [1];
    }
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
  // materialsList getter provided at class scope

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        color: Theme.of(context).cardColor, // background dialog mengikuti theme
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                          const Text("Question Number", style: TextStyle(fontWeight: FontWeight.w600)),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Question Poin", style: TextStyle(fontWeight: FontWeight.w600)),
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
                const SizedBox(height: 12),
                const Text("Related Materials", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor, // dropdown material mengikuti theme
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMaterialId,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(10),
                        hint: const Text(
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                            fontSize: 12
                          ),
                          "Select related material"
                          ),
                        items: materialsList.map((m) {
                          return DropdownMenuItem(
                            value: m.id,
                            child: Text(m.title),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedMaterialId = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Question", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _questionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: "Type your question here",
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Question Choices", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Column(
                  children: List.generate(_choiceControllers.length, (i) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _choiceControllers[i],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              hintText: "Choice",
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Correct", style: TextStyle(fontWeight: FontWeight.w600)),
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
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            onPressed: () => _removeChoiceField(i),
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF306062),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _choiceControllers.length < 5 ? _addChoiceField : null,
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF437057),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _submitQuestion,
                    child: const Text(
                      "Add Question",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
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
  }
}
