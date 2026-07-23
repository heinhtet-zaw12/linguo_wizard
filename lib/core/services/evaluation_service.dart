import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/app_config.dart';
import '../../features/feedback/models/score_data.dart';

/// Evaluates a conversation transcript using Gemini structured JSON output.
///
/// Follows the same pattern as [AiService]: plain Dart class, no Riverpod,
/// stateless and injectable.
class EvaluationService {
  /// Calls Gemini to evaluate the student's conversation performance.
  ///
  /// Returns a [ScoreData] with scores and grammar corrections.
  /// On any failure, returns [ScoreData.fallback()] with zeroed scores.
  Future<ScoreData> evaluateGoal({
    required String scenarioGoal,
    required String transcript,
  }) async {
    try {
      final apiKey = AppConfig.geminiApiKey;
      if (apiKey.isEmpty) {
        throw StateError(
          'Gemini API key is missing. '
          'Make sure your .env file contains GEMINI_API_KEY=your_key (no quotes).',
        );
      }

      final model = GenerativeModel(
        model: AppConfig.geminiModel,
        apiKey: apiKey,
        // No system instruction — this is a one-shot evaluation, not a chat.
      );

      final prompt = AppConfig.evaluationPromptTemplate
          .replaceAll('{goal}', scenarioGoal)
          .replaceAll('{transcript}', transcript);

      final response = await model.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          temperature: 0.3,
          responseMimeType: 'application/json',
          responseSchema: Schema(
            SchemaType.object,
            properties: {
              'overallScore': Schema(SchemaType.integer),
              'fluencyScore': Schema(SchemaType.integer),
              'grammarScore': Schema(SchemaType.integer),
              'vocabularyScore': Schema(SchemaType.integer),
              'grammarCorrections': Schema(
                SchemaType.array,
                items: Schema(
                  SchemaType.object,
                  properties: {
                    'original': Schema(SchemaType.string),
                    'corrected': Schema(SchemaType.string),
                    'explanation': Schema(SchemaType.string),
                  },
                ),
              ),
            },
            requiredProperties: [
              'overallScore',
              'fluencyScore',
              'grammarScore',
              'vocabularyScore',
            ],
          ),
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(
          'Gemini evaluation timed out after 30s',
        ),
      );

      final jsonStr = response.text;
      if (jsonStr == null || jsonStr.isEmpty) {
        return ScoreData.fallback();
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return ScoreData.fromJson(json);
    } catch (e) {
      // On any failure, return fallback scores.
      return ScoreData.fallback();
    }
  }
}
