import 'package:flutter_test/flutter_test.dart';
import 'package:linguo_wizard/features/onboarding/models/onboarding_data.dart';

void main() {
  group('OnboardingData', () {
    test('constructor stores all fields', () {
      const data = OnboardingData(
        targetLanguage: 'Spanish',
        cefrLevel: 'B2',
        goal: 'Travel',
      );

      expect(data.targetLanguage, 'Spanish');
      expect(data.cefrLevel, 'B2');
      expect(data.goal, 'Travel');
    });

    test('fromJson parses valid JSON', () {
      final json = {
        'targetLanguage': 'French',
        'cefrLevel': 'A2',
        'goal': 'Work',
      };

      final data = OnboardingData.fromJson(json);

      expect(data.targetLanguage, 'French');
      expect(data.cefrLevel, 'A2');
      expect(data.goal, 'Work');
    });

    test('fromJson uses defaults for missing fields', () {
      final json = <String, dynamic>{};

      final data = OnboardingData.fromJson(json);

      expect(data.targetLanguage, 'English');
      expect(data.cefrLevel, 'A1');
      expect(data.goal, 'Travel');
    });

    test('toJson round-trips correctly', () {
      const original = OnboardingData(
        targetLanguage: 'Japanese',
        cefrLevel: 'C1',
        goal: 'Exam',
      );

      final json = original.toJson();
      final restored = OnboardingData.fromJson(json);

      expect(restored.targetLanguage, original.targetLanguage);
      expect(restored.cefrLevel, original.cefrLevel);
      expect(restored.goal, original.goal);
    });
  });

  group('Preset constants', () {
    test('kLanguages is non-empty', () {
      expect(kLanguages, isNotEmpty);
      expect(kLanguages.first.value, 'English');
    });

    test('kCefrLevels covers A1 to C1', () {
      expect(kCefrLevels, ['A1', 'A2', 'B1', 'B2', 'C1']);
    });

    test('kGoals is non-empty', () {
      expect(kGoals, isNotEmpty);
      expect(kGoals.map((e) => e.value), contains('Travel'));
    });
  });
}
