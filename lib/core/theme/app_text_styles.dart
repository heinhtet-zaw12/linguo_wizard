import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized text style system.
/// Uses Plus Jakarta Sans (headings), Inter (body), JetBrains Mono (numbers).
class AppTextStyles {
  AppTextStyles._();

  // ─── Font families ───
  static TextStyle get _heading => GoogleFonts.plusJakartaSans();
  static TextStyle get _body => GoogleFonts.inter();
  static TextStyle get _mono => GoogleFonts.jetBrainsMono();

  // ─── Display (hero numbers, XP counters) ───

  static TextStyle displayLarge({Color? color}) => _mono.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle displayMedium({Color? color}) => _heading.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: color ?? AppColors.textPrimary,
      );

  // ─── Headings ───

  static TextStyle headingLarge({Color? color}) => _heading.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle headingMedium({Color? color}) => _heading.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.41,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle headingSmall({Color? color}) => _heading.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.47,
        color: color ?? AppColors.textPrimary,
      );

  // ─── Body ───

  static TextStyle bodyLarge({Color? color}) => _body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodyMedium({Color? color}) => _body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySmall({Color? color}) => _body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        color: color ?? AppColors.textTertiary,
      );

  // ─── Labels ───

  static TextStyle labelLarge({Color? color}) => _body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle labelMedium({Color? color}) => _body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle labelSmall({Color? color}) => _body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.27,
        color: color ?? AppColors.textTertiary,
      );
}
