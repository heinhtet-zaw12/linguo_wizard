import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';

/// Wraps the Google Generative AI package for persona-based conversations.
class AiService {
  GenerativeModel? _model;
  ChatSession? _chat;

  /// Whether a persona has been initialized and the service is ready to chat.
  bool get isReady => _chat != null;

  /// Initializes a new persona-based chat session.
  ///
  /// Creates a [GenerativeModel] with a system instruction that defines
  /// the persona's character, name, and conversation goal.
  void initializePersona({
    required String personaName,
    required String personaDescription,
    required String scenarioGoal,
  }) {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        'Gemini API key is missing. '
        'Make sure your .env file contains GEMINI_API_KEY=your_key (no quotes).',
      );
    }

    _model = GenerativeModel(
      model: AppConfig.geminiModel,
      apiKey: apiKey,
      systemInstruction: Content.system(
        'You are $personaName. $personaDescription '
        'Your goal in this conversation: $scenarioGoal. '
        'Stay in character at all times. '
        'Keep responses short and natural for a spoken conversation (1-3 sentences). '
        'If the user makes grammar mistakes, gently correct them naturally '
        'within the conversation rather than breaking character.',
      ),
    );
    _chat = _model!.startChat();
  }

  /// Sends a message to the AI and returns the response text.
  Future<String> sendMessage(String userText) async {
    if (_chat == null) {
      throw StateError('AiService not initialized. Call initializePersona first.');
    }
    final response = await _chat!.sendMessage(Content.text(userText));
    return response.text ?? '';
  }
}
