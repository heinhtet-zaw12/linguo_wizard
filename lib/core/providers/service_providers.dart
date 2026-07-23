import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_service.dart';
import '../services/daily_challenge_service.dart';
import '../services/firestore_service.dart';
import '../services/gamification_service.dart';
import '../services/scenario_service.dart';
import '../services/srs_service.dart';
import 'auth_provider.dart';

/// Injectable provider for [GamificationService].
///
/// Depends on [FirestoreService] for data persistence.
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService(ref.read(firestoreServiceProvider));
});

/// Injectable provider for [SrsService].
///
/// Depends on [FirestoreService] for data persistence.
final srsServiceProvider = Provider<SrsService>((ref) {
  return SrsService(ref.read(firestoreServiceProvider));
});

/// Injectable provider for [FirestoreScenarioService].
///
/// Stateless service for fetching and caching curated scenarios from Firestore.
final scenarioServiceProvider =
    Provider<FirestoreScenarioService>((ref) => FirestoreScenarioService());

/// Injectable provider for [AiService].
///
/// Stateless service for persona-based conversations and scenario generation.
final aiServiceProvider = Provider<AiService>((ref) => AiService());

/// Injectable provider for [DailyChallengeService].
///
/// Depends on [AiService] for scenario variation generation and
/// [FirestoreService] for Firestore seed document management.
final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService(
    ref.read(aiServiceProvider),
  );
});
