import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PageGuide extends StatefulWidget {
  const PageGuide({super.key});

  @override
  State<PageGuide> createState() => _PageGuideState();
}

class _PageGuideState extends State<PageGuide> {
  String _role = 'student';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null) {
      _role = user.role.toString().toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = {
      'teacher': [
        'Create classes using the "Create Class" button on Home.',
        'Create quizzes under the Quiz tab; you can compose questions and save them.',
        'Create discussion rooms with materials and enable the AI ChatRoom to let students ask questions.',
        'When editing a discussion, you can toggle the ChatRoom AI on/off.',
      ],
      'student': [
        'Join classes using a class code from the Home page ("Join with Class Code").',
        'Open the Quiz tab to see quizzes for your classes. Start a quiz to answer questions.',
        'Open the Discussion tab to view and join active discussions. If a discussion has an AI ChatRoom, you can ask the AI about materials.',
        'Materials attached to a discussion can be read before joining the chatroom.',
      ],
    };

    final list = entries[_role] ?? entries['student']!;

    return Scaffold(
      //appBar: AppBar(title: const Text('Application Guide')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Role', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              )),
            const SizedBox(height: 8),
         Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _role,
          isExpanded: true,
          dropdownColor: Colors.white, // warna background menu
          style: const TextStyle(color: Colors.black),
          items: const [
            DropdownMenuItem(value: 'student', child: Text('Student')),
            DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _role = v);
          },
        ),
      ),
    ),
  ),
),

            const SizedBox(height: 16),
            const Text('Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(list[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
