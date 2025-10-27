import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/add_pdf.dart';
import '../../utils/pdf_to_text.dart';

class WindowAddMaterial extends StatefulWidget {
  final String? fkIdQuiz;
  final String? fkIdDiscussionRoom;
  final String? discussionId;
  // When false, the dialog will NOT persist to backend and instead return the material data to caller.
  final bool saveImmediately;
  const WindowAddMaterial({super.key, this.fkIdQuiz, this.fkIdDiscussionRoom, this.discussionId, this.saveImmediately = true});

  @override
  State<WindowAddMaterial> createState() => _WindowAddMaterialState();
}

class _WindowAddMaterialState extends State<WindowAddMaterial> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = 'text';
  String? pdfPath;
  Uint8List? pdfBytes;
  String? pdfFileName;
  bool _loading = false;

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    String contentValue = '';
    if (_selectedType == 'pdf') {
      contentValue = await convertPdfToText(path: pdfPath, bytes: pdfBytes);
    } else {
      contentValue = _contentController.text.trim();
    }

    final payload = {
      'title': _titleController.text.trim(),
      'content': contentValue,
      'type': _selectedType,
      'fk_id_quiz': widget.fkIdQuiz != null ? int.tryParse(widget.fkIdQuiz!) : null,
      'fk_id_discussionroom': widget.discussionId != null ? int.tryParse(widget.discussionId!) : (widget.fkIdDiscussionRoom != null ? int.tryParse(widget.fkIdDiscussionRoom!) : null),
    };

    // If caller requested deferred save, return the material data to the caller instead of persisting now.
    if (!widget.saveImmediately) {
      final Map<String, dynamic> localMaterial = {
        // caller will assign a tmp_id
        'title': payload['title'],
        'content': payload['content'],
        'type': payload['type'],
      };
      if (mounted) Navigator.of(context).pop(localMaterial);
      return;
    }

    try {
      final resp = await ApiService.createMaterial(payload);
      if (resp.statusCode == 201) {
        // We simply return true to indicate success; parent can refresh materials list.
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    } catch (e) {
      // ignore
    }

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save material')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 560,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Material', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Text')),
                  DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              if (_selectedType == 'text')
                TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
              if (_selectedType == 'pdf') ...[
                const SizedBox(height: 8),
                AddPdfWidget(onPdfSelected: (path, bytes, name) {
                  setState(() {
                    pdfPath = path;
                    pdfBytes = bytes;
                    pdfFileName = name;
                  });
                }),
                if (pdfFileName != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Selected: $pdfFileName')),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
