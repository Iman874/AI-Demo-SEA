import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../models/class.dart';
import '../../theme/app_colors.dart';
import '../../component/ui/staggered_slide_up.dart';
import '../../utils/app_notification.dart';

class WindowViewListClass extends StatefulWidget {
  final List<ClassModel> classes;
  final bool isTeacher;

  const WindowViewListClass({
    super.key,
    required this.classes,
    required this.isTeacher,
  });

  @override
  State<WindowViewListClass> createState() => _WindowViewListClassState();
}

class _WindowViewListClassState extends State<WindowViewListClass> {
  final TextEditingController _searchController = TextEditingController();
  List<ClassModel> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _filteredClasses = widget.classes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClasses = widget.classes;
      } else {
        _filteredClasses = widget.classes
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.codeClass.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _relativeTime(DateTime dt) {
    try {
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 7) {
        return "${dt.day}/${dt.month}/${dt.year}";
      } else if (diff.inDays >= 1) {
        return "${diff.inDays} hari lalu";
      } else if (diff.inHours >= 1) {
        return "${diff.inHours} jam lalu";
      } else if (diff.inMinutes >= 1) {
        return "${diff.inMinutes} menit lalu";
      } else {
        return "baru saja";
      }
    } catch (_) {
      return "baru saja";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
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
              
              // Kolom Pencarian
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: "Cari kelas berdasarkan nama atau kode...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: Icon(
                              PhosphorIconsRegular.xCircle,
                              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                              size: 18,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Daftar Kelas
              Expanded(
                child: _filteredClasses.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredClasses.length,
                        itemBuilder: (context, idx) {
                          final c = _filteredClasses[idx];
                          final relTime = _relativeTime(c.updatedAt);
                          return StaggeredSlideUp(
                            index: idx,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      PhosphorIconsRegular.graduationCap,
                                      color: accentColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  PhosphorIconsRegular.calendar,
                                                  size: 12,
                                                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  c.semester.isEmpty ? "Semester 1" : "Semester ${c.semester}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  PhosphorIconsRegular.clock,
                                                  size: 12,
                                                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Aktif $relTime",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Salin Kode Kelas
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: c.codeClass));
                                      AppNotification.show(context, "Kode kelas '${c.codeClass}' berhasil disalin!");
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            c.codeClass,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            PhosphorIconsRegular.copy,
                                            size: 12,
                                            color: isDark ? Colors.white38 : const Color(0xFF64748B),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
    final accentColor = widget.isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;

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
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.list,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Semua Kelas',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mencakup total ${widget.classes.length} kelas terdaftar',
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 40,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 12),
            Text(
              "Kelas tidak ditemukan",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Coba masukkan nama atau kode kelas lainnya.",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerActionBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white10 : const Color(0xFF0F172A),
            foregroundColor: isDark ? Colors.white70 : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Tutup',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
