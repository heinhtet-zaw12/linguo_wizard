/// Level progression configuration for the gamification system.
///
/// Defines 5 levels with linear XP progression (500 XP per level).
library;

/// A single level definition.
class LevelRecord {
  /// Display name of the level.
  final String name;

  /// XP required to reach this level.
  final int xpRequired;

  /// Path to the level icon asset.
  final String iconPath;

  const LevelRecord({
    required this.name,
    required this.xpRequired,
    required this.iconPath,
  });
}

/// Information about a user's current level and progress.
class LevelInfo {
  /// Zero-based index of the current level.
  final int currentLevel;

  /// Name of the current level.
  final String currentLevelName;

  /// Name of the next level (null if at max level).
  final String? nextLevelName;

  /// Progress fraction toward the next level (0.0 to 1.0).
  final double progress;

  const LevelInfo({
    required this.currentLevel,
    required this.currentLevelName,
    this.nextLevelName,
    required this.progress,
  });
}

/// Level progression configuration.
///
/// 5 levels with linear progression: 0, 500, 1000, 1500, 2000 XP.
class LevelConfig {
  LevelConfig._();

  /// All level definitions in order.
  static const List<LevelRecord> levels = [
    LevelRecord(name: 'Beginner', xpRequired: 0, iconPath: 'assets/levels/beginner.png'),
    LevelRecord(name: 'Elementary', xpRequired: 500, iconPath: 'assets/levels/elementary.png'),
    LevelRecord(name: 'Intermediate', xpRequired: 1000, iconPath: 'assets/levels/intermediate.png'),
    LevelRecord(name: 'Advanced', xpRequired: 1500, iconPath: 'assets/levels/advanced.png'),
    LevelRecord(name: 'Master', xpRequired: 2000, iconPath: 'assets/levels/master.png'),
  ];

  /// Returns level information based on total XP.
  ///
  /// Provides current level index, name, next level name, and
  /// progress fraction toward the next level.
  static LevelInfo getLevelInfo(int totalXp) {
    // Find the current level by iterating from highest to lowest
    for (int i = levels.length - 1; i >= 0; i--) {
      if (totalXp >= levels[i].xpRequired) {
        final currentLevelName = levels[i].name;

        // If at max level, progress is 1.0
        if (i == levels.length - 1) {
          return LevelInfo(
            currentLevel: i,
            currentLevelName: currentLevelName,
            nextLevelName: null,
            progress: 1.0,
          );
        }

        // Calculate progress toward next level
        final currentLevelXp = levels[i].xpRequired;
        final nextLevelXp = levels[i + 1].xpRequired;
        final xpInLevel = totalXp - currentLevelXp;
        final xpForLevel = nextLevelXp - currentLevelXp;
        final progress = (xpInLevel / xpForLevel).clamp(0.0, 1.0);

        return LevelInfo(
          currentLevel: i,
          currentLevelName: currentLevelName,
          nextLevelName: levels[i + 1].name,
          progress: progress,
        );
      }
    }

    // Should never reach here (level 0 is 0 XP), but handle defensively
    return const LevelInfo(
      currentLevel: 0,
      currentLevelName: 'Beginner',
      nextLevelName: 'Elementary',
      progress: 0.0,
    );
  }
}
