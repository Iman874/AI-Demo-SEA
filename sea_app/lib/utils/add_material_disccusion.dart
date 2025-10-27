import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sea_app/utils/add_pdf.dart';
import 'package:sea_app/utils/pdf_to_text.dart'; // import convertPdfToText
import '../models/material.dart';
import '../services/api_service.dart';

class AddMaterialDiscussionPage extends StatefulWidget {
  final List<MaterialPdf> materials;
  const AddMaterialDiscussionPage({super.key, required this.materials});

  @override
  State<AddMaterialDiscussionPage> createState() =>
      _AddMaterialDiscussionPageState();
}

class _AddMaterialDiscussionPageState
    extends State<AddMaterialDiscussionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedType = "text";
  String? pdfPath;
  Uint8List? pdfBytes; // kalau web
  String? pdfFileName;

  Future<void> _addMaterial() async {
    if (_titleController.text.isEmpty) return;

    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String contentValue = "";

    if (_selectedType == "pdf") {
      // ekstrak teks dari PDF
      contentValue = await convertPdfToText(
        path: pdfPath,
        bytes: pdfBytes,
      );
    } else {
      contentValue = _contentController.text;
    }

    // Tutup loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    } else {
      return;
    }

    if (contentValue.isEmpty) return;

    final payload = {
      'title': _titleController.text.trim(),
      'content': contentValue,
      'type': _selectedType,
    };

    try {
      final resp = await ApiService.createMaterial(payload);
      if (resp.statusCode == 201) {
        // parse created data if available
        // we will append a local MaterialPdf representation
        final newMaterial = MaterialPdf(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          content: contentValue,
          type: _selectedType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        setState(() {
          widget.materials.add(newMaterial);
          pdfPath = null;
          pdfBytes = null;
          pdfFileName = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Material '${newMaterial.title}' ditambahkan")),
          );
        }

        _titleController.clear();
        _contentController.clear();

        // kembali ke halaman sebelumnya setelah save
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }
    } catch (e) {
      // ignore
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save material')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Material Discussion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),

            // dropdown type
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: "text", child: Text("Text")),
                DropdownMenuItem(value: "pdf", child: Text("PDF")),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                    _contentController.clear();
                    pdfPath = null;
                    pdfBytes = null;
                    pdfFileName = null;
                  });
                }
              },
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 12),

            // text input jika type = text
            if (_selectedType == "text")
              TextField(
                controller: _contentController,
                decoration:
                    const InputDecoration(labelText: "Content (text only)"),
                maxLines: 3,
              ),

            // add pdf jika type = pdf
            if (_selectedType == "pdf") ...[
              AddPdfWidget(
                onPdfSelected: (path, bytes, fileName) {
                  setState(() {
                    pdfPath = path;
                    pdfBytes = bytes;
                    pdfFileName = fileName;

                    // tampilkan nama/path file yang dipilih
                    _contentController.text =
                        path ?? fileName ?? "PDF Selected";
                  });
                },
              ),
              const SizedBox(height: 8),
              if (pdfPath != null || pdfFileName != null)
                Text(
                  "Selected: ${pdfPath ?? pdfFileName}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMaterial,
              child: const Text("Save Material"),
            ),
            const SizedBox(height: 20),

            // list materi
            const Text("Materials:", style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.materials.length,
                itemBuilder: (context, index) {
                  final mat = widget.materials[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        mat.type == "pdf"
                            ? Icons.picture_as_pdf
                            : Icons.description,
                        color: mat.type == "pdf" ? Colors.red : Colors.blue,
                      ),
                      title: Text(mat.title),
                      subtitle: Text(
                        "Type: ${mat.type} | Content: ${mat.content.substring(0, mat.content.length > 50 ? 50 : mat.content.length)}...",
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
