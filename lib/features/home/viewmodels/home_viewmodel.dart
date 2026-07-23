import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/streak_data.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/scenario_service.dart';
import '../../scenario_selection/models/scenario.dart';

/// State for the home dashboard.
class HomeState {
  final int totalXp;
  final int scenariosCompleted;
  final int streakDays;
  final String? displayName;
  final String? cefrLevel;
  final List<Scenario> recommendedScenarios;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.totalXp = 0,
    this.scenariosCompleted = 0,
    this.streakDays = 0,
    this.displayName,
    this.cefrLevel,
    this.recommendedScenarios = const [],
    this.isLoading = true,
    this.error,
  });

  HomeState copyWith({
    int? totalXp,
    int? scenariosCompleted,
    int? streakDays,
    String? displayName,
    String? cefrLevel,
    List<Scenario>? recommendedScenarios,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      totalXp: totalXp ?? this.totalXp,
      scenariosCompleted: scenariosCompleted ?? this.scenariosCompleted,
      streakDays: streakDays ?? this.streakDays,
      displayName: displayName ?? this.displayName,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      recommendedScenarios:
          recommendedScenarios ?? this.recommendedScenarios,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for the home dashboard.
///
/// Loads user data from Firestore (authenticated) or SharedPreferences (guest).
/// Recommends scenarios filtered by the user's CEFR level.
class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final user = ref.read(currentUserProvider);
    final isGuest = ref.read(isGuestProvider);

    try {
      if (isGuest) {
        return await _loadGuestData();
      } else if (user != null) {
        return await _loadAuthenticatedData(user.uid);
      } else {
        return const HomeState(isLoading: false, displayName: 'Guest');
      }
    } catch (e) {
      return HomeState(isLoading: false, error: e.toString());
    }
  }

  Future<HomeState> _loadGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    final displayName = 'Guest';
    final cefrLevel = prefs.getString('onboarding_cefr') ?? 'A1';
    final totalXp = prefs.getInt('progress_xp') ?? 0;
    final scenariosCompleted = prefs.getInt('progress_scenarios') ?? 0;
    final streakDays = prefs.getInt('progress_streak') ?? 0;

    final scenarios = await _loadRecommendedScenarios(cefrLevel);

    return HomeState(
      totalXp: totalXp,
      scenariosCompleted: scenariosCompleted,
      streakDays: streakDays,
      displayName: displayName,
      cefrLevel: cefrLevel,
      recommendedScenarios: scenarios,
      isLoading: false,
    );
  }

  Future<HomeState> _loadAuthenticatedData(String uid) async {
    final firestore = ref.read(firestoreServiceProvider);

    // Load profile
    final profile = await firestore.getUserProfile(uid);
    final displayName = profile?['displayName'] as String? ?? 'Learner';

    // Load preferences
    final prefs = await firestore.getPreferences(uid);
    final cefrLevel = prefs?['cefrLevel'] as String? ?? 'A1';

    // Load progress and streak concurrently.
    final results = await Future.wait<Object?>([
      firestore.getProgress(uid),
      firestore.getStreak(uid),
    ]);

    final progress = results[0] as Map<String, dynamic>?;
    final streakData = results[1] as StreakData?;

    final totalXp = progress?['totalXp'] as int? ?? 0;
    final scenariosCompleted = progress?['scenariosCompleted'] as int? ?? 0;
    final streakDays = streakData?.currentStreak ?? 0;

    final scenarios = await _loadRecommendedScenarios(cefrLevel);

    return HomeState(
      totalXp: totalXp,
      scenariosCompleted: scenariosCompleted,
      streakDays: streakDays,
      displayName: displayName,
      cefrLevel: cefrLevel,
      recommendedScenarios: scenarios,
      isLoading: false,
    );
  }

  Future<List<Scenario>> _loadRecommendedScenarios(String cefrLevel) async {
    try {
      final scenarioService = FirestoreScenarioService();
      final allScenarios = await scenarioService.getScenarios();

      // Filter by CEFR level, then take up to 4 recommended.
      var filtered = allScenarios
          .where((s) => s.cefrLevel == cefrLevel)
          .toList();

      // Sort by completionCount descending (popular first).
      filtered.sort((a, b) => b.completionCount.compareTo(a.completionCount));

      // If no scenarios match the CEFR level, show popular ones.
      if (filtered.isEmpty) {
        filtered = allScenarios
            .toList()
          ..sort((a, b) => b.completionCount.compareTo(a.completionCount));
      }

      return filtered.take(4).toList();
    } catch (_) {
      return [];
    }
  }

  void refresh() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final homeProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
