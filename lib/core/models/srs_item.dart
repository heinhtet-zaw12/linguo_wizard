/// Spaced Repetition System (SRS) item model.
///
/// Tracks grammar, vocabulary, and phrase items for spaced repetition review.
/// Implements the SM-2 algorithm for calculating review intervals.
library;

/// A single item in the spaced repetition system.
class SrsItem {
  /// Unique identifier for this item.
  final String id;

  /// The text content (word, phrase, or grammar correction).
  final String text;

  /// Category: 'vocabulary', 'grammar', or 'phrase'.
  final String category;

  /// Number of consecutive successful reviews.
  final int repetitions;

  /// Ease factor for interval calculation (minimum 1.3).
  final double easeFactor;

  /// Current interval in days until next review.
  final int interval;

  /// When this item is next due for review.
  final DateTime nextReview;

  /// Quality of the last review (0-5).
  final int quality;

  const SrsItem({
    required this.id,
    required this.text,
    required this.category,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    required this.nextReview,
    this.quality = 0,
  });

  /// Whether this item is due for review now.
  bool get isDue => DateTime.now().isAfter(nextReview);

  /// Reviews this item using the SM-2 algorithm.
  ///
  /// Quality scale: 0 = complete fail, 5 = perfect recall.
  /// - quality < 3: reset (repetitions=0, interval=1)
  /// - quality >= 3: advance (first review interval=1, second interval=6,
  ///   then interval = interval * easeFactor)
  /// Ease factor is updated: EF = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
  /// Minimum ease factor is 1.3.
  SrsItem review(int quality) {
    int newRepetitions;
    int newInterval;
    double newEaseFactor;

    if (quality < 3) {
      // Failed review — reset
      newRepetitions = 0;
      newInterval = 1;
      newEaseFactor = easeFactor;
    } else {
      // Successful review — advance
      newRepetitions = repetitions + 1;

      if (newRepetitions == 1) {
        newInterval = 1;
      } else if (newRepetitions == 2) {
        newInterval = 6;
      } else {
        newInterval = (interval * easeFactor).round();
      }

      // Update ease factor
      newEaseFactor =
          easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    }

    return SrsItem(
      id: id,
      text: text,
      category: category,
      repetitions: newRepetitions,
      easeFactor: newEaseFactor,
      interval: newInterval,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
      quality: quality,
    );
  }

  /// Creates an [SrsItem] from a JSON map.
  factory SrsItem.fromJson(Map<String, dynamic> json) {
    return SrsItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'vocabulary',
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      nextReview: json['nextReview'] is String
          ? DateTime.parse(json['nextReview'] as String)
          : (json['nextReview'] as DateTime? ?? DateTime.now()),
      quality: json['quality'] as int? ?? 0,
    );
  }

  /// Converts to a JSON map for Firestore serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReview': nextReview.toIso8601String(),
      'quality': quality,
    };
  }
}
