import 'dart:convert';
import 'package:flutter/material.dart';

import '../../models/discussion_room.dart';
import '../../models/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import '../student/page_menu_discussion_chatroom_student.dart';

class DiscussionDetailStudentPage extends StatefulWidget {
  final DiscussionRoom discussion;
  const DiscussionDetailStudentPage({super.key, required this.discussion});

  @override
  State<DiscussionDetailStudentPage> createState() => _DiscussionDetailStudentPageState();
}

class _DiscussionDetailStudentPageState extends State<DiscussionDetailStudentPage> {
  List<MaterialPdf> materials = [];
  bool _loading = false;
  bool _loadingClass = false;
  bool _loadingMembers = false;
  List<Map<String, dynamic>> _members = [];
  String? _className;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _loadClassName();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final resp = await ApiService.getDiscussionMembers(discussionId: widget.discussion.idDiscussionRoom);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        _members = list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  Future<void> _loadClassName() async {
    setState(() => _loadingClass = true);
    try {
      final resp = await ApiService.getClasses();
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        final classes = list.map((c) => ClassModelJson.fromJson(c as Map<String, dynamic>)).toList();
        final match = classes.firstWhere(
          (c) => (c.idClass == widget.discussion.fkIdClass) || (c.codeClass == widget.discussion.fkIdClass),
          orElse: () => ClassModelJson.fromJson(<String, dynamic>{}),
        );
        _className = (match.idClass.isNotEmpty) ? match.name : null;
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingClass = false);
    }
  }

  Future<void> _loadMaterials() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiService.getMaterialsForDiscussion(discussionId: widget.discussion.idDiscussionRoom);
      if (resp.statusCode == 200) {
        final decoded = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        materials = list.map((m) => MaterialPdfJson.fromJson(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Discussion Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Discussion Room Info', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discussion Room Class'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(child: Text('Class Name: ${_className ?? widget.discussion.fkIdClass}')),
                          if (_loadingClass) const SizedBox(width: 12),
                          if (_loadingClass) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Discussion Room Name'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(widget.discussion.title),
                          const SizedBox(height: 6),
                          Text('Discussion ID: ${widget.discussion.idDiscussionRoom}', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Discussion Members', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  if (_loadingMembers) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())),
                  if (!_loadingMembers && _members.isEmpty)
                    const ListTile(title: Text('No members found')),
                  ..._members.map((m) => ListTile(
                        title: Text(m['name'] ?? 'Unknown'),
                        subtitle: Text(m['email'] ?? ''),
                        trailing: TextButton(onPressed: () {}, child: const Text('View Details')),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Discussion Materials', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading)
              Card(
                child: Column(
                  children: materials.map((m) => ListTile(leading: const Icon(Icons.picture_as_pdf), title: Text(m.title), trailing: TextButton(onPressed: () {}, child: const Text('View Material')))).toList(),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to chatroom (AI) when user taps Ask About Discussion Material
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiscussionPageChatRoomStudent(discussion: widget.discussion)));
                },
                child: const Text('Ask About Discussion Material [AI]'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
