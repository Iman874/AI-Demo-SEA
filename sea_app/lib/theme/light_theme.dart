import 'package:flutter/material.dart';

final Color backgroundColorStudent = const Color(0xFFD97B43);
final Color backgroundColorTeacher = const Color(0xFF4B6A85);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF3F3F3),
  primaryColor: backgroundColorTeacher,
  colorScheme: ColorScheme.light(
    primary: backgroundColorTeacher,
    secondary: backgroundColorStudent,
    background: const Color(0xFFF3F3F3),
    surface: Colors.white,
  ),
  cardColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4B6A85),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD97B43),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
    ),
  ),
  // Tambahkan definisi warna lain sesuai kebutuhan
);
