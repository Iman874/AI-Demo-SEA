import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<String> convertPdfToText({String? path, Uint8List? bytes}) async {
  String fullText = "";

  if (path != null && !kIsWeb) {
    // Mobile/desktop: ekstrak dari path file PDF
    final List<int> fileBytes = await File(path).readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: fileBytes);
    fullText = List.generate(document.pages.count, (i) => PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i)).join(' ');
    document.dispose();
  } else if (bytes != null) {
    // Web: ekstrak dari bytes
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    fullText = List.generate(document.pages.count, (i) => PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i)).join(' ');
    document.dispose();
  }

  // Batasi maksimal 2000 kata
  List<String> words = fullText.split(RegExp(r'\s+'));
  if (words.length > 2000) {
    fullText = words.sublist(0, 2000).join(' ');
  }

  return fullText;
}
