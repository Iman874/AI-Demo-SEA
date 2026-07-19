import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Base ──
  static TextStyle _base(double size, FontWeight weight, Color color) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

  // ── Light ──
  static TextStyle get displayLarge =>
      _base(28, FontWeight.bold, AppColors.textPrimaryLight);

  static TextStyle get headlineMedium =>
      _base(22, FontWeight.w600, AppColors.textPrimaryLight);

  static TextStyle get titleLarge =>
      _base(18, FontWeight.w600, AppColors.textPrimaryLight);

  static TextStyle get titleMedium =>
      _base(16, FontWeight.w600, AppColors.textPrimaryLight);

  static TextStyle get bodyLarge =>
      _base(16, FontWeight.normal, AppColors.textPrimaryLight);

  static TextStyle get bodyMedium =>
      _base(14, FontWeight.normal, AppColors.textPrimaryLight);

  static TextStyle get bodySmall =>
      _base(12, FontWeight.normal, AppColors.textSecondaryLight);

  static TextStyle get labelLarge =>
      _base(16, FontWeight.w600, AppColors.textPrimaryLight);

  static TextStyle get labelMedium =>
      _base(14, FontWeight.w500, AppColors.textPrimaryLight);

  static TextStyle get labelSmall =>
      _base(12, FontWeight.normal, AppColors.textSecondaryLight);

  // ── Dark ──
  static TextStyle get displayLargeDark =>
      _base(28, FontWeight.bold, AppColors.textPrimaryDark);

  static TextStyle get headlineMediumDark =>
      _base(22, FontWeight.w600, AppColors.textPrimaryDark);

  static TextStyle get titleLargeDark =>
      _base(18, FontWeight.w600, AppColors.textPrimaryDark);

  static TextStyle get titleMediumDark =>
      _base(16, FontWeight.w600, AppColors.textPrimaryDark);

  static TextStyle get bodyLargeDark =>
      _base(16, FontWeight.normal, AppColors.textPrimaryDark);

  static TextStyle get bodyMediumDark =>
      _base(14, FontWeight.normal, AppColors.textPrimaryDark);

  static TextStyle get bodySmallDark =>
      _base(12, FontWeight.normal, AppColors.textSecondaryDark);

  static TextStyle get labelLargeDark =>
      _base(16, FontWeight.w600, AppColors.textPrimaryDark);

  static TextStyle get labelMediumDark =>
      _base(14, FontWeight.w500, AppColors.textPrimaryDark);

  static TextStyle get labelSmallDark =>
      _base(12, FontWeight.normal, AppColors.textSecondaryDark);

  // ── Context-aware helpers ──
  static TextStyle display(BuildContext context) =>
      _byBrightness(context, displayLarge, displayLargeDark);

  static TextStyle headline(BuildContext context) =>
      _byBrightness(context, headlineMedium, headlineMediumDark);

  static TextStyle titleLg(BuildContext context) =>
      _byBrightness(context, titleLarge, titleLargeDark);

  static TextStyle titleMd(BuildContext context) =>
      _byBrightness(context, titleMedium, titleMediumDark);

  static TextStyle bodyLg(BuildContext context) =>
      _byBrightness(context, bodyLarge, bodyLargeDark);

  static TextStyle bodyMd(BuildContext context) =>
      _byBrightness(context, bodyMedium, bodyMediumDark);

  static TextStyle bodySm(BuildContext context) =>
      _byBrightness(context, bodySmall, bodySmallDark);

  static TextStyle labelLg(BuildContext context) =>
      _byBrightness(context, labelLarge, labelLargeDark);

  static TextStyle labelMd(BuildContext context) =>
      _byBrightness(context, labelMedium, labelMediumDark);

  static TextStyle labelSm(BuildContext context) =>
      _byBrightness(context, labelSmall, labelSmallDark);

  // ── Internal ──
  static TextStyle _byBrightness(
      BuildContext context, TextStyle light, TextStyle dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
