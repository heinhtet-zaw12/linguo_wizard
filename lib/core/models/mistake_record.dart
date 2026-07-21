/// Mistake tracking data model for learning analytics.
///
/// Records grammar corrections and vocabulary gaps from scenario evaluations.
/// Stored in a Firestore subcollection with a 7-day rolling window.
library;

/// A single mistake record from a conversation evaluation.
class MistakeRecord {
  /// Unique identifier for this mistake.
  final String id;

  /// The original text that was incorrect.
  final String text;

  /// Category of mistake: 'grammar' or 'vocabulary'.
  final String category;

  /// The corrected version of the text.
  final String correctedText;

  /// Explanation of why the correction was made.
  final String explanation;

  /// ID of the scenario where this mistake occurred.
  final String scenarioId;

  /// When this mistake was recorded.
  final DateTime recordedAt;

  const MistakeRecord({
    required this.id,
    required this.text,
    required this.category,
    required this.correctedText,
    required this.explanation,
    required this.scenarioId,
    required this.recordedAt,
  });

  /// Creates a [MistakeRecord] from a JSON map.
  factory MistakeRecord.fromJson(Map<String, dynamic> json) {
    return MistakeRecord(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'grammar',
      correctedText: json['correctedText'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      scenarioId: json['scenarioId'] as String? ?? '',
      recordedAt: json['recordedAt'] is String
          ? DateTime.parse(json['recordedAt'] as String)
          : (json['recordedAt'] as DateTime? ?? DateTime.now()),
    );
  }

  /// Converts to a JSON map for Firestore serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'correctedText': correctedText,
      'explanation': explanation,
      'scenarioId': scenarioId,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}
