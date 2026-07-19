import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Header Modern Minimalis
/// ────────────────────────
/// Menyatu bersih dengan warna latar belakang aplikasi (tidak lagi pakai
/// gradient card penuh) — sapaan personalisasi dinamis, judul halaman,
/// dan avatar inisial dengan tint warna accent lembut di pojok kanan.
///
/// Bahasa desainnya sengaja disamakan dengan BottomNavigation: shadow
/// tipis (bukan berwarna/tebal), aksen warna dipakai secukupnya (avatar
/// tint + titik kecil di subtitle), bukan sebagai background penuh.
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

    // Inisial nama user untuk avatar.
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    // Sapaan dinamis berdasarkan jam lokal.
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour >= 5 && hour < 11) {
      greeting = "Selamat pagi";
    } else if (hour >= 11 && hour < 15) {
      greeting = "Selamat siang";
    } else if (hour >= 15 && hour < 18) {
      greeting = "Selamat sore";
    } else {
      greeting = "Selamat malam";
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary   = isDark ? Colors.white : const Color(0xFF1A2536);
    final textSecondary = isDark ? const Color(0xFF9AA5B4) : const Color(0xFF6B7A8D);
    final isHome = title.toLowerCase() == 'home';
    final bool isStudent = accentColor == AppColors.studentAccent;
    final List<Color> gradientColors = isStudent ? AppColors.studentGradient : AppColors.teacherGradient;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Info teks header ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isHome) ...[
                    Text(
                      "$greeting, $userName",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: AppTextStyles.headline(context).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: textPrimary,
                    ),
                  ),
                  if (!isHome && subtitle != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitle!,
                            style: AppTextStyles.bodySm(context).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: textSecondary,
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
            // ── Aksi tambahan (jika ada) ──
            if (actions != null && actions!.isNotEmpty) ...[
              Row(mainAxisSize: MainAxisSize.min, children: actions!),
              const SizedBox(width: 10),
            ],
            // ── Avatar — tint circle, bukan gradient ──
            // Bahasa desainnya sama seperti halo di active-tab bottom
            // nav: warna accent sebagai tint lembut di background, bukan
            // fill solid/gradient. Shadow tunggal yang tipis, tanpa
            // border putih tebal.
            AnimatedAvatar(
              initial: initial,
              gradientColors: gradientColors,
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar Bulat Beranimasi Pulse Glow & Indikator Status Online
class AnimatedAvatar extends StatefulWidget {
  final String initial;
  final List<Color> gradientColors;

  const AnimatedAvatar({
    super.key,
    required this.initial,
    required this.gradientColors,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Efek Pulse Glow Ring Melingkar di Belakang Avatar
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.gradientColors.first.withValues(
                    alpha: (1.0 - _controller.value) * 0.7,
                  ),
                  width: 1.5 + (_controller.value * 5.0),
                ),
              ),
            );
          },
        ),
        // Kontainer Avatar Utama dengan Gradient & Border Putih
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                widget.initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        // Indikator Status Online Hijau (Cocok seperti Dashboard)
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}