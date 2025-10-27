import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class AddPdfWidget extends StatelessWidget {
  final Function(String? path, Uint8List? bytes, String? fileName) onPdfSelected;

  const AddPdfWidget({super.key, required this.onPdfSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text("Add PDF"),
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          withData: kIsWeb, // ambil bytes jika di web
        );
        if (result != null) {
          if (kIsWeb) {
            // Web: ambil bytes dan nama file
            final bytes = result.files.single.bytes;
            final fileName = result.files.single.name;
            onPdfSelected(null, bytes, fileName);
          } else {
            // Mobile/Desktop: ambil path
            final path = result.files.single.path;
            onPdfSelected(path, null, null);
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}
