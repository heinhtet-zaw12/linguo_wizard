/// Streak tracking data model for daily engagement.
///
/// Tracks current streak, longest streak, and last activity date.
/// Streak resets at midnight in the user's local timezone.
library;

/// Data model for streak tracking.
class StreakData {
  /// Current consecutive days of activity.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// Last activity date as 'YYYY-MM-DD' string.
  final String lastActivityDate;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
  });

  /// Updates streak for today.
  ///
  /// - If today == lastActivityDate: no change (already counted).
  /// - If today == yesterday: increment streak.
  /// - Otherwise: reset streak to 1.
  /// Always updates longestStreak if new streak is longer.
  StreakData updateForToday(String today) {
    if (today == lastActivityDate) {
      // Already counted today
      return this;
    }

    // Calculate yesterday as YYYY-MM-DD string
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    int newStreak;
    if (today == yesterdayStr) {
      // Consecutive day — increment
      newStreak = currentStreak + 1;
    } else {
      // Streak broken — reset to 1
      newStreak = 1;
    }

    // Update longest streak if new streak is longer
    final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

    return StreakData(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastActivityDate: today,
    );
  }

  /// Creates a [StreakData] from a JSON map.
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] as String? ?? '',
    );
  }

  /// Converts to a JSON map for Firestore serialization.
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate,
    };
  }
}
