import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable gradient builders for the dark theme.
class AppGradients {
  AppGradients._();

  /// Accent gradient: electric blue → violet (left-to-right).
  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accentStart, AppColors.accentMid, AppColors.accentEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Accent cyan gradient: cyan → indigo.
  static const LinearGradient accentCyan = LinearGradient(
    colors: [AppColors.accentCyan, AppColors.accentStart],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Surface gradient: dark surface transition.
  static const LinearGradient surface = LinearGradient(
    colors: [AppColors.surface0, AppColors.surface1],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
