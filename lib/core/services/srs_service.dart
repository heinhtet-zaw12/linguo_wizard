import 'package:linguo_wizard/core/models/srs_item.dart';
import 'package:linguo_wizard/core/services/firestore_service.dart';
import 'package:linguo_wizard/features/feedback/models/score_data.dart';

/// Spaced Repetition System (SRS) engine.
///
/// Manages SRS items for grammar, vocabulary, and phrases.
/// Extracts learning items from evaluation scores and schedules reviews.
class SrsService {
  final FirestoreService _firestore;

  SrsService(this._firestore);

  /// Returns all SRS items due for review.
  ///
  /// Queries items where nextReview <= now, sorted by nextReview ascending.
  Future<List<SrsItem>> getDueItems(String uid) async {
    final items = await _firestore.getSrsItems(uid);
    final now = DateTime.now();
    final dueItems = items.where((item) => item.nextReview.isBefore(now)).toList();
    dueItems.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    return dueItems;
  }

  /// Extracts learning items from a score and adds them to the SRS deck.
  ///
  /// Creates SRS items from grammar corrections. Checks for duplicates
  /// before saving to avoid redundant items.
  Future<void> addItemsFromScore(String uid, ScoreData score) async {
    final existingItems = await _firestore.getSrsItems(uid);
    final existingTexts = existingItems.map((item) => item.text.toLowerCase()).toSet();

    for (final correction in score.grammarCorrections) {
      // Skip if item already exists
      if (existingTexts.contains(correction.original.toLowerCase())) continue;

      final item = SrsItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: correction.original,
        category: 'grammar',
        nextReview: DateTime.now().add(const Duration(days: 1)),
      );

      await _firestore.saveSrsItem(uid, item);
    }
  }

  /// Reviews an SRS item with the given quality score.
  ///
  /// Quality scale: 0 = complete fail, 5 = perfect recall.
  /// Updates the item's SM-2 parameters and saves back to Firestore.
  Future<void> reviewItem(String uid, SrsItem item, int quality) async {
    final updated = item.review(quality);
    await _firestore.saveSrsItem(uid, updated);
  }

  /// Deletes an SRS item from the user's collection.
  Future<void> deleteItem(String uid, String itemId) async {
    await _firestore.deleteSrsItem(uid, itemId);
  }
}
