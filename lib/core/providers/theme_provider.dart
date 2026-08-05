import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

const _kThemeKey = 'theme_mode';

/// Persists the user's theme choice and exposes it as a Riverpod provider.
///
/// Values: `system` (default), `light`, `dark`.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kThemeKey);
    state = _fromString(value);
    _syncColorProvider();
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    _syncColorProvider();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }

  void _syncColorProvider() {
    switch (state) {
      case ThemeMode.dark:
        AppTheme.updateColorProvider(Brightness.dark);
        break;
      case ThemeMode.light:
        AppTheme.updateColorProvider(Brightness.light);
        break;
      case ThemeMode.system:
        // Let the OS decide; Flutter's MaterialApp handles the ThemeData.
        // For AppColorProvider (used by non-Material widgets), default to light.
        AppTheme.updateColorProvider(Brightness.light);
        break;
    }
  }

  static ThemeMode _fromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
