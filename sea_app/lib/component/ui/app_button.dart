import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';

/// Sistem Button Modern Aplikasi SEA App
///
/// Bahasa desain disamakan dengan BottomNavigation dan TopHeader: flat
/// surface, shadow lembut dua-layer (netral + accent-tint tipis), warna
/// accent dipakai sebagai fill/tint — bukan gradient/glow penuh.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton._({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.gradientColors,
    this.backgroundColor,
    this.textColor,
  });

  /// Primary Button — flat solid fill (Modern Look).
  ///
  /// Default-nya sekarang flat, bukan gradient. Kalau [gradientColors]
  /// diisi eksplisit (2+ warna), gradient tetap dipakai — supaya tempat
  /// lain di app yang sudah pasang gradient custom tidak ikut berubah.
  factory AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
    List<Color>? gradientColors,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      gradientColors: gradientColors,
      textColor: Colors.white,
    );
  }

  /// Secondary Soft Color Button
  factory AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = false,
    Color? color,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: color?.withValues(alpha: 0.12) ?? AppColors.primary.withValues(alpha: 0.12),
      textColor: color ?? AppColors.primary,
    );
  }

  /// Pill Small Action Button (misal: "Kerjakan", "Detail", "Edit")
  factory AppButton.pill({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Color color = AppColors.primary,
    bool filled = false,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      isFullWidth: false,
      backgroundColor: filled ? color : color.withValues(alpha: 0.12),
      textColor: filled ? Colors.white : color,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only treat gradientColors as an explicit request when the caller
    // actually passed 2+ colors — otherwise fall back to a flat solid
    // fill using the theme's primary color.
    final bool hasExplicitGradient = gradientColors != null && gradientColors!.length > 1;
    final Color solidColor = gradientColors?.first ?? Theme.of(context).primaryColor;

    final isPill = !isFullWidth && backgroundColor != null;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: isPill ? 16 : 20, color: textColor ?? Colors.white),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: (isPill ? AppTextStyles.labelMedium : AppTextStyles.labelLarge).copyWith(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isPill ? 13 : 15,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );

    if (backgroundColor == null) {
      // ── Primary — flat solid fill, soft two-layer shadow ──────────
      // Same shadow recipe as the active-tab circle in BottomNavigation:
      // one neutral shadow for elevation + one faint accent-tinted
      // shadow for warmth, instead of a single colored "glow" blur.
      return Container(
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: (onPressed != null && hasExplicitGradient)
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: onPressed == null
              ? Colors.grey.shade400
              : (hasExplicitGradient ? null : solidColor),
          borderRadius: AppDecorations.borderRadiusMd,
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: solidColor.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: AppDecorations.borderRadiusMd,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: buttonChild,
            ),
          ),
        ),
      );
    }

    return Material(
      color: backgroundColor,
      borderRadius: isPill ? AppDecorations.borderRadiusPill : AppDecorations.borderRadiusMd,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: isPill ? AppDecorations.borderRadiusPill : AppDecorations.borderRadiusMd,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPill ? 14 : 20,
            vertical: isPill ? 8 : 14,
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}