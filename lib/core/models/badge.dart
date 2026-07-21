import 'package:linguo_wizard/core/config/badge_config.dart';

/// Represents an earned badge instance.
///
/// This is different from [BadgeDefinition] — it represents a badge
/// that has been earned by a user, with the time it was earned.
class Badge {
  /// Unique identifier matching the badge definition ID.
  final String id;

  /// When this badge was earned.
  final DateTime earnedAt;

  /// The badge definition (nullable for deserialization).
  final BadgeDefinition? definition;

  const Badge({
    required this.id,
    required this.earnedAt,
    this.definition,
  });

  /// Creates a [Badge] from a JSON map.
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String? ?? '',
      earnedAt: json['earnedAt'] is String
          ? DateTime.parse(json['earnedAt'] as String)
          : (json['earnedAt'] as DateTime? ?? DateTime.now()),
    );
  }

  /// Converts to a JSON map for Firestore serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}
