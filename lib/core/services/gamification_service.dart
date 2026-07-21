import 'package:linguo_wizard/core/config/badge_config.dart';
import 'package:linguo_wizard/core/config/level_config.dart';
import 'package:linguo_wizard/core/models/badge.dart';
import 'package:linguo_wizard/core/models/streak_data.dart';
import 'package:linguo_wizard/core/services/firestore_service.dart';
import 'package:linguo_wizard/features/feedback/models/score_data.dart';

/// Coordinates gamification logic: streaks, XP, levels, and badges.
///
/// Injects [FirestoreService] for data persistence. All methods are
/// async and follow the fire-and-forget pattern for non-critical writes.
class GamificationService {
  final FirestoreService _firestore;

  GamificationService(this._firestore);

  /// Updates the user's streak for today.
  ///
  /// Loads current streak from Firestore, calculates today's date
  /// in the user's local timezone, and updates the streak.
  /// Returns the updated [StreakData].
  Future<StreakData> updateStreak(String uid) async {
    final existing = await _firestore.getStreak(uid);

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final streakData = existing ?? const StreakData(
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: '',
    );

    final updated = streakData.updateForToday(today);
    await _firestore.saveStreak(uid, updated);

    return updated;
  }

  /// Returns the user's current level index based on total XP.
  int calculateLevel(int totalXp) {
    return LevelConfig.getLevelInfo(totalXp).currentLevel;
  }

  /// Checks badge eligibility and returns newly earned badges.
  ///
  /// Compares current user stats against all badge definitions.
  /// Newly earned badges are saved to Firestore (fire-and-forget).
  Future<List<Badge>> checkBadges(
    String uid, {
    required int totalXp,
    required int currentStreak,
    required int scenariosCompleted,
    required ScoreData lastScore,
    Duration? scenarioDuration,
  }) async {
    final earnedBadges = await _firestore.getEarnedBadges(uid);
    final earnedIds = earnedBadges.map((b) => b.id).toSet();

    final newlyEarned = <Badge>[];

    for (final definition in badgeDefinitions) {
      if (earnedIds.contains(definition.id)) continue;

      bool conditionMet = false;
      final condition = definition.condition;

      switch (condition.type) {
        case 'streak':
          conditionMet = currentStreak >= condition.threshold;
          break;
        case 'xp':
          conditionMet = totalXp >= condition.threshold;
          break;
        case 'scenarios':
          conditionMet = scenariosCompleted >= condition.threshold;
          break;
        case 'perfect_score':
          conditionMet = lastScore.overallScore >= condition.threshold;
          break;
        case 'no_mistakes':
          conditionMet = lastScore.grammarCorrections.isEmpty;
          break;
        case 'fast_learner':
          if (scenarioDuration != null) {
            conditionMet =
                scenarioDuration.inSeconds < condition.threshold;
          }
          // If no duration provided, skip this badge
          break;
      }

      if (conditionMet) {
        final badge = Badge(
          id: definition.id,
          earnedAt: DateTime.now(),
          definition: definition,
        );
        newlyEarned.add(badge);
        // Fire-and-forget save
        _firestore.saveBadge(uid, badge);
      }
    }

    return newlyEarned;
  }

  /// Awards XP to the user and increments scenarios completed.
  ///
  /// Uses Firestore increment operations for atomic updates.
  Future<void> awardXp(String uid, int xp) async {
    await _firestore.addXp(uid, xp);
    await _firestore.incrementScenariosCompleted(uid);
  }
}
