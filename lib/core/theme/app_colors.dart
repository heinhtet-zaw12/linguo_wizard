import 'package:flutter/material.dart';

/// Flat dark-only color palette.
/// All tokens are direct const Color constants — no provider delegation.
class AppColors {
  AppColors._();

  // ─── Surface (Dark) ───
  static const Color surfaceBase = Color(0xFF0A0E1A);
  static const Color surface0 = Color(0xFF0F1424);
  static const Color surface1 = Color(0xFF151B30);
  static const Color surface2 = Color(0xFF1C2340);
  static const Color surface3 = Color(0xFF242D50);

  // ─── Accent Gradient (Electric Blue → Violet) ───
  static const Color accentStart = Color(0xFF6366F1);
  static const Color accentMid = Color(0xFF8B5CF6);
  static const Color accentEnd = Color(0xFFA78BFA);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentCyanGlow = Color(0xFF06B6D4);

  // ─── Semantic Text ───
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF7C8BA1);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ─── Status ───
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  // ─── Border ───
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderGlow = Color(0x406366F1);

  // ─── Glass ───
  static const Color surfaceGlass = Color(0x33151B30);
  static const double glassBlur = 20.0;
  static const double glassBorderOpacity = 0.12;
}
