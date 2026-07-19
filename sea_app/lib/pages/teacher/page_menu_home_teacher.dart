import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../theme/app_colors.dart';
import '../../component/nav/bottom_navigation.dart';
import '../../component/header/top.dart';
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
import '../../component/window/window_view_list_class.dart';
import '../../component/window/window_view_list_discussion.dart';
import 'page_menu_discussion_details_teacher.dart';
import '../../component/state/skeleton_loading.dart';
import '../../component/animated_quote.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import '../../component/ui/staggered_slide_up.dart';
import '../../utils/app_notification.dart';

class MenuHomeTeacher extends StatefulWidget {
  const MenuHomeTeacher({super.key});

  @override
  State<MenuHomeTeacher> createState() => _MenuHomeTeacherState();
}

class _MenuHomeTeacherState extends State<MenuHomeTeacher> {
  int _currentIndex = 2;
  late final PageController _pageController;

  static const List<String> _titles = [
    "Discussion Room",
    "Quiz",
    "Home",
    "Panduan",
    "Setelan",
  ];

  static const List<String> _subtitles = [
    "Ruang diskusi kelas",
    "Buat & kelola kuis",
    "Kelola kelas & diskusi",
    "Cara menggunakan aplikasi",
    "Preferensi & konfigurasi",
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

  Widget _buildTabWrapper(int index, Widget child) {
    return Column(
      children: [
        TopHeader(
          title: _titles[index],
          subtitle: _subtitles[index],
          accentColor: AppColors.teacherAccent,
        ),
        Expanded(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            _buildTabWrapper(0, PageMenuDiscussionTeacher()),
            _buildTabWrapper(1, PageMenuQuizTeacher()),
            _HomeTeacherContent(),
            _buildTabWrapper(3, const PageGuide()),
            _buildTabWrapper(4, const PageSettings()),
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
  String _classSortType = 'terbaru';
  String _discussionSortType = 'terbaru';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String userName = auth.user?.name ?? "Teacher";

    final teacherQuotes = [
      "Belajar mengajar hari ini",
      "Guru adalah cahaya ilmu",
      "Mendidik dengan hati dan karya",
      "Bersama mencerdaskan generasi",
      "Ilmu yang dibagi takkan pernah habis",
    ];

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
                          const Icon(PhosphorIconsRegular.quotes, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: AnimatedQuote(
                              quotes: teacherQuotes,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Row Statistik berupa Kartu Putih Horizontal Melayang — HIERARCHY (angka besar)
              Positioned(
                bottom: -70,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    // Card 1: Kelas Diajar
                    Expanded(
                      child: _StatCard(
                        icon: PhosphorIconsRegular.graduationCap,
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
                        icon: PhosphorIconsFill.chatsCircle,
                        iconColor: const Color(0xFF8B5CF6),
                        value: "${_discussions.where((d) => d.status == 'open').length}",
                        label: "Diskusi Aktif",
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 90), // Jarak aman setelah Stack melayang

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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => WindowViewListClass(
                        classes: _classes,
                        isTeacher: true,
                      ),
                    );
                  },
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
                      Icon(PhosphorIconsRegular.caretRight, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Filter Chips Kelas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildSortChip(
                  context,
                  label: "Terbaru",
                  isSelected: _classSortType == 'terbaru',
                  onTap: () => setState(() => _classSortType = 'terbaru'),
                  isDark: isDark,
                  accentColor: AppColors.teacherAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "Abjad A-Z",
                  isSelected: _classSortType == 'abjad',
                  onTap: () => setState(() => _classSortType = 'abjad'),
                  isDark: isDark,
                  accentColor: AppColors.teacherAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Horizontal list kelas / Empty state border putus-putus
          _classes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEmptyClassCard(context),
                )
              : () {
                  final sortedClasses = List<ClassModel>.from(_classes);
                  if (_classSortType == 'abjad') {
                    sortedClasses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  } else {
                    sortedClasses.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                  }
                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedClasses.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == sortedClasses.length) {
                          return _buildAddClassCard(context, isDark);
                        }
                        final c = sortedClasses[idx];
                        return _buildClassHorizontalCard(context, c, isDark);
                      },
                    ),
                  );
                }(),
          const SizedBox(height: 12),

          // ── KONTEN BAWAH (DISKUSI & DISCUSSION ACTIONS) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
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
                      "Ruang Diskusi Saat Ini",
                      style: AppTextStyles.titleMd(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => WindowViewListDiscussion(
                        discussions: _discussions,
                        isTeacher: true,
                        onTap: (d) {
                          if (d.status == 'closed') {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
                          }
                        },
                      ),
                    );
                  },
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
                      Icon(PhosphorIconsRegular.caretRight, size: 16, color: Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildSortChip(
                  context,
                  label: "Terbaru",
                  isSelected: _discussionSortType == 'terbaru',
                  onTap: () => setState(() => _discussionSortType = 'terbaru'),
                  isDark: isDark,
                  accentColor: AppColors.teacherAccent,
                ),
                const SizedBox(width: 8),
                _buildSortChip(
                  context,
                  label: "Abjad A-Z",
                  isSelected: _discussionSortType == 'abjad',
                  onTap: () => setState(() => _discussionSortType = 'abjad'),
                  isDark: isDark,
                  accentColor: AppColors.teacherAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal scroll discussions
          () {
            final sortedDiscussions = List<DiscussionRoom>.from(_discussions);
            if (_discussionSortType == 'abjad') {
              sortedDiscussions.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
            } else {
              sortedDiscussions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }

            return sortedDiscussions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.card(context),
                      child: Center(
                        child: Text(
                          "Belum ada ruang diskusi tersedia",
                          style: AppTextStyles.bodySm(context),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedDiscussions.length + 1,
                      itemBuilder: (context, idx) {
                        if (idx == sortedDiscussions.length) {
                          return _buildAddDiscussionCard(context, isDark, isTeacher: true);
                        }
                        final d = sortedDiscussions[idx];
                        return StaggeredSlideUp(
                          index: idx,
                          child: _buildDiscussionHorizontalCard(context, d, isDark, isTeacher: true),
                        );
                      },
                    ),
                  );
          }(),
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
                  PhosphorIconsRegular.bookOpenText,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: c.codeClass));
                  AppNotification.show(
                    context,
                    "Kode kelas '${c.codeClass}' berhasil disalin!",
                    isError: false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.codeClass,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIconsRegular.copy,
                        size: 10,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                    ],
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
                    PhosphorIconsRegular.calendar,
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

  Widget _buildAddClassCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _createClassDialog(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.plus,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Buat",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDiscussionCard(BuildContext context, bool isDark, {required bool isTeacher}) {
    final accentColor = isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PageMenuDiscussionEditorTeacher()),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.plus,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Buat",
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
                  PhosphorIconsRegular.plus,
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



  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? accentColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionHorizontalCard(BuildContext context, DiscussionRoom d, bool isDark, {required bool isTeacher}) {
    final isOpen = d.status == 'open';
    final accentColor = isTeacher ? AppColors.teacherAccent : AppColors.studentAccent;

    return GestureDetector(
      onTap: () {
        if (isTeacher) {
          if (isOpen) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionEditorTeacher(discussionId: d.idDiscussionRoom)));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageMenuDiscussionDetailsTeacher(discussionId: d.idDiscussionRoom)));
          }
        }
      },
      child: Container(
        width: 240,
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
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.chatsCircle,
                    color: accentColor,
                    size: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOpen ? "AKTIF" : "SELESAI",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isOpen ? const Color(0xFF10B981) : Colors.red,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    d.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.description.isNotEmpty == true ? d.description : "Tidak ada deskripsi",
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
