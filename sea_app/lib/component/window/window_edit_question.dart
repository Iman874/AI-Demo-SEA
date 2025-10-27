import 'package:flutter/material.dart';
import '../../utils/app_logger.dart';
import '../../models/question.dart';
import '../../models/answer_question.dart';
import '../../models/material.dart';

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
    // Jangan duplikat value, pastikan value hanya satu kali
    final allNums = List.generate(50, (i) => i + 1);
    final available = allNums.where((n) => !usedNumbers.contains(n)).toList();
    // Pastikan nomor yang sedang diedit tetap ada di daftar
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
    // Pastikan value ada di daftar items
    final dropdownNumber = availableNumbers.contains(_selectedNumber)
        ? _selectedNumber
        : availableNumbers.isNotEmpty ? availableNumbers.first : null;
  final List<MaterialPdf> materials = widget.materials ?? [];

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
                        items: materials.map((m) {
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
                    onPressed: _saveQuestion,
                    child: const Text(
                      "Save Question",
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
