import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../component/nav/bottom_navigation.dart';
import '../../component/header/top.dart';
import '../../component/card/card_discussion.dart';
import '../../models/class.dart';
import '../../models/discussion_room.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import 'page_menu_discussion_teacher.dart';
import 'page_menu_quiz_teacher.dart';
import '../page_guide.dart';
import '../page_settings.dart';
import 'page_menu_discussion_editor_teacher.dart';
import '../../component/window/window_add_class.dart';
import 'page_menu_discussion_details_teacher.dart';
import '../../component/state/skeleton_loading.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';

class MenuHomeTeacher extends StatefulWidget {
  const MenuHomeTeacher({super.key});

  @override
  State<MenuHomeTeacher> createState() => _MenuHomeTeacherState();
}

class _MenuHomeTeacherState extends State<MenuHomeTeacher> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const List<String> _titles = [
    "Home",
    "Discussion Room",
    "Quiz",
    "Panduan",
    "Setelan",
  ];

  static const List<String> _subtitles = [
    "Kelola kelas & diskusi",
    "Ruang diskusi kelas",
    "Buat & kelola kuis",
    "Cara menggunakan aplikasi",
    "Preferensi & konfigurasi",
  ];

  final List<Widget> _pages = [
    _HomeTeacherContent(),
    PageMenuDiscussionTeacher(),
    PageMenuQuizTeacher(),
    const PageGuide(),
    const PageSettings(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex != 0)
              TopHeader(
                title: _titles[_currentIndex],
                subtitle: _subtitles[_currentIndex],
                accentColor: AppColors.teacherAccent,
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        isStudent: false,
      ),
    );
  }
}

class _HomeTeacherContent extends StatefulWidget {
  @override
  State<_HomeTeacherContent> createState() => _HomeTeacherContentState();
}

class _HomeTeacherContentState extends State<_HomeTeacherContent> {
  bool _loading = true;
  String? _error;
  List<ClassModel> _classes = [];
  List<DiscussionRoom> _discussions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final classesResp = await ApiService.getClasses();
      if (classesResp.statusCode == 200) {
        final body = jsonDecode(classesResp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _classes = items.map((e) => ClassModelJson.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load classes (${classesResp.statusCode})');
      }

      final discResp = await ApiService.getDiscussions();
      if (discResp.statusCode == 200) {
        final body = jsonDecode(discResp.body);
        final items = body['data'] as List<dynamic>? ?? [];
        _discussions = items.map((e) => DiscussionRoomJson.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load discussions (${discResp.statusCode})');
      }
    } catch (err) {
      _error = err.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SkeletonHomeContent();
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final active = _discussions.where((d) => d.status == 'open').toList();
    final completed = _discussions.where((d) => d.status == 'closed').toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String userName = auth.user?.name ?? "Teacher";

    // Greeting time based on hour
    final hour = DateTime.now().hour;
    String timeGreeting = "Selamat Hari";
    if (hour >= 5 && hour < 11) {
      timeGreeting = "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      timeGreeting = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      timeGreeting = "Selamat Sore";
    } else {
      timeGreeting = "Selamat Malam";
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── RICH DASHBOARD HEADER (TEACHER) ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 56),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.teacherGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: AppDecorations.shadowGlow(
                    color: AppColors.teacherAccent,
                    opacity: 0.15,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top personalized bar
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$timeGreeting,",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userName.toLowerCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar Gradient + Border Putih + Indikator Online
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.teacherGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0].toUpperCase() : "T",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -1,
                                bottom: -1,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Info aktivitas hari ini
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.today_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Belajar mengajar hari ini",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            "${_classes.length} kelas • ${active.length} diskusi aktif",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Row Statistik berupa Kartu Putih Horizontal Melayang — HIERARCHY (angka besar)
              Positioned(
                bottom: -56,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    // Card 1: Kelas Diajar
                    Expanded(
                      child: _StatCard(
                        icon: Icons.school_rounded,
                        iconColor: const Color(0xFF2563EB),
                        value: "${_classes.length}",
                        label: "Kelas Diajar",
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Card 2: Diskusi Aktif
                    Expanded(
                      child: _StatCard(
                        icon: Icons.forum_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        value: "${active.length}",
                        label: "Diskusi Aktif",
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 72), // Jarak aman setelah Stack melayang

          // ── KELAS TERDAFTAR (DI LUAR HEADER BIRU) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kelas Terdaftar",
                  style: AppTextStyles.titleMd(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        "Lihat semua",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Horizontal list kelas / Empty state border putus-putus
          _classes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmptyClassCard(context),
                )
              : SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _classes.length,
                    itemBuilder: (context, idx) {
                      final c = _classes[idx];
                      return _buildClassHorizontalCard(context, c, isDark);
                    },
                  ),
                ),
          const SizedBox(height: 28),

          // ── KONTEN BAWAH (DISKUSI & DISCUSSION ACTIONS) ──
          _buildContentSectionHeader(context, "Ruang Diskusi Saat Ini", "1", isDark),
          CardDiscussionList(
            discussions: [...active, ...completed],
            onEdit: (d) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
            },
            onDetails: (d) {
              if (d.status == 'closed') {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PageMenuDiscussionEditorTeacher(),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.teacherGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.forum_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Mulai Diskusi Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Buat ruang diskusi sekarang',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER WIDGETS FOR RICH DASHBOARD (TEACHER) ──

  Widget _buildClassHorizontalCard(BuildContext context, ClassModel c, bool isDark) {
    final relTime = _relativeTime(c.updatedAt);
    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              // Kode kelas badge abu neutral (bukan biru)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  c.codeClass,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 10,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      c.semester.isEmpty ? "Semester —" : c.semester,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                "Diperbarui $relTime",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white30 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} mnt lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 30) return "${diff.inDays} hari lalu";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} bln lalu";
    return "${(diff.inDays / 365).floor()} thn lalu";
  }

  Widget _buildEmptyClassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _createClassDialog(context),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomPaint(
          painter: _DottedBorderPainter(
            color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
            radius: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Buat Kelas",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Mulai dengan membuat kelas baru untuk siswamu",
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSectionHeader(BuildContext context, String title, String stepNum, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -10,
                top: -12,
                child: Text(
                  stepNum,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    letterSpacing: -1,
                  ),
                ),
              ),
              Row(
                children: [
                  // Garis aksen vertikal gradient
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.teacherGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: AppTextStyles.titleMd(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createClassDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => WindowAddClass(
        onAdd: (newClass) {
          setState(() {
            _classes.add(newClass);
          });
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon soft (kecil, alpha rendah)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          // Angka BESAR (hierarchy)
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Label kecil
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = Path();
    var distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
