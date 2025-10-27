import 'package:flutter/material.dart';

final Color backgroundColorStudent = const Color(0xFFD97B43);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF181A20),
  primaryColor: const Color(0xFF223A4E),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF223A4E),
    secondary: backgroundColorStudent,
    background: const Color(0xFF181A20),
    surface: const Color(0xFF22252A),
  ),
  cardColor: const Color.fromARGB(255, 76, 82, 93),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF223A4E),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF223A4E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      color: Colors.white,
    ),
  ),
  // Tambahkan definisi warna lain sesuai kebutuhan
);
