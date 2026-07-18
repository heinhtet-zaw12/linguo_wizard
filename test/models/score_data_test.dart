import 'package:flutter_test/flutter_test.dart';
import 'package:linguo_wizard/features/feedback/models/score_data.dart';

void main() {
  group('ScoreData', () {
    test('fromJson parses valid JSON', () {
      final json = {
        'overallScore': 85,
        'fluencyScore': 80,
        'grammarScore': 90,
        'vocabularyScore': 85,
        'grammarCorrections': [
          {
            'original': 'I go to store',
            'corrected': 'I went to the store',
            'explanation': 'Past tense needed',
          },
        ],
      };

      final score = ScoreData.fromJson(json);

      expect(score.overallScore, 85);
      expect(score.fluencyScore, 80);
      expect(score.grammarScore, 90);
      expect(score.vocabularyScore, 85);
      expect(score.xpEarned, 10);
      expect(score.grammarCorrections, hasLength(1));
      expect(score.grammarCorrections[0].original, 'I go to store');
      expect(score.grammarCorrections[0].corrected, 'I went to the store');
      expect(score.grammarCorrections[0].explanation, 'Past tense needed');
    });

    test('fromJson handles missing scores gracefully', () {
      final json = <String, dynamic>{};

      final score = ScoreData.fromJson(json);

      expect(score.overallScore, 0);
      expect(score.fluencyScore, 0);
      expect(score.grammarScore, 0);
      expect(score.vocabularyScore, 0);
      expect(score.grammarCorrections, isEmpty);
    });

    test('fromJson handles non-list grammarCorrections', () {
      final json = {
        'overallScore': 70,
        'fluencyScore': 70,
        'grammarScore': 70,
        'vocabularyScore': 70,
        'grammarCorrections': 'invalid',
      };

      final score = ScoreData.fromJson(json);

      expect(score.grammarCorrections, isEmpty);
    });

    test('fromJson handles malformed correction items', () {
      final json = {
        'overallScore': 70,
        'fluencyScore': 70,
        'grammarScore': 70,
        'vocabularyScore': 70,
        'grammarCorrections': [
          {'original': 'good'},
          'not a map',
          null,
        ],
      };

      final score = ScoreData.fromJson(json);

      // Only the valid map item should be parsed
      expect(score.grammarCorrections, hasLength(1));
      expect(score.grammarCorrections[0].original, 'good');
      expect(score.grammarCorrections[0].corrected, '');
      expect(score.grammarCorrections[0].explanation, '');
    });

    test('fallback returns zeroed scores', () {
      final score = ScoreData.fallback();

      expect(score.overallScore, 0);
      expect(score.fluencyScore, 0);
      expect(score.grammarScore, 0);
      expect(score.vocabularyScore, 0);
      expect(score.grammarCorrections, isEmpty);
      expect(score.xpEarned, 0);
    });
  });

  group('GrammarCorrection', () {
    test('constructor stores all fields', () {
      const correction = GrammarCorrection(
        original: 'original',
        corrected: 'corrected',
        explanation: 'explanation',
      );

      expect(correction.original, 'original');
      expect(correction.corrected, 'corrected');
      expect(correction.explanation, 'explanation');
    });
  });
}
