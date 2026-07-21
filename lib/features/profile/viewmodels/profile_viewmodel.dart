import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/level_config.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

/// Immutable state for the profile screen.
class ProfileState {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String cefrLevel;
  final int totalXp;
  final String levelName;
  final int currentStreak;
  final int scenariosCompleted;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.cefrLevel = 'A1',
    this.totalXp = 0,
    this.levelName = 'Beginner',
    this.currentStreak = 0,
    this.scenariosCompleted = 0,
    this.isLoading = true,
    this.error,
  });

  ProfileState copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    String? cefrLevel,
    int? totalXp,
    String? levelName,
    int? currentStreak,
    int? scenariosCompleted,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearPhoto = false,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      cefrLevel: cefrLevel ?? this.cefrLevel,
      totalXp: totalXp ?? this.totalXp,
      levelName: levelName ?? this.levelName,
      currentStreak: currentStreak ?? this.currentStreak,
      scenariosCompleted: scenariosCompleted ?? this.scenariosCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// ViewModel for the profile screen.
///
/// Loads user profile data, gamification stats, and provides sign-out.
class ProfileViewModel extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) {
      return const ProfileState(isLoading: false, error: 'Sign in to view profile');
    }

    try {
      return await _loadProfile(user.uid);
    } catch (e) {
      return ProfileState(isLoading: false, error: e.toString());
    }
  }

  Future<ProfileState> _loadProfile(String uid) async {
    final firestore = ref.read(firestoreServiceProvider);

    final results = await Future.wait<Object?>([
      firestore.getUserProfile(uid),
      firestore.getTotalXp(uid),
      firestore.getStreak(uid),
      firestore.getScenariosCompleted(uid),
    ]);

    final profile = results[0] as Map<String, dynamic>?;
    final totalXp = results[1] as int;
    final streak = results[2] as dynamic;
    final scenariosCompleted = results[3] as int;

    final levelInfo = LevelConfig.getLevelInfo(totalXp);

    return ProfileState(
      displayName: profile?['displayName'] as String? ?? 'User',
      email: profile?['email'] as String? ?? '',
      photoUrl: profile?['photoUrl'] as String?,
      cefrLevel: profile?['cefrLevel'] as String? ?? 'A1',
      totalXp: totalXp,
      levelName: levelInfo.currentLevelName,
      currentStreak: streak?.currentStreak ?? 0,
      scenariosCompleted: scenariosCompleted,
      isLoading: false,
    );
  }

  Future<void> signOut() async {
    final authViewModel = ref.read(authProvider.notifier);
    await authViewModel.signOut();
  }

  void refresh() {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }
}

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);
