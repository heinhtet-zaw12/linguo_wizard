import 'package:flutter/services.dart';

/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  static final Map<String, String> _env = {};

  /// Loads environment variables from the bundled .env asset.
  static Future<void> loadEnv() async {
    try {
      final content = await rootBundle.loadString('.env');
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eqIndex = trimmed.indexOf('=');
        if (eqIndex == -1) continue;
        final key = trimmed.substring(0, eqIndex).trim();
        final value = trimmed.substring(eqIndex + 1).trim();
        // Strip surrounding quotes if present
        final unquoted = (value.startsWith('"') && value.endsWith('"'))
            ? value.substring(1, value.length - 1)
            : value;
        _env[key] = unquoted;
      }
    } catch (_) {
      // .env not found — geminiApiKey will return empty string
    }
  }

  /// Gemini API key — loaded from .env file
  static String get geminiApiKey => _env['GEMINI_API_KEY'] ?? '';

  /// Gemini model to use for conversation
  static const String geminiModel = 'gemini-3.1-flash-lite';

  /// Maximum conversation turns before prompting to end
  static const int maxConversationTurns = 20;

  /// Maximum duration for STT listening session
  static const Duration sttListenTimeout = Duration(seconds: 30);

  /// Duration of silence before STT auto-pauses
  static const Duration sttPauseTimeout = Duration(seconds: 3);

  /// Maximum daily AI calls for guest users.
  static const int maxDailyCalls = 10;

  /// SharedPreferences key prefix for rate-limit counters.
  static const String rateLimitPrefix = 'rate_limit_';
}
