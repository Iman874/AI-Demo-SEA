import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_spacing.dart';

/// Header Modern Minimalis Premium
/// Menyatu bersih dengan warna latar belakang aplikasi, menampilkan sapaan
/// personalisasi dinamis dengan inisial avatar pengguna di pojok kanan.
class TopHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final List<Widget>? actions;

  const TopHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = AppColors.primary,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final userName = user?.name ?? "Pengguna";

    // Dapatkan inisial nama user untuk avatar
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    // Tentukan sapaan dinamis berdasarkan jam lokal
    final hour = DateTime.now().hour;
    String greeting = "Selamat Hari";
    if (hour >= 5 && hour < 11) {
      greeting = "Selamat Pagi";
    } else if (hour >= 11 && hour < 15) {
      greeting = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      greeting = "Selamat Sore";
    } else {
      greeting = "Selamat Malam";
    }

    final bool isStudent = accentColor == AppColors.studentAccent;
    final gradientColors = isStudent ? AppColors.studentGradient : AppColors.teacherGradient;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: AppDecorations.shadowGlow(
          color: accentColor,
          opacity: 0.15,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md + 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Info Teks Header ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sapaan personalisasi jika di halaman utama (Home)
                    if (title.toLowerCase() == 'home') ...[
                      Text(
                        "$greeting, $userName 👋",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      style: AppTextStyles.headline(context).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    if (title.toLowerCase() != 'home' && subtitle != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              subtitle!,
                              style: AppTextStyles.bodySm(context).copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Aksi Tambahan (jika ada) ──
              if (actions != null && actions!.isNotEmpty) ...[
                Row(mainAxisSize: MainAxisSize.min, children: actions!),
                const SizedBox(width: 8),
              ],
              // ── Avatar Profil Gradient + Border Putih + Shadow ──
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
