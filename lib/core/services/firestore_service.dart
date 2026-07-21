import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguo_wizard/core/models/badge.dart';
import 'package:linguo_wizard/core/models/mistake_record.dart';
import 'package:linguo_wizard/core/models/srs_item.dart';
import 'package:linguo_wizard/core/models/streak_data.dart';

/// Stateless service wrapping Cloud Firestore for user data persistence.
///
/// Provides CRUD operations for user profiles, preferences, progress,
/// and scenario results. All writes use [FieldValue.serverTimestamp]
/// for consistent server-side timestamps.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new user profile document.
  Future<void> createUserProfile(
    String uid, {
    required String displayName,
    String? email,
    String? photoUrl,
  }) {
    return _db.collection('users').doc(uid).set({
      'profile': {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      },
    });
  }

  /// Update an existing user profile (must already exist).
  Future<void> updateUserProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
  }) {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['profile.displayName'] = displayName;
    if (photoUrl != null) updates['profile.photoUrl'] = photoUrl;
    return _db.collection('users').doc(uid).update(updates);
  }

  /// Read the user profile subfield map, or null if the document does not exist.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['profile'] as Map<String, dynamic>?;
  }

  /// Save user preferences as a map field on the user document.
  Future<void> savePreferences(
    String uid, {
    required String language,
    required String cefrLevel,
    required String goal,
  }) {
    return _db.collection('users').doc(uid).update({
      'preferences': {
        'language': language,
        'cefrLevel': cefrLevel,
        'goal': goal,
      },
    });
  }

  /// Read the user preferences map, or null if not set.
  Future<Map<String, dynamic>?> getPreferences(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['preferences'] as Map<String, dynamic>?;
  }

  /// Save user progress (XP, scenarios completed, last activity).
  Future<void> saveProgress(
    String uid, {
    required int totalXp,
    required int scenariosCompleted,
    DateTime? lastScenarioAt,
  }) {
    return _db.collection('users').doc(uid).update({
      'progress': {
        'totalXp': totalXp,
        'scenariosCompleted': scenariosCompleted,
        'lastScenarioAt':
            lastScenarioAt != null ? Timestamp.fromDate(lastScenarioAt) : FieldValue.serverTimestamp(),
      },
    });
  }

  /// Read the user progress map, or null if not set.
  Future<Map<String, dynamic>?> getProgress(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['progress'] as Map<String, dynamic>?;
  }

  /// Save a scenario result (best score, attempts, individual scores).
  Future<void> saveScenarioResult(
    String uid,
    String scenarioId, {
    required double bestScore,
    required int attempts,
    required List<Map<String, dynamic>> scores,
  }) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('scenarios')
        .doc(scenarioId)
        .set({
      'bestScore': bestScore,
      'attempts': attempts,
      'scores': scores,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Read all scenario result documents for a user.
  Future<List<Map<String, dynamic>>> getScenarios(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('scenarios').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
  }

  // ─── Gamification CRUD ───

  /// Read the user's streak data, or null if not set.
  Future<StreakData?> getStreak(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()?['progress'];
    if (data == null) return null;
    return StreakData.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Save streak data to the user's progress document (merge: true).
  Future<void> saveStreak(String uid, StreakData streak) {
    return _db.collection('users').doc(uid).set({
      'progress': streak.toJson(),
    }, SetOptions(merge: true));
  }

  /// Read the user's total XP, default 0.
  Future<int> getTotalXp(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return 0;
    return doc.data()?['progress']?['totalXp'] as int? ?? 0;
  }

  /// Increment total XP by the given amount.
  Future<void> addXp(String uid, int xp) {
    return _db.collection('users').doc(uid).set({
      'progress': {
        'totalXp': FieldValue.increment(xp),
      },
    }, SetOptions(merge: true));
  }

  /// Read the user's scenarios completed count, default 0.
  Future<int> getScenariosCompleted(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return 0;
    return doc.data()?['progress']?['scenariosCompleted'] as int? ?? 0;
  }

  /// Increment scenarios completed by 1.
  Future<void> incrementScenariosCompleted(String uid) {
    return _db.collection('users').doc(uid).set({
      'progress': {
        'scenariosCompleted': FieldValue.increment(1),
      },
    }, SetOptions(merge: true));
  }

  /// Read all earned badges for a user.
  Future<List<Badge>> getEarnedBadges(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .get();
    return snapshot.docs
        .map((doc) => Badge.fromJson(doc.data()))
        .toList();
  }

  /// Save a badge to the user's badges subcollection.
  Future<void> saveBadge(String uid, Badge badge) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badge.id)
        .set(badge.toJson());
  }

  /// Read all SRS items for a user.
  Future<List<SrsItem>> getSrsItems(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('srs_items')
        .get();
    return snapshot.docs
        .map((doc) => SrsItem.fromJson(doc.data()))
        .toList();
  }

  /// Save or update an SRS item in the user's subcollection.
  Future<void> saveSrsItem(String uid, SrsItem item) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('srs_items')
        .doc(item.id)
        .set(item.toJson());
  }

  /// Delete an SRS item from the user's subcollection.
  Future<void> deleteSrsItem(String uid, String itemId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('srs_items')
        .doc(itemId)
        .delete();
  }

  /// Read mistake records from the last [days] days.
  Future<List<MistakeRecord>> getMistakes(String uid, {int days = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('mistakes')
        .where('recordedAt', isGreaterThanOrEqualTo: cutoff.toIso8601String())
        .orderBy('recordedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => MistakeRecord.fromJson(doc.data()))
        .toList();
  }

  /// Save a mistake record to the user's subcollection.
  Future<void> saveMistake(String uid, MistakeRecord mistake) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('mistakes')
        .doc(mistake.id)
        .set(mistake.toJson());
  }

  /// Delete mistake records older than 7 days (rolling window).
  Future<void> cleanupOldMistakes(String uid) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('mistakes')
        .where('recordedAt', isLessThan: cutoff.toIso8601String())
        .get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
