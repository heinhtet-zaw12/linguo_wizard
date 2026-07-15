import 'package:flutter/material.dart';

/// Central color palette — extracted from the 3D claymorphism wizard mascot.
class AppColors {
  AppColors._();

  // ─── Primary palette ───
  static const Color primaryPink = Color(0xFFF2A7B3);
  static const Color primaryPinkDark = Color(0xFFD4869A);
  static const Color primaryPinkLight = Color(0xFFFCCDD6);

  // ─── Background gradient ───
  static const Color bgTop = Color(0xFFFADADD);
  static const Color bgBottom = Color(0xFFF8C8D4);

  // ─── Accent ───
  static const Color accentGold = Color(0xFFF5C862);
  static const Color accentCoral = Color(0xFFE8836B);

  // ─── Text ───
  static const Color textDark = Color(0xFF3D2C35);
  static const Color textMuted = Color(0xFF7A6570);
  static const Color textLight = Color(0xFFFFFFFF);

  // ─── Effects ───
  static const Color shadowPink = Color(0x30D4869A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bgTop,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPink,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );
}
