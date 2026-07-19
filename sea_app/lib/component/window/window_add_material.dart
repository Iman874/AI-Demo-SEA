import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context, isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Materi
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.textT, size: 14, color: AppColors.teacherAccent),
                          const SizedBox(width: 6),
                          Text(
                            "Judul Materi",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ],
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
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.teacherAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tipe Format
                      Row(
                        children: [
                          Icon(PhosphorIconsRegular.textAlignLeft, size: 14, color: AppColors.teacherAccent),
                          const SizedBox(width: 6),
                          Text(
                            "Tipe Format",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = 'text'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'text'
                                      ? AppColors.teacherAccent.withValues(alpha: 0.12)
                                      : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedType == 'text'
                                        ? AppColors.teacherAccent
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                                    width: _selectedType == 'text' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.textAlignLeft,
                                      size: 16,
                                      color: _selectedType == 'text' ? AppColors.teacherAccent : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Teks / Artikel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedType == 'text' ? FontWeight.w800 : FontWeight.w600,
                                        color: _selectedType == 'text' ? AppColors.teacherAccent : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = 'pdf'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'pdf'
                                      ? AppColors.teacherAccent.withValues(alpha: 0.12)
                                      : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedType == 'pdf'
                                        ? AppColors.teacherAccent
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                                    width: _selectedType == 'pdf' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.filePdf,
                                      size: 16,
                                      color: _selectedType == 'pdf' ? AppColors.teacherAccent : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dokumen PDF',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: _selectedType == 'pdf' ? FontWeight.w800 : FontWeight.w600,
                                        color: _selectedType == 'pdf' ? AppColors.teacherAccent : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Konten
                      if (_selectedType == 'text') ...[
                        Row(
                          children: [
                            Icon(PhosphorIconsRegular.alignLeft, size: 14, color: AppColors.teacherAccent),
                            const SizedBox(width: 6),
                            Text(
                              "Isi Materi / Deskripsi",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _contentController,
                          maxLines: 5,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: "Tulis atau tempel materi teks di sini...",
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.teacherAccent, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                      if (_selectedType == 'pdf') ...[
                        Row(
                          children: [
                            Icon(PhosphorIconsRegular.filePdf, size: 14, color: AppColors.teacherAccent),
                            const SizedBox(width: 6),
                            Text(
                              "Unggah File PDF",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ],
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
                    ],
                  ),
                ),
              ),
              _footerActionBar(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teacherAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsRegular.filePlus,
              color: AppColors.teacherAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Materi Baru',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload materi PDF atau buat catatan belajar teks',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.x,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerActionBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton.primary(
              label: 'Simpan Materi',
              icon: PhosphorIconsRegular.check,
              isLoading: _loading,
              gradientColors: AppColors.teacherGradient,
              onPressed: _loading ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
