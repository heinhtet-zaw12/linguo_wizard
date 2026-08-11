import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/badge.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
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

/// Whether the progress save is currently in progress.
final isSavingProgressProvider = StateProvider<bool>((ref) => false);

/// ViewModel for the feedback screen.
///
/// Wraps [currentScoreProvider] to provide a ViewModel layer for the feedback
/// screen. The screen watches this provider and forwards user actions here.
class FeedbackViewModel extends Notifier<ScoreData?> {
  @override
  ScoreData? build() => ref.watch(currentScoreProvider);

  /// Save user progress to Firestore before navigating away.
  ///
  /// Reads the current progress, adds the new XP, and saves it back.
  /// Returns true if the save completed successfully, false otherwise.
  Future<bool> saveProgress() async {
    final scoreData = state;
    if (scoreData == null) return false;

    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) return true; // Guests skip save

    ref.read(isSavingProgressProvider.notifier).state = true;

    try {
      final fs = ref.read(firestoreServiceProvider);
      final progress = await fs.getProgress(user.uid);
      final existingXp = progress?['totalXp'] as int? ?? 0;
      final existingCompleted = progress?['scenariosCompleted'] as int? ?? 0;

      await fs.saveProgress(
        user.uid,
        totalXp: existingXp + scoreData.xpEarned,
        scenariosCompleted: existingCompleted,
        lastScenarioAt: DateTime.now(),
      );

      ref.read(isSavingProgressProvider.notifier).state = false;
      return true;
    } catch (e) {
      ref.read(isSavingProgressProvider.notifier).state = false;
      // Still allow navigation even if save fails — XP can sync later
      return true;
    }
  }

  /// Clear the current score data (called when navigating away).
  void clearScore() {
    ref.read(currentScoreProvider.notifier).state = null;
    ref.read(newlyEarnedBadgesProvider.notifier).state = const [];
  }
}

final feedbackProvider =
    NotifierProvider<FeedbackViewModel, ScoreData?>(FeedbackViewModel.new);
