// This window now uses ApiService for network calls. Direct HTTP removed.
import 'package:flutter/material.dart';
import '../../models/summary_discussion.dart';
import '../../services/api_service.dart';

class WindowAddSummary extends StatefulWidget {
  final List<SummaryDiscussion> summaries;
  final String chatRoomId;
  final String userId;
  final String? initialContent;
  const WindowAddSummary({
    super.key,
    required this.summaries,
    required this.chatRoomId,
    required this.userId,
    this.initialContent,
  });

  @override
  State<WindowAddSummary> createState() => _WindowAddSummaryState();
}

class _WindowAddSummaryState extends State<WindowAddSummary> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? "");
  }

  void _saveSummary() {
    if (_controller.text.trim().isEmpty) return;
    // show English warning before submitting
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Your discussion room will be closed for you after submitting the summary.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Proceed')),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;

      // call backend to persist summary and mark completion
      try {
        final resp = await ApiService.submitDiscussionSummary(
          chatroomId: widget.chatRoomId,
          userId: widget.userId,
          content: _controller.text.trim(),
        );
        if (resp.statusCode == 200) {
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          // show failure
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit summary')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit summary')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialContent == null ? "Add Discussion Summary" : "Edit Discussion Summary"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: "Summary Content",
        ),
        maxLines: 5,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveSummary,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
