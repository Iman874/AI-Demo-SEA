import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_decorations.dart';
import 'app_text_styles.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.scaffoldDark,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryLight,       // lebih terang di dark mode
    onPrimary: Colors.white,
    secondary: AppColors.secondaryLight,   // sedikit lebih terang
    onSecondary: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.error,
    onError: Colors.white,
  ),
  cardColor: AppColors.surfaceDark,
  dividerColor: AppColors.borderDark,
  shadowColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.borderDark,
      disabledForegroundColor: AppColors.textSecondaryDark,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusSm,
      ),
      textStyle: AppTextStyles.labelLargeDark,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      side: const BorderSide(color: AppColors.primaryLight),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: AppDecorations.borderRadiusSm,
      ),
      textStyle: AppTextStyles.labelLargeDark,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: AppTextStyles.labelLargeDark,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: AppDecorations.borderRadiusSm,
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDecorations.borderRadiusSm,
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDecorations.borderRadiusSm,
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDecorations.borderRadiusSm,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    labelStyle: AppTextStyles.labelMediumDark,
    hintStyle: AppTextStyles.bodyMediumDark
        .copyWith(color: AppColors.textSecondaryDark),
  ),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.displayLargeDark,
    headlineMedium: AppTextStyles.headlineMediumDark,
    titleLarge: AppTextStyles.titleLargeDark,
    titleMedium: AppTextStyles.titleMediumDark,
    bodyLarge: AppTextStyles.bodyLargeDark,
    bodyMedium: AppTextStyles.bodyMediumDark,
    bodySmall: AppTextStyles.bodySmallDark,
    labelLarge: AppTextStyles.labelLargeDark,
    labelMedium: AppTextStyles.labelMediumDark,
    labelSmall: AppTextStyles.labelSmallDark,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.borderDark,
    labelStyle: AppTextStyles.bodySmallDark,
    shape: RoundedRectangleBorder(
      borderRadius: AppDecorations.borderRadiusSm,
    ),
    side: BorderSide.none,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: AppDecorations.borderRadiusLg,
    ),
    titleTextStyle: AppTextStyles.titleLargeDark,
    contentTextStyle: AppTextStyles.bodyMediumDark,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: AppColors.textSecondaryDark,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
);
