import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/add_pdf.dart';
import '../../utils/pdf_to_text.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../utils/app_notification.dart';

class WindowAddMaterial extends StatefulWidget {
  final String? fkIdQuiz;
  final String? fkIdDiscussionRoom;
  final String? discussionId;
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

    if (!widget.saveImmediately) {
      final Map<String, dynamic> localMaterial = {
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
        if (mounted) {
          AppNotification.show(context, "Materi '${payload['title']}' berhasil ditambahkan!");
          Navigator.of(context).pop(true);
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
      AppNotification.show(context, 'Gagal menyimpan dokumen materi.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Icon(
                  Icons.note_add_rounded,
                  color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Tambah Materi Baru",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Judul
            Text(
              "Judul Materi",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Contoh: Pengenalan Flutter & Dart",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipe
            Text(
              "Tipe Format",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.format_align_left_rounded,
                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                    ),
                  ),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('Teks / Artikel')),
                    DropdownMenuItem(value: 'pdf', child: Text('Dokumen PDF')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Konten
            if (_selectedType == 'text') ...[
              Text(
                "Isi Materi / Deskripsi",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: 4,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "Tulis atau tempel materi teks di sini...",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            if (_selectedType == 'pdf') ...[
              Text(
                "Unggah File PDF",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              AddPdfWidget(onPdfSelected: (path, bytes, name) {
                setState(() {
                  pdfPath = path;
                  pdfBytes = bytes;
                  pdfFileName = name;
                });
              }),
              if (pdfFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Terpilih: $pdfFileName',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),

            // Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Batal",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.primary(
                    label: "Simpan",
                    gradientColors: AppColors.teacherGradient,
                    isLoading: _loading,
                    onPressed: _loading ? null : _save,
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
