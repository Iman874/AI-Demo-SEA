import 'package:flutter/material.dart';
import '../../models/class.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/app_button.dart';
import '../../utils/app_notification.dart';
import 'dart:convert';

class WindowAddClass extends StatefulWidget {
  final void Function(ClassModel) onAdd;

  const WindowAddClass({super.key, required this.onAdd});

  @override
  State<WindowAddClass> createState() => _WindowAddClassState();
}

class _WindowAddClassState extends State<WindowAddClass> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;

  void _addClass() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _submitting = true);
    final payload = {
      'name': name,
      'description': '',
      'semester': '1',
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
        AppNotification.show(context, "Kelas '${created.name}' berhasil dibuat!");
        Navigator.of(context).pop();
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _submitting = false);
      AppNotification.show(context, 'Gagal membuat kelas baru.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_business_rounded,
                  color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  "Buat Kelas Baru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Nama Kelas",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "Contoh: Pemrograman Mobile A",
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
                  Icons.school_rounded,
                  color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _submitting
                ? const Center(child: CircularProgressIndicator())
                : Row(
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
                          label: "Buat",
                          gradientColors: AppColors.teacherGradient,
                          onPressed: _addClass,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
