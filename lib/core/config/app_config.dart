import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  /// Gemini API key — loaded from .env file
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Gemini model to use for conversation
  static const String geminiModel = 'gemini-1.5-flash';

  /// Maximum conversation turns before prompting to end
  static const int maxConversationTurns = 20;

  /// Maximum duration for STT listening session
  static const Duration sttListenTimeout = Duration(seconds: 30);

  /// Duration of silence before STT auto-pauses
  static const Duration sttPauseTimeout = Duration(seconds: 3);
}
