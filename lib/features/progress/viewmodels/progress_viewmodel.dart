import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/level_config.dart';
import '../../../core/models/badge.dart';
import '../../../core/models/mistake_record.dart';
import '../../../core/models/streak_data.dart';
import '../../../core/providers/auth_provider.dart';

/// Summary statistics for mistakes over the last 7 days.
class MistakeStats {
  final int totalMistakes;
  final int grammarMistakes;
  final int vocabularyGaps;
  final double accuracyPercent;

  const MistakeStats({
    required this.totalMistakes,
    required this.grammarMistakes,
    required this.vocabularyGaps,
    required this.accuracyPercent,
  });

  static const empty = MistakeStats(
    totalMistakes: 0,
    grammarMistakes: 0,
    vocabularyGaps: 0,
    accuracyPercent: 100.0,
  );
}

/// Immutable state for the progress screen.
class ProgressState {
  final int totalXp;
  final int currentLevel;
  final String levelName;
  final double levelProgress;
  final int currentStreak;
  final int longestStreak;
  final int scenariosCompleted;
  final List<Badge> earnedBadges;
  final MistakeStats mistakeStats;
  final bool isLoading;
  final String? error;

  const ProgressState({
    this.totalXp = 0,
    this.currentLevel = 0,
    this.levelName = 'Beginner',
    this.levelProgress = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.scenariosCompleted = 0,
    this.earnedBadges = const [],
    this.mistakeStats = MistakeStats.empty,
    this.isLoading = true,
    this.error,
  });

  ProgressState copyWith({
    int? totalXp,
    int? currentLevel,
    String? levelName,
    double? levelProgress,
    int? currentStreak,
    int? longestStreak,
    int? scenariosCompleted,
    List<Badge>? earnedBadges,
    MistakeStats? mistakeStats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProgressState(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      levelName: levelName ?? this.levelName,
      levelProgress: levelProgress ?? this.levelProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      scenariosCompleted: scenariosCompleted ?? this.scenariosCompleted,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      mistakeStats: mistakeStats ?? this.mistakeStats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for the progress screen.
///
/// Loads user gamification data from Firestore: XP, level, streak,
/// badges, and mistake summary for the last 7 days.
class ProgressViewModel extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) {
      return const ProgressState(isLoading: false, error: 'Sign in to view progress');
    }

    try {
      return await _loadProgress(user.uid);
    } catch (e) {
      return ProgressState(isLoading: false, error: e.toString());
    }
  }

  Future<ProgressState> _loadProgress(String uid) async {
    final firestore = ref.read(firestoreServiceProvider);

    // Load progress data concurrently.
    final results = await Future.wait<Object?>([
      firestore.getTotalXp(uid),
      firestore.getScenariosCompleted(uid),
      firestore.getStreak(uid),
      firestore.getEarnedBadges(uid),
      firestore.getMistakes(uid, days: 7),
    ]);

    final totalXp = results[0] as int;
    final scenariosCompleted = results[1] as int;
    final streak = results[2] as StreakData?;
    final earnedBadges = results[3] as List<Badge>;
    final mistakes = results[4] as List<MistakeRecord>;

    // Calculate level from XP.
    final levelInfo = LevelConfig.getLevelInfo(totalXp);

    // Build mistake stats.
    final mistakeStats = _buildMistakeStats(mistakes);

    return ProgressState(
      totalXp: totalXp,
      currentLevel: levelInfo.currentLevel,
      levelName: levelInfo.currentLevelName,
      levelProgress: levelInfo.progress,
      currentStreak: streak?.currentStreak ?? 0,
      longestStreak: streak?.longestStreak ?? 0,
      scenariosCompleted: scenariosCompleted,
      earnedBadges: earnedBadges,
      mistakeStats: mistakeStats,
      isLoading: false,
    );
  }

  MistakeStats _buildMistakeStats(List<MistakeRecord> mistakes) {
    if (mistakes.isEmpty) {
      return const MistakeStats(
        totalMistakes: 0,
        grammarMistakes: 0,
        vocabularyGaps: 0,
        accuracyPercent: 100.0,
      );
    }

    final total = mistakes.length;
    final grammar = mistakes.where((m) => m.category == 'grammar').length;
    final vocabulary = mistakes.where((m) => m.category == 'vocabulary').length;

    // Accuracy = percentage of non-mistake turns (approximated).
    // With only mistake data, we estimate based on total scenarios.
    // A simple heuristic: if user has completed scenarios, accuracy =
    // max(0, 100 - (totalMistakes * 5)). Clamp to 0-100.
    final accuracyPercent = (100.0 - (total * 5.0)).clamp(0.0, 100.0);

    return MistakeStats(
      totalMistakes: total,
      grammarMistakes: grammar,
      vocabularyGaps: vocabulary,
      accuracyPercent: accuracyPercent,
    );
  }

  void refresh() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final progressViewModelProvider =
    AsyncNotifierProvider<ProgressViewModel, ProgressState>(ProgressViewModel.new);
