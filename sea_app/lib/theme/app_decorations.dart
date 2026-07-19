import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  // ── Border Radius ──
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusPill => BorderRadius.circular(50);

  // ── Shadows ──
  static List<BoxShadow> shadowSm(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static List<BoxShadow> shadowMd(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : const Color(0xFF0F172A).withValues(alpha: 0.07),
        blurRadius: 18,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static List<BoxShadow> shadowGlow({required Color color, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // ── Card Decorations ──
  static BoxDecoration card(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: borderRadiusLg,
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: shadowSm(b),
    );
  }

  static BoxDecoration elevatedCard(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: borderRadiusXl,
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: shadowMd(b),
    );
  }

  /// Modern Card dengan Tint Aksen Awal
  static BoxDecoration modernAccentCard({
    required BuildContext context,
    required Color accentColor,
  }) {
    final b = Theme.of(context).brightness;
    final isDark = b == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: borderRadiusLg,
      border: Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
        width: 1.5,
      ),
      boxShadow: shadowSm(b),
    );
  }

  /// Card Gradient Modern (Soft/Rich)
  static BoxDecoration gradientCard({
    required BuildContext context,
    required List<Color> colors,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadiusXl,
      boxShadow: shadowGlow(color: colors.first, opacity: 0.3),
    );
  }

  /// Badge / Pill Status Tag Decoration
  static BoxDecoration statusBadge({
    required Color color,
    bool filled = false,
  }) {
    return BoxDecoration(
      color: filled ? color : color.withValues(alpha: 0.12),
      borderRadius: borderRadiusPill,
      border: filled
          ? null
          : Border.all(color: color.withValues(alpha: 0.3), width: 1),
    );
  }
}
