import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/level_config.dart';
import '../../../core/providers/auth_provider.dart';

/// A single entry in the leaderboard.
class LeaderboardEntry {
  final int rank;
  final String uid;
  final String displayName;
  final int totalXp;
  final int currentLevel;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.uid,
    required this.displayName,
    required this.totalXp,
    required this.currentLevel,
    this.isCurrentUser = false,
  });
}

/// ViewModel for the leaderboard screen.
///
/// Queries Firestore for top users ordered by total XP.
class LeaderboardViewModel extends AsyncNotifier<List<LeaderboardEntry>> {
  @override
  Future<List<LeaderboardEntry>> build() async {
    return _loadLeaderboard();
  }

  Future<List<LeaderboardEntry>> _loadLeaderboard() async {
    final currentUser = ref.read(currentUserProvider);
    final currentUid = currentUser?.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('progress.totalXp', descending: true)
          .limit(50)
          .get();

      final entries = <LeaderboardEntry>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final profile = data['profile'] as Map<String, dynamic>?;
        final progress = data['progress'] as Map<String, dynamic>?;

        final totalXp = progress?['totalXp'] as int? ?? 0;
        final levelInfo = LevelConfig.getLevelInfo(totalXp);

        entries.add(LeaderboardEntry(
          rank: i + 1,
          uid: doc.id,
          displayName: profile?['displayName'] as String? ?? 'Learner',
          totalXp: totalXp,
          currentLevel: levelInfo.currentLevel,
          isCurrentUser: doc.id == currentUid,
        ));
      }

      return entries;
    } catch (_) {
      // Firestore query failed — return empty leaderboard.
      return [];
    }
  }

  void refresh() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final leaderboardViewModelProvider =
    AsyncNotifierProvider<LeaderboardViewModel, List<LeaderboardEntry>>(
  LeaderboardViewModel.new,
);
