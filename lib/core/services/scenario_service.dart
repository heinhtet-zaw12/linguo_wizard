import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/scenario_selection/models/scenario.dart';

/// Service for fetching curated scenarios from Firestore with
/// SharedPreferences-based local caching for instant startup.
///
/// Pattern: load from cache instantly, then background-fetch from Firestore
/// if cache is stale (>24h). On the very first call (empty cache), blocks
/// on the Firestore fetch so the user sees content immediately.
///
/// Cache TTL: 24 hours. Stale data is replaced silently in the background.
class FirestoreScenarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'scenarios';
  static const String _cacheKey = 'cached_scenarios';
  static const String _cacheTimestampKey = 'cached_scenarios_timestamp';
  static const Duration _cacheTtl = Duration(hours: 24);

  /// Main entrypoint: loads from cache first (instant), then if stale,
  /// background-fetches from Firestore and updates the cache.
  ///
  /// On the very first call when cache is empty, blocks on the Firestore
  /// fetch so the UI has data to display.
  Future<List<Scenario>> getScenarios() async {
    final cached = await getCachedScenarios();

    if (cached.isNotEmpty) {
      // Cache has data — return it instantly.
      // Kick off a background refresh if stale.
      final stale = await isCacheStale();
      if (stale) {
        _refreshCache();
      }
      return cached;
    }

    // No cache — block on Firestore fetch.
    final fresh = await fetchAll();
    await cacheScenarios(fresh);
    return fresh;
  }

  /// Paginated fetch from Firestore. If [limit] is null, fetches all documents.
  /// Pass [startAfter] to paginate beyond the first page.
  Future<List<Scenario>> fetchAll({
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query =
        _db.collection(_collection).orderBy('completionCount', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Scenario.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Reads the cached scenario list from SharedPreferences.
  /// Returns an empty list if no cache exists or the cache is corrupted.
  Future<List<Scenario>> getCachedScenarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null || cached.isEmpty) return [];

      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => Scenario.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Cache corrupted — force re-fetch.
      return [];
    }
  }

  /// Serializes the scenario list to JSON and writes to SharedPreferences
  /// with a timestamp for staleness checking.
  Future<void> cacheScenarios(List<Scenario> scenarios) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = scenarios.map((s) => s.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
      await prefs.setString(
        _cacheTimestampKey,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (_) {
      // Cache write failure — non-critical, will retry on next fetch.
    }
  }

  /// Returns true if the cache is older than 24h or does not exist.
  Future<bool> isCacheStale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheTimestampKey);
      if (timestampStr == null || timestampStr.isEmpty) return true;

      final timestamp = DateTime.parse(timestampStr);
      return DateTime.now().toUtc().difference(timestamp) > _cacheTtl;
    } catch (_) {
      return true;
    }
  }

  /// Background-refresh: fetch all scenarios from Firestore and update cache.
  Future<void> _refreshCache() async {
    try {
      final fresh = await fetchAll();
      await cacheScenarios(fresh);
    } catch (_) {
      // Background refresh failed — stale cache is better than nothing.
    }
  }

  /// Returns the last [DocumentSnapshot] from a list of scenarios, used as
  /// a pagination cursor. Returns null if the list is empty.
  Future<DocumentSnapshot?> getLastVisible(List<Scenario> scenarios) async {
    if (scenarios.isEmpty) return null;

    final last = scenarios.last;
    final doc =
        await _db.collection(_collection).doc(last.id).get();
    return doc;
  }

  // ─── Custom scenarios (user-created) ───

  /// Save a custom scenario for a user.
  Future<void> saveCustomScenario({
    required String uid,
    required Scenario scenario,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('custom_scenarios')
        .doc(scenario.id)
        .set({
      ...scenario.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Load all custom scenarios for a user, newest first.
  Future<List<Scenario>> getCustomScenarios(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('custom_scenarios')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Scenario.fromJson(doc.data()))
        .toList();
  }

  /// Delete a custom scenario.
  Future<void> deleteCustomScenario(String uid, String scenarioId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('custom_scenarios')
        .doc(scenarioId)
        .delete();
  }

  // ─── Twist replay tracking ───

  /// Read the twist replay count for a scenario (defaults to 0).
  Future<int> getTwistReplayCount(String uid, String scenarioId) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('scenarios')
        .doc(scenarioId)
        .get();
    if (!doc.exists) return 0;
    return doc.data()?['twistReplayCount'] as int? ?? 0;
  }

  /// Increment twist replay count by 1 and record the timestamp.
  Future<void> incrementTwistReplay(String uid, String scenarioId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('scenarios')
        .doc(scenarioId)
        .set({
      'twistReplayCount': FieldValue.increment(1),
      'twistLastPlayedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
