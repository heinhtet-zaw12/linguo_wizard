import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevation system with themed shadows.
class AppShadows {
  AppShadows._();

  /// Level 1: Resting cards
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  /// Level 2: Hovered/focused cards
  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Level 3: Modals, dropdowns
  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Level 4: Floating elements
  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
      ];

  /// Glass card shadow (subtle, used with backdrop blur)
  static List<BoxShadow> get glass => [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x99FFFFFF),
          blurRadius: 8,
          offset: Offset(0, -3),
        ),
      ];
}
