import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary    = Color(0xFF00E5A0);
  static const Color bg         = Color(0xFF0D1117);
  static const Color surface    = Color(0xFF161B22);
  static const Color surface2   = Color(0xFF21262D);
  static const Color textPri    = Color(0xFFE6EDF3);
  static const Color textSec    = Color(0xFF8B949E);
  static const Color danger     = Color(0xFFFF4D4D);
  static const Color warning    = Color(0xFFFFB347);
  static const Color info       = Color(0xFF58A6FF);

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: surface,
      onSurface: textPri,
    ),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPri, fontSize: 17, fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPri),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textSec),
      labelStyle: const TextStyle(color: textSec),
    ),
  );
}