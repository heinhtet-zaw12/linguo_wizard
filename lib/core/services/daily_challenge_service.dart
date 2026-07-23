import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/scenario_selection/models/scenario.dart';
import 'ai_service.dart';

/// Manages UTC-based daily challenge rotation and Firestore seed document management.
///
/// The first user of a UTC day triggers AI generation of the challenge and writes
/// it to /challenges/YYYY-MM-DD. Subsequent users read the existing document.
/// This ensures globally consistent challenges without needing a Cloud Function.
class DailyChallengeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AiService _aiService;

  DailyChallengeService(this._aiService);

  /// Returns "YYYY-MM-DD" for the current UTC day.
  String get todayDateString {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Returns "YYYY-MM-DD" for the next UTC day.
  String get nextDateString {
    final now = DateTime.now().toUtc().add(const Duration(days: 1));
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Calculates duration remaining until next UTC midnight.
  Duration get timeUntilNextChallenge {
    final now = DateTime.now().toUtc();
    final nextMidnight = DateTime.utc(now.year, now.month, now.day + 1);
    final diff = nextMidnight.difference(now);
    // Clamp to non-negative duration.
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formats a countdown [Duration] into "{X}h remaining" or "{X}m remaining".
  String formatCountdown(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h remaining';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m remaining';
    }
    return 'Ended — new challenge tomorrow';
  }

  /// Loads today's challenge from Firestore, or generates a new one
  /// if none exists (first user of UTC day).
  Future<Scenario?> getOrCreateDailyChallenge({required String uid}) async {
    final dateStr = todayDateString;
    final docRef = _db.collection('challenges').doc(dateStr);
    final doc = await docRef.get();

    if (doc.exists) {
      // Challenge already exists — return it.
      final data = doc.data()!;
      return Scenario.fromJson(data);
    }

    // First user of UTC day: generate the challenge.
    // Pick a random curated scenario as the base.
    final allScenarios = await _loadAllCuratedScenarios();
    if (allScenarios.isEmpty) return null;

    final random = Random();
    final baseScenario = allScenarios[random.nextInt(allScenarios.length)];

    // Generate variation via Gemini.
    final challengeJson = await _aiService.generateDailyChallenge(
      baseScenario: baseScenario,
    );

    // Construct Scenario from generated data.
    final challenge = Scenario(
      id: 'challenge_$dateStr',
      title: challengeJson['title'] as String,
      description: challengeJson['description'] as String,
      personaName: challengeJson['personaName'] as String,
      personaDescription: challengeJson['personaDescription'] as String,
      goalDescription: challengeJson['goalDescription'] as String,
      cefrLevel: baseScenario.cefrLevel,
      category: 'daily-challenge',
      openingMessage: challengeJson['openingMessage'] as String,
      tags: [...baseScenario.tags, 'daily-challenge'],
      difficultyRating: baseScenario.difficultyRating,
      isFeatured: false,
      completionCount: 0,
    );

    // Save to Firestore for subsequent users.
    await docRef.set({
      ...challenge.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'generatedBy': uid,
    });

    return challenge;
  }

  /// Loads curated scenarios from Firestore for random selection.
  Future<List<Scenario>> _loadAllCuratedScenarios() async {
    final snapshot = await _db.collection('scenarios').get();
    return snapshot.docs
        .map((doc) => Scenario.fromJson(doc.data()))
        .toList();
  }

  /// Check if a specific user has completed today's challenge.
  Future<bool> hasCompletedTodayChallenge(String uid) async {
    final dateStr = todayDateString;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('scenarios')
        .doc('challenge_$dateStr')
        .get();
    return doc.exists && doc.data()?['completed'] == true;
  }

  /// Mark today's challenge as completed for a user.
  Future<void> markChallengeCompleted(String uid) async {
    final dateStr = todayDateString;
    await _db
        .collection('users')
        .doc(uid)
        .collection('scenarios')
        .doc('challenge_$dateStr')
        .set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
