import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linguo_wizard/features/feedback/models/score_data.dart';
import 'package:linguo_wizard/features/feedback/viewmodels/feedback_viewmodel.dart';

void main() {
  group('FeedbackViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      expect(container.read(feedbackProvider), isNull);
    });

    test('currentScoreProvider can be set', () {
      const scoreData = ScoreData(
        overallScore: 85,
        fluencyScore: 80,
        grammarScore: 90,
        vocabularyScore: 85,
        grammarCorrections: [],
        xpEarned: 10,
      );

      container.read(currentScoreProvider.notifier).state = scoreData;

      expect(container.read(currentScoreProvider), scoreData);
    });

    test('clearScore sets score to null', () {
      const scoreData = ScoreData(
        overallScore: 85,
        fluencyScore: 80,
        grammarScore: 90,
        vocabularyScore: 85,
        grammarCorrections: [],
        xpEarned: 10,
      );

      container.read(currentScoreProvider.notifier).state = scoreData;
      expect(container.read(currentScoreProvider), isNotNull);

      container.read(feedbackProvider.notifier).clearScore();
      expect(container.read(currentScoreProvider), isNull);
    });
  });
}
