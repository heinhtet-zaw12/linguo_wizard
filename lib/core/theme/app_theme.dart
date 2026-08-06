import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

// Re-export theme files so existing imports continue to work.
export 'app_colors.dart';
export 'app_dimensions.dart';

/// Application theme configuration.
/// Dark-only — single ThemeData for the futuristic dark theme.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.accentStart,
      secondary: AppColors.accentMid,
      surface: AppColors.surface1,
      error: AppColors.danger,
      onPrimary: AppColors.textOnAccent,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surfaceBase,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headingMedium(
          color: AppColors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceGlass,
        elevation: 0,
        indicatorColor: AppColors.accentStart,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium(color: AppColors.textOnAccent);
          }
          return AppTextStyles.labelMedium(color: AppColors.textTertiary);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        titleTextStyle: AppTextStyles.headingMedium(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium(
          color: AppColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface3,
        contentTextStyle: AppTextStyles.bodyMedium(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Build a TextTheme using GoogleFonts.
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.displayMedium(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.headingLarge(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.headingMedium(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.headingSmall(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
      bodyMedium: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
      bodySmall: AppTextStyles.bodySmall(color: AppColors.textTertiary),
      labelLarge: AppTextStyles.labelLarge(color: AppColors.textPrimary),
      labelMedium: AppTextStyles.labelMedium(color: AppColors.textSecondary),
      labelSmall: AppTextStyles.labelSmall(color: AppColors.textTertiary),
    );
  }
}
