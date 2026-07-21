/// Badge definitions for the gamification system.
///
/// Badges are categorized as milestone-based (streak, XP, scenarios) or
/// skill achievements (perfect score, no mistakes, fast learner).
/// New badges can be added via this config without code changes.
library;

/// Category of badge: milestone-based or skill-based achievement.
enum BadgeCategory {
  milestone,
  skill,
}

/// Defines the condition that must be met to earn a badge.
class BadgeCondition {
  /// The type of condition: 'streak', 'xp', 'scenarios', 'perfect_score',
  /// 'no_mistakes', 'fast_learner'.
  final String type;

  /// The threshold value to meet or exceed for the condition.
  final int threshold;

  const BadgeCondition({
    required this.type,
    required this.threshold,
  });
}

/// A single badge definition.
class BadgeDefinition {
  /// Unique identifier for this badge.
  final String id;

  /// Display name of the badge.
  final String name;

  /// Description of how to earn the badge.
  final String description;

  /// Path to the badge icon asset.
  final String iconPath;

  /// Category of badge (milestone or skill).
  final BadgeCategory category;

  /// Condition that must be met to earn this badge.
  final BadgeCondition condition;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.category,
    required this.condition,
  });
}

/// All available badge definitions.
///
/// To add a new badge, append to this list. No other code changes needed.
const List<BadgeDefinition> badgeDefinitions = [
  BadgeDefinition(
    id: 'streak_3',
    name: 'First Steps',
    description: 'Maintain a 3-day streak',
    iconPath: 'assets/badges/streak_3.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'streak', threshold: 3),
  ),
  BadgeDefinition(
    id: 'streak_7',
    name: 'On Fire',
    description: 'Maintain a 7-day streak',
    iconPath: 'assets/badges/streak_7.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'streak', threshold: 7),
  ),
  BadgeDefinition(
    id: 'xp_500',
    name: 'XP Hunter',
    description: 'Earn 500 total XP',
    iconPath: 'assets/badges/xp_500.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'xp', threshold: 500),
  ),
  BadgeDefinition(
    id: 'xp_2000',
    name: 'XP Legend',
    description: 'Earn 2000 total XP',
    iconPath: 'assets/badges/xp_2000.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'xp', threshold: 2000),
  ),
  BadgeDefinition(
    id: 'scenarios_10',
    name: 'Explorer',
    description: 'Complete 10 scenarios',
    iconPath: 'assets/badges/scenarios_10.png',
    category: BadgeCategory.milestone,
    condition: BadgeCondition(type: 'scenarios', threshold: 10),
  ),
  BadgeDefinition(
    id: 'perfect_score',
    name: 'Perfectionist',
    description: 'Score 100 on any scenario',
    iconPath: 'assets/badges/perfect_score.png',
    category: BadgeCategory.skill,
    condition: BadgeCondition(type: 'perfect_score', threshold: 100),
  ),
  BadgeDefinition(
    id: 'no_mistakes',
    name: 'Flawless',
    description: 'Complete a scenario with 0 grammar corrections',
    iconPath: 'assets/badges/no_mistakes.png',
    category: BadgeCategory.skill,
    condition: BadgeCondition(type: 'no_mistakes', threshold: 0),
  ),
  BadgeDefinition(
    id: 'fast_learner',
    name: 'Quick Study',
    description: 'Complete a scenario in under 5 minutes',
    iconPath: 'assets/badges/fast_learner.png',
    category: BadgeCategory.skill,
    condition: BadgeCondition(type: 'fast_learner', threshold: 300),
  ),
];
