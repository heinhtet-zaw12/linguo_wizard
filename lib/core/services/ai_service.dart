import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../features/scenario_selection/models/scenario.dart';
import '../config/app_config.dart';

// Wraps the Google Generative AI package for persona-based conversations.
class AiService {
  GenerativeModel? _model;
  ChatSession? _chat;

  // Whether a persona has been initialized and the service is ready to chat.
  bool get isReady => _chat != null;

  // Initializes a new persona-based chat session.
  //
  // Creates a [GenerativeModel] with a system instruction that defines
  // the persona's character, name, and conversation goal.
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

  /// Generates a complete scenario config from user-provided description.
  ///
  /// Uses Gemini structured JSON output (same pattern as EvaluationService)
  /// to produce a Scenario object from free-form user input.
  Future<Scenario> generateScenario({
    required String persona,
    required String context,
    required String goal,
    required String cefrLevel,
    required String tone,
  }) async {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) throw StateError('Gemini API key missing');

    final model = GenerativeModel(
      model: AppConfig.geminiModel,
      apiKey: apiKey,
    );

    final prompt = '''
You are a scenario designer for an English language learning app.
Generate a conversation scenario as structured JSON — no markdown, no code fences, pure JSON.

The scenario must feel realistic and be appropriate for a $cefrLevel English learner.
Tone: $tone

User's request:
- Persona/character to talk to: $persona
- Context/setting: $context
- Goal to accomplish: $goal

Return this exact JSON structure (no other text):
{
  "title": "short catchy title (max 5 words)",
  "description": "one sentence describing the situation",
  "personaName": "a fitting name for the character",
  "personaDescription": "2-3 sentences: who they are, their personality, how they speak",
  "goalDescription": "what the user needs to accomplish (one sentence)",
  "category": "one of: travel, work, social, academic, daily-life",
  "openingMessage": "the character's first line to start the conversation naturally",
  "tags": ["2-4 relevant tags for search"]
}
''';

    final response = await model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        temperature: 0.8,
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          properties: {
            'title': Schema(SchemaType.string),
            'description': Schema(SchemaType.string),
            'personaName': Schema(SchemaType.string),
            'personaDescription': Schema(SchemaType.string),
            'goalDescription': Schema(SchemaType.string),
            'category': Schema(SchemaType.string),
            'openingMessage': Schema(SchemaType.string),
            'tags': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
            ),
          },
          requiredProperties: [
            'title', 'description', 'personaName', 'personaDescription',
            'goalDescription', 'category', 'openingMessage', 'tags',
          ],
        ),
      ),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Scenario generation timed out'),
    );

    final jsonStr = response.text;
    if (jsonStr == null || jsonStr.isEmpty) {
      throw StateError('Empty response from Gemini');
    }

    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    return Scenario(
      id: 'custom_${const Uuid().v4()}',
      title: json['title'] as String,
      description: json['description'] as String,
      personaName: json['personaName'] as String,
      personaDescription: json['personaDescription'] as String,
      goalDescription: json['goalDescription'] as String,
      cefrLevel: cefrLevel,
      category: json['category'] as String? ?? 'social',
      openingMessage: json['openingMessage'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      difficultyRating: _difficultyForLevel(cefrLevel),
      isFeatured: false,
      completionCount: 0,
    );
  }

  /// Maps CEFR level to a default difficulty rating (1-5).
  int _difficultyForLevel(String cefrLevel) {
    switch (cefrLevel.toUpperCase()) {
      case 'A1': return 1;
      case 'A2': return 2;
      case 'B1': return 3;
      case 'B2': return 4;
      case 'C1': return 5;
      default: return 3;
    }
  }
}
