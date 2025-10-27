import 'package:flutter/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class WindowAddClass extends StatefulWidget {
  final void Function(ClassModel) onAdd;

  const WindowAddClass({super.key, required this.onAdd});

  @override
  State<WindowAddClass> createState() => _WindowAddClassState();
}

class _WindowAddClassState extends State<WindowAddClass> {
  final TextEditingController _nameController = TextEditingController();

  void _addClass() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {});
    final payload = {
      'name': name,
      'description': '',
      'semester': '1',
      // 'created_by' could be provided from auth context; using 1 as fallback
      'created_by': 1,
    };
    try {
      final resp = await ApiService.createClass(payload);
      if (resp.statusCode == 201) {
    final body = jsonDecode(resp.body);
    final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
    final created = ClassModelJson.fromJson(data);
    if (!mounted) return;
    widget.onAdd(created);
    Navigator.of(context).pop();
    return;
      }
    } catch (e) {
      // ignore for now
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create class')));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Name Class",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Name of class",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF437057),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _addClass,
                child: const Text(
                  "Add Class",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
