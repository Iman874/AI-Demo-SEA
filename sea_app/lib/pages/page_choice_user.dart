import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'page_login_user.dart' as login;
import '../theme/app_colors.dart';

typedef UserType = login.UserType;

class ChoiceUserPage extends StatefulWidget {
  const ChoiceUserPage({super.key});

  @override
  State<ChoiceUserPage> createState() => _ChoiceUserPageState();
}

class _ChoiceUserPageState extends State<ChoiceUserPage> {
  void _navigateToLogin(UserType userType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => login.LoginUserPage(userType: userType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Header Aplikasi Logo PNG Asli
              Image.asset(
                'assets/logo.png',
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                "Selamat Datang di SEA App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Sistem pembelajaran cerdas berbasis AI untuk mengoptimalkan proses belajar mengajar.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Pilihan Role Siswa
              _buildRoleCard(
                title: "Saya Sebagai Siswa",
                description: "Masuk ke portal pembelajaran interaktif, berdiskusi dengan AI, dan kerjakan kuis mandiri.",
                gradient: AppColors.studentGradient,
                iconData: PhosphorIconsRegular.graduationCap,
                onTap: () => _navigateToLogin(login.UserType.student),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Pilihan Role Guru
              _buildRoleCard(
                title: "Saya Sebagai Guru",
                description: "Kelola kelas terdaftar, buat kuis interaktif, unggah materi belajar, dan pantau pemahaman murid.",
                gradient: AppColors.teacherGradient,
                iconData: PhosphorIconsRegular.chalkboardTeacher,
                onTap: () => _navigateToLogin(login.UserType.teacher),
                isDark: isDark,
              ),

              const Spacer(flex: 2),
              Text(
                "Smart Education Assistant • Universitas Negeri Padang",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required List<Color> gradient,
    required IconData iconData,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Arrow indicator
            Icon(
              PhosphorIconsRegular.caretRight,
              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
