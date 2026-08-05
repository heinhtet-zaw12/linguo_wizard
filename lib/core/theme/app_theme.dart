import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

// Re-export app_colors.dart so existing imports continue to work.
export 'app_colors.dart';

/// Application theme configuration.
/// Provides both light and dark Material 3 themes.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colors = const LightColors();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.accentPrimary,
      brightness: Brightness.light,
      primary: colors.accentPrimary,
      onPrimary: colors.textOnAccent,
      surface: colors.surfacePrimary,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.backgroundStart,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headingMedium(
          color: colors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceGlass,
        elevation: 0,
        indicatorColor: colors.accentPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium(color: colors.textOnAccent);
          }
          return AppTextStyles.labelMedium(color: colors.textTertiary);
        }),
      ),
    );
  }

  static ThemeData get dark {
    final colors = const DarkColors();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.accentPrimary,
      brightness: Brightness.dark,
      primary: colors.accentPrimary,
      onPrimary: colors.textOnAccent,
      surface: colors.surfacePrimary,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.backgroundStart,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headingMedium(
          color: colors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceGlass,
        elevation: 0,
        indicatorColor: colors.accentPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium(color: colors.textOnAccent);
          }
          return AppTextStyles.labelMedium(color: colors.textTertiary);
        }),
      ),
    );
  }

  /// Build a TextTheme using GoogleFonts.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final colors =
        brightness == Brightness.light ? const LightColors() : const DarkColors();

    return TextTheme(
      displayLarge: AppTextStyles.displayLarge(color: colors.textPrimary),
      displayMedium: AppTextStyles.displayMedium(color: colors.textPrimary),
      headlineLarge: AppTextStyles.headingLarge(color: colors.textPrimary),
      headlineMedium: AppTextStyles.headingMedium(color: colors.textPrimary),
      headlineSmall: AppTextStyles.headingSmall(color: colors.textPrimary),
      bodyLarge: AppTextStyles.bodyLarge(color: colors.textSecondary),
      bodyMedium: AppTextStyles.bodyMedium(color: colors.textSecondary),
      bodySmall: AppTextStyles.bodySmall(color: colors.textTertiary),
      labelLarge: AppTextStyles.labelLarge(color: colors.textPrimary),
      labelMedium: AppTextStyles.labelMedium(color: colors.textSecondary),
      labelSmall: AppTextStyles.labelSmall(color: colors.textTertiary),
    );
  }

  /// Update the AppColorProvider based on brightness.
  /// Call this when theme changes (e.g., dark mode toggle).
  static void updateColorProvider(Brightness brightness) {
    if (brightness == Brightness.dark) {
      AppColorProvider.update(const DarkColors());
    } else {
      AppColorProvider.update(const LightColors());
    }
  }
}
