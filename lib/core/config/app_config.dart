import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide configuration constants.
///
/// SECURITY NOTE: API keys should NEVER be bundled in compiled app binaries.
/// For production, proxy API calls through a Cloud Function (e.g., Firebase Functions).
/// This config loads from .env for development only.
class AppConfig {
  AppConfig._();

  /// Loads environment variables from .env file (development only).
  /// In production, use Cloud Functions to proxy API calls.
  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env not found — geminiApiKey will return empty string.
      // This is expected in production environments.
    }
  }

  /// Gemini API key — loaded from .env file (development only).
  ///
  /// SECURITY WARNING: This key is exposed in client-side code.
  /// For production deployments:
  /// 1. Create a Cloud Function to proxy Gemini API calls
  /// 2. Store the API key in Firebase environment configuration
  /// 3. Remove this getter and use the Cloud Function endpoint instead
  static String get geminiApiKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  /// Gemini model to use for conversation
  static const String geminiModel = 'gemini-3.1-flash-lite';

  /// Maximum conversation turns before prompting to end
  static const int maxConversationTurns = 20;

  /// Maximum duration for STT listening session
  static const Duration sttListenTimeout = Duration(seconds: 30);

  /// Safety-net silence timeout — very generous so the mic stays open
  /// until the user manually taps to stop. Only fires if the user walks
  /// away without ending the turn.
  static const Duration sttPauseTimeout = Duration(seconds: 60);

  /// Enable/disable daily rate limiting for AI calls.
  /// Set to `true` to enforce limits; `false` allows unlimited calls (for testing).
  ///
  /// SECURITY WARNING: This MUST be set to `true` in production to prevent abuse.
  /// Combined with Firebase Security Rules, this provides client-side rate limiting.
  /// For additional security, implement server-side rate limiting via Cloud Functions.
  static const bool rateLimitEnabled = true;

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
