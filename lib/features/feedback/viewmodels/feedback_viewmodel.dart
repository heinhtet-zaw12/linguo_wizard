import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/badge.dart';
import '../models/score_data.dart';

/// Score data holder provider — ConversationScreen sets this before navigating
/// and FeedbackScreen reads it on mount.
///
/// This is the primary mechanism for passing score data from the conversation
/// screen to the feedback screen. The FeedbackViewModel simply wraps this
/// provider for the MVVM pattern.
final currentScoreProvider = StateProvider<ScoreData?>((ref) => null);

/// Newly earned badges from the last scenario completion.
///
/// ConversationViewModel sets this before navigating to FeedbackScreen.
final newlyEarnedBadgesProvider = StateProvider<List<Badge>>((ref) => const []);

/// ViewModel for the feedback screen.
///
/// Wraps [currentScoreProvider] to provide a ViewModel layer for the feedback
/// screen. The screen watches this provider and forwards user actions here.
class FeedbackViewModel extends Notifier<ScoreData?> {
  @override
  ScoreData? build() => ref.watch(currentScoreProvider);

  /// Clear the current score data (called when navigating away).
  void clearScore() {
    ref.read(currentScoreProvider.notifier).state = null;
    ref.read(newlyEarnedBadgesProvider.notifier).state = const [];
  }
}

final feedbackProvider =
    NotifierProvider<FeedbackViewModel, ScoreData?>(FeedbackViewModel.new);
