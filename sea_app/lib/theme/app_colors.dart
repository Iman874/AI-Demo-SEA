import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary (Teacher) — Electric Indigo ──
  static const Color primary = Color(0xFF2563EB);        // Royal blue vivid
  static const Color primaryLight = Color(0xFF60A5FA);   // sky-400 untuk dark mode
  static const Color primaryDark = Color(0xFF1D4ED8);    // blue-700

  // ── Secondary (Student) — Coral Amber ──
  static const Color secondary = Color(0xFFF97316);      // orange-500 vivid
  static const Color secondaryLight = Color(0xFFFB923C); // orange-400
  static const Color secondaryDark = Color(0xFFEA580C);  // orange-600

  // ── Status ──
  static const Color success = Color(0xFF10B981);  // emerald-500
  static const Color error = Color(0xFFEF4444);    // red-500
  static const Color warning = Color(0xFFF59E0B);  // amber-500
  static const Color info = Color(0xFF3B82F6);     // blue-500

  // ── Role accent ──
  static const Color teacherAccent = primary;
  static const Color studentAccent = secondary;

  // ── Gradient stops ──
  /// Gradient teacher (dari-ke)
  static const List<Color> teacherGradient = [Color(0xFF2563EB), Color(0xFF1D4ED8)];
  /// Gradient student (dari-ke)
  static const List<Color> studentGradient = [Color(0xFFF97316), Color(0xFFEA580C)];
  /// Gradient aksen header bar vertical
  static const List<Color> accentBarTeacher = [Color(0xFF60A5FA), Color(0xFF2563EB)];
  static const List<Color> accentBarStudent = [Color(0xFFFB923C), Color(0xFFF97316)];

  // ── Surface (light) — warm-neutral ──
  static const Color backgroundLight = Color(0xFFF4F6FB);
  static const Color surfaceLight    = Color(0xFFFFFFFF);
  static const Color borderLight     = Color(0xFFE2E8F2);
  static const Color textPrimaryLight    = Color(0xFF0F172A);  // slate-900
  static const Color textSecondaryLight  = Color(0xFF64748B);  // slate-500
  static const Color scaffoldLight   = Color(0xFFF4F6FB);

  // ── Surface (dark) — deep navy ──
  static const Color backgroundDark  = Color(0xFF080C14);  // very deep navy
  static const Color surfaceDark     = Color(0xFF111827);  // gray-900
  static const Color borderDark      = Color(0xFF1F2D40);
  static const Color textPrimaryDark    = Color(0xFFE2E8F2);  // slate-200
  static const Color textSecondaryDark  = Color(0xFF94A3B8);  // slate-400
  static const Color scaffoldDark    = Color(0xFF080C14);

  // ── Common ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Helper methods ──
  static Color background(Brightness b) =>
      b == Brightness.dark ? backgroundDark : backgroundLight;

  static Color surface(Brightness b) =>
      b == Brightness.dark ? surfaceDark : surfaceLight;

  static Color border(Brightness b) =>
      b == Brightness.dark ? borderDark : borderLight;

  static Color textPrimary(Brightness b) =>
      b == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(Brightness b) =>
      b == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  /// Adaptif berdasarkan brightness context
  static Color forBrightness(BuildContext context, Color light, Color dark) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
