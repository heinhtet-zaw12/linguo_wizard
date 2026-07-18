import 'package:cloud_firestore/cloud_firestore.dart';

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
}
