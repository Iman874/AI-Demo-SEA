import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class PageGuide extends StatefulWidget {
  const PageGuide({super.key});

  @override
  State<PageGuide> createState() => _PageGuideState();
}

class _PageGuideState extends State<PageGuide> {
  String _role = 'student';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user != null) {
      _role = user.role.toString().toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final entries = {
      'teacher': [
        {
          'title': 'Buat & Kelola Kelas',
          'desc': 'Buat kelas baru melalui tombol "+ Buat Kelas" di halaman Beranda untuk mengundang siswa belajar bersama.',
          'icon': PhosphorIconsRegular.plus,
        },
        {
          'title': 'Rancang Kuis Interaktif',
          'desc': 'Buat kuis baru di tab Kuis, susun butir-butir pertanyaan pilihan ganda, dan tugaskan ke kelas pilihan Anda.',
          'icon': PhosphorIconsRegular.clipboardText,
        },
        {
          'title': 'Kelompok & Ruang Diskusi',
          'desc': 'Sediakan ruang diskusi kelompok lengkap dengan lampiran materi belajar berupa file PDF.',
          'icon': PhosphorIconsRegular.chatsCircle,
        },
        {
          'title': 'Integrasikan AI Gemini',
          'desc': 'Aktifkan AI ChatRoom pada diskusi agar siswa dapat berkonsultasi secara mandiri dengan asisten AI.',
          'icon': PhosphorIconsRegular.brain,
        },
      ],
      'student': [
        {
          'title': 'Gabung Kelas Baru',
          'desc': 'Masuk ke kelas guru Anda dengan memasukkan kode akses unik di halaman utama ("Gabung Kelas").',
          'icon': PhosphorIconsRegular.userPlus,
        },
        {
          'title': 'Kerjakan Kuis Terjadwal',
          'desc': 'Buka tab Kuis untuk melihat daftar kuis aktif kelas Anda. Mulai kuis dan jawab pertanyaan dengan cermat.',
          'icon': PhosphorIconsRegular.playCircle,
        },
        {
          'title': 'Diskusikan Materi Bersama AI',
          'desc': 'Masuk ke grup diskusi aktif. Gunakan fitur Tanya AI untuk memahami materi belajar secara interaktif.',
          'icon': PhosphorIconsRegular.sparkle,
        },
        {
          'title': 'Ekstraksi & Unduh Materi',
          'desc': 'Pelajari dokumen PDF yang diunggah guru di dalam ruang diskusi sebelum Anda memulai kuis.',
          'icon': PhosphorIconsRegular.filePdf,
        },
      ],
    };

    final list = entries[_role] ?? entries['student']!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Panduan Penggunaan',
                style: AppTextStyles.titleLg(context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pelajari cara maksimal menggunakan Smart Education Assistant.',
                style: AppTextStyles.bodySm(context).copyWith(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Segmented Control (Role Selector)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = 'student'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _role == 'student'
                                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _role == 'student'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Siswa (Student)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _role == 'student'
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _role = 'teacher'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _role == 'teacher'
                                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _role == 'teacher'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Guru (Teacher)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _role == 'teacher'
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Guide Items List
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final item = list[i] as Map<String, dynamic>;
                    final iconData = item['icon'] as IconData;
                    final titleText = item['title'].toString();
                    final descText = item['desc'].toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_role == 'student' ? AppColors.secondary : AppColors.primary)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              iconData,
                              color: _role == 'student' ? AppColors.secondary : AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
