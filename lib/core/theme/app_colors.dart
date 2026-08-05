import 'package:flutter/material.dart';

/// Abstract color token interface.
/// Both light and dark themes implement this.
abstract class AppColorTokens {
  // Surface
  Color get surfacePrimary;
  Color get surfaceSecondary;
  Color get surfaceGlass;

  // Background gradient
  Color get backgroundStart;
  Color get backgroundMid;
  Color get backgroundEnd;

  // Accent
  Color get accentPrimary;
  Color get accentPrimaryLight;
  Color get accentPrimaryDark;
  Color get accentSecondary;
  Color get accentTertiary;
  Color get accentDanger;

  // Text
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get textOnAccent;

  // Border
  Color get borderSubtle;
  Color get borderFocus;

  // Shadow
  Color get shadowColor;
}

/// Light mode color tokens.
class LightColors implements AppColorTokens {
  const LightColors();

  @override
  Color get surfacePrimary => const Color(0xFFFFFFFF);
  @override
  Color get surfaceSecondary => const Color(0xFFF8F5F2);
  @override
  Color get surfaceGlass => const Color(0xB8FFFFFF); // 72% white

  @override
  Color get backgroundStart => const Color(0xFFFFF5F7);
  @override
  Color get backgroundMid => const Color(0xFFFDE8EE);
  @override
  Color get backgroundEnd => const Color(0xFFF9D4DE);

  @override
  Color get accentPrimary => const Color(0xFFE8728A);
  @override
  Color get accentPrimaryLight => const Color(0xFFF5A3B5);
  @override
  Color get accentPrimaryDark => const Color(0xFFC95670);
  @override
  Color get accentSecondary => const Color(0xFFF5B742);
  @override
  Color get accentTertiary => const Color(0xFF7ECFC0);
  @override
  Color get accentDanger => const Color(0xFFE86B6B);

  @override
  Color get textPrimary => const Color(0xFF2D1F2B);
  @override
  Color get textSecondary => const Color(0xFF6B5A66);
  @override
  Color get textTertiary => const Color(0xFFA89BA3);
  @override
  Color get textOnAccent => const Color(0xFFFFFFFF);

  @override
  Color get borderSubtle => const Color(0x0F000000); // 6% black
  @override
  Color get borderFocus => const Color(0xFFE8728A);

  @override
  Color get shadowColor => const Color(0x14C85078); // 8% pink
}

/// Dark mode color tokens.
class DarkColors implements AppColorTokens {
  const DarkColors();

  @override
  Color get surfacePrimary => const Color(0xFF1E1A20);
  @override
  Color get surfaceSecondary => const Color(0xFF2A2530);
  @override
  Color get surfaceGlass => const Color(0xCC282330); // 80% dark

  @override
  Color get backgroundStart => const Color(0xFF141018);
  @override
  Color get backgroundMid => const Color(0xFF1A1520);
  @override
  Color get backgroundEnd => const Color(0xFF201A28);

  @override
  Color get accentPrimary => const Color(0xFFF5A3B5);
  @override
  Color get accentPrimaryLight => const Color(0xFFFBBCC9);
  @override
  Color get accentPrimaryDark => const Color(0xFFE8728A);
  @override
  Color get accentSecondary => const Color(0xFFF5B742);
  @override
  Color get accentTertiary => const Color(0xFF7ECFC0);
  @override
  Color get accentDanger => const Color(0xFFE86B6B);

  @override
  Color get textPrimary => const Color(0xFFF2ECF0);
  @override
  Color get textSecondary => const Color(0xFFB8A8B2);
  @override
  Color get textTertiary => const Color(0xFF7A6B75);
  @override
  Color get textOnAccent => const Color(0xFFFFFFFF);

  @override
  Color get borderSubtle => const Color(0x14FFFFFF); // 8% white
  @override
  Color get borderFocus => const Color(0xFFF5A3B5);

  @override
  Color get shadowColor => const Color(0x4D000000); // 30% black
}

/// Current theme color tokens — set by AppTheme, read by all widgets.
/// Defaults to light mode.
class AppColorProvider {
  static AppColorTokens _tokens = const LightColors();

  static AppColorTokens get current => _tokens;

  /// Called by AppTheme when theme changes.
  static void update(AppColorTokens tokens) {
    _tokens = tokens;
  }
}

/// Backward-compatible static color palette.
/// Delegates to the current theme's tokens where possible.
/// Legacy fields (primaryPink, bgTop, etc.) are kept as const for backward compatibility.
class AppColors {
  AppColors._();

  // ─── New semantic tokens (preferred for new code) ───
  static Color get surfacePrimary => AppColorProvider.current.surfacePrimary;
  static Color get surfaceSecondary =>
      AppColorProvider.current.surfaceSecondary;
  static Color get surfaceGlass => AppColorProvider.current.surfaceGlass;
  static Color get backgroundStart =>
      AppColorProvider.current.backgroundStart;
  static Color get backgroundMid => AppColorProvider.current.backgroundMid;
  static Color get backgroundEnd => AppColorProvider.current.backgroundEnd;
  static Color get accentPrimary => AppColorProvider.current.accentPrimary;
  static Color get accentPrimaryLight =>
      AppColorProvider.current.accentPrimaryLight;
  static Color get accentPrimaryDark =>
      AppColorProvider.current.accentPrimaryDark;
  static Color get accentSecondary => AppColorProvider.current.accentSecondary;
  static Color get accentTertiary => AppColorProvider.current.accentTertiary;
  static Color get accentDanger => AppColorProvider.current.accentDanger;
  static Color get textPrimary => AppColorProvider.current.textPrimary;
  static Color get textSecondary => AppColorProvider.current.textSecondary;
  static Color get textTertiary => AppColorProvider.current.textTertiary;
  static Color get textOnAccent => AppColorProvider.current.textOnAccent;
  static Color get borderSubtle => AppColorProvider.current.borderSubtle;
  static Color get borderFocus => AppColorProvider.current.borderFocus;
  static Color get shadowColor => AppColorProvider.current.shadowColor;

  // ─── Legacy const fields (backward compatibility) ───
  // These are frozen at light-mode values.
  // New code should use semantic tokens above.
  // These will be removed in Wave 3 once all screens use new tokens.
  static const Color primaryPink = Color(0xFFF2A7B3);
  static const Color primaryPinkDark = Color(0xFFD4869A);
  static const Color primaryPinkLight = Color(0xFFFCCDD6);
  static const Color bgTop = Color(0xFFFADADD);
  static const Color bgBottom = Color(0xFFF8C8D4);
  static const Color accentGold = Color(0xFFF5C862);
  static const Color accentCoral = Color(0xFFE8836B);
  static const Color textDark = Color(0xFF3D2C35);
  static const Color textMuted = Color(0xFF7A6570);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color shadowPink = Color(0x30D4869A);
}
