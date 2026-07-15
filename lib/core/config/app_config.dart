/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  /// Gemini API key — injected at build time via --dart-define=API_KEY=xxx
  static const String geminiApiKey = String.fromEnvironment('API_KEY');

  /// Gemini model to use for conversation
  static const String geminiModel = 'gemini-1.5-flash';

  /// Maximum conversation turns before prompting to end
  static const int maxConversationTurns = 20;

  /// Maximum duration for STT listening session
  static const Duration sttListenTimeout = Duration(seconds: 30);

  /// Duration of silence before STT auto-pauses
  static const Duration sttPauseTimeout = Duration(seconds: 3);
}
