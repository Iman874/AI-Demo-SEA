import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/summary_discussion.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';

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
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? "");
  }

  void _saveSummary() {
    if (_controller.text.trim().isEmpty) return;

    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(PhosphorIconsRegular.warning, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text('Konfirmasi Penutupan'),
          ],
        ),
        content: const Text('Ruang diskusi akan otomatis ditutup untuk Anda setelah ringkasan ini disimpan. Apakah Anda ingin melanjutkan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.studentAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;

      setState(() => _loading = true);

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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan ringkasan.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan ringkasan.')),
        );
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.fileText, size: 14, color: AppColors.studentAccent),
                        const SizedBox(width: 6),
                        Text(
                          "Isi Ringkasan Diskusi",
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
                      controller: _controller,
                      maxLines: 6,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: "Tulis hasil kesimpulan atau ringkasan diskusi Anda di sini...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(16),
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
                          borderSide: const BorderSide(color: AppColors.studentAccent, width: 1.5),
                        ),
                      ),
                    ),
                  ],
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
    final titleText = widget.initialContent == null ? "Simpan Ringkasan" : "Edit Ringkasan";

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
              color: AppColors.studentAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsRegular.sparkle,
              color: AppColors.studentAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Simpan ringkasan belajar hasil diskusi kelompok',
                  style: TextStyle(
                    color: Colors.grey,
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
              label: 'Simpan Kesimpulan',
              icon: PhosphorIconsRegular.check,
              isLoading: _loading,
              gradientColors: AppColors.studentGradient,
              onPressed: _loading ? null : _saveSummary,
            ),
          ),
        ],
      ),
    );
  }
}
