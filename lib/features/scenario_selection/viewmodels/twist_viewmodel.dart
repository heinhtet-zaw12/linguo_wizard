import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/scenario_service.dart';
import '../models/scenario.dart';

/// ViewModel for the "Today's Twist" flow.
///
/// Orchestrates:
/// 1. Reading the current twist replay count from Firestore
/// 2. Generating a twist variation via AiService (progressive depth)
/// 3. Incrementing the replay count after successful generation
/// 4. Exposing the generated twist Scenario for navigation
class TwistViewModel extends StateNotifier<AsyncValue<Scenario?>> {
  TwistViewModel(this._scenarioService, this._aiService)
      : super(const AsyncData(null));

  final FirestoreScenarioService _scenarioService;
  final AiService _aiService;

  /// Generate a twist variation of [originalScenario] and set state.
  ///
  /// [uid] may be null for guest users (twist badge not shown for guests,
  /// but the ViewModel handles gracefully).
  Future<void> generateAndLaunchTwist({
    required Scenario originalScenario,
    required String? uid,
  }) async {
    state = const AsyncLoading();

    try {
      // 1. Read current twist replay count (defaults to 0).
      final replayCount = uid != null
          ? await _scenarioService.getTwistReplayCount(uid, originalScenario.id)
          : 0;

      // 2. Generate twist variation via AiService.
      final twistData = await _aiService.generateTwistVariation(
        scenario: originalScenario,
        replayCount: replayCount,
      );

      // 3. Build a twist Scenario from the original + variation fields.
      final twistScenario = Scenario(
        id: 'twist_${originalScenario.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: twistData['title'] as String? ?? originalScenario.title,
        description:
            twistData['description'] as String? ?? originalScenario.description,
        personaName:
            twistData['personaName'] as String? ?? originalScenario.personaName,
        personaDescription: twistData['personaDescription'] as String? ??
            originalScenario.personaDescription,
        goalDescription: twistData['goalDescription'] as String? ??
            originalScenario.goalDescription,
        cefrLevel: originalScenario.cefrLevel,
        category: originalScenario.category,
        openingMessage: twistData['openingMessage'] as String? ??
            originalScenario.openingMessage,
        tags: originalScenario.tags,
        difficultyRating: originalScenario.difficultyRating,
        isFeatured: false,
        completionCount: 0,
      );

      // 4. Increment twist replay count (fire-and-forget for guests).
      if (uid != null) {
        await _scenarioService.incrementTwistReplay(uid, originalScenario.id);
      }

      // 5. Expose the twist scenario for the screen to navigate.
      state = AsyncData(twistScenario);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Reset state back to null (e.g., after navigation completes).
  void reset() {
    state = const AsyncData(null);
  }
}

/// Provider for [TwistViewModel].
final twistProvider =
    StateNotifierProvider<TwistViewModel, AsyncValue<Scenario?>>((ref) {
  return TwistViewModel(
    ref.read(scenarioServiceProvider),
    ref.read(aiServiceProvider),
  );
});
