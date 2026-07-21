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

  /// Enable/disable daily rate limiting for AI calls.
  /// Set to `true` to enforce limits; `false` allows unlimited calls (for testing).
  static const bool rateLimitEnabled = false;

  /// Maximum daily AI calls for guest users.
  static const int maxDailyCalls = 10;

  /// SharedPreferences key prefix for rate-limit counters.
  static const String rateLimitPrefix = 'rate_limit_';

  /// XP earned per completed scenario (flat rate).
  static const int xpPerScenario = 50;

  /// Evaluation prompt template for Gemini structured JSON evaluation.
  /// Placeholders: {goal}, {transcript}
  static const String evaluationPromptTemplate = '''
You are an English language teacher evaluating a student's conversation performance.

The student's conversation goal was: {goal}

Analyze the conversation transcript below and provide:
1. An overall score (0-100) based on how well the student achieved the goal
2. A fluency score (0-100) based on natural flow and coherence
3. A grammar score (0-100) based on grammatical accuracy
4. A vocabulary score (0-100) based on word choice and range
5. A list of grammar corrections with original text, corrected text, and explanation

Be fair but encouraging. Score generously for beginners (A1-A2) and stricter for advanced (B1+).

Conversation transcript:
{transcript}
''';
}
