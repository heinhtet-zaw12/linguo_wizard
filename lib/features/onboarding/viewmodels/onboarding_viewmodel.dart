import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';
import '../models/onboarding_data.dart';

const _kOnboardingCompletedKey = 'onboarding_completed';

/// State for the onboarding flow (2 steps: CEFR level → goal).
class OnboardingState {
  final int currentPage;
  final String? selectedCefrLevel;
  final String? selectedGoal;

  const OnboardingState({
    this.currentPage = 0,
    this.selectedCefrLevel,
    this.selectedGoal,
  });

  OnboardingState copyWith({
    int? currentPage,
    String? selectedCefrLevel,
    String? selectedGoal,
    bool clearCefrLevel = false,
    bool clearGoal = false,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      selectedCefrLevel: clearCefrLevel ? null : (selectedCefrLevel ?? this.selectedCefrLevel),
      selectedGoal: clearGoal ? null : (selectedGoal ?? this.selectedGoal),
    );
  }

  bool get canProceed {
    switch (currentPage) {
      case 0:
        return selectedCefrLevel != null;
      case 1:
        return selectedGoal != null;
      default:
        return false;
    }
  }

  bool get isLastPage => currentPage == 1;
}

/// ViewModel for the onboarding flow.
///
/// Synchronous state — all async work (SharedPreferences/Firestore writes) is
/// fire-and-forget from methods; [build] returns the initial state directly.
///
/// When the user is authenticated, preferences are synced to Firestore.
/// When the user is a guest, preferences are stored in SharedPreferences only.
class OnboardingViewModel extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Whether the current user is authenticated (not guest).
  bool get _isAuthenticated {
    final user = ref.read(currentUserProvider);
    return user != null && !user.isAnonymous;
  }

  void setCefrLevel(String level) {
    state = state.copyWith(selectedCefrLevel: level);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('onboarding_cefr', level);
    });
    if (_isAuthenticated) {
      final user = ref.read(currentUserProvider)!;
      final fs = ref.read(firestoreServiceProvider);
      fs.savePreferences(
        user.uid,
        language: 'English',
        cefrLevel: level,
        goal: state.selectedGoal ?? 'Travel',
      );
    }
  }

  void setGoal(String goal) {
    state = state.copyWith(selectedGoal: goal);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('onboarding_goal', goal);
    });
    if (_isAuthenticated) {
      final user = ref.read(currentUserProvider)!;
      final fs = ref.read(firestoreServiceProvider);
      fs.savePreferences(
        user.uid,
        language: 'English',
        cefrLevel: state.selectedCefrLevel ?? 'A1',
        goal: goal,
      );
    }
  }

  void nextPage() {
    if (state.currentPage < 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Save selections and mark onboarding as completed.
  ///
  /// Always sets the SharedPreferences flag (needed for local state).
  /// When authenticated, also syncs to Firestore and creates user profile.
  Future<void> saveAndComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_language', 'English');
    await prefs.setString('onboarding_cefr', state.selectedCefrLevel ?? 'A1');
    await prefs.setString('onboarding_goal', state.selectedGoal ?? 'Travel');
    await prefs.setBool(_kOnboardingCompletedKey, true);

    if (_isAuthenticated) {
      final user = ref.read(currentUserProvider)!;
      final fs = ref.read(firestoreServiceProvider);
      // Ensure profile exists, then save preferences.
      // Use updateUserProfile (not createUserProfile) to avoid overwriting
      // the displayName that was saved during sign-up.
      try {
        final existing = await fs.getUserProfile(user.uid);
        if (existing == null) {
          await fs.createUserProfile(
            user.uid,
            displayName: user.displayName ?? 'User',
            email: user.email,
          );
        } else if (user.displayName != null &&
            user.displayName != existing['displayName']) {
          // Sync display name from Firebase Auth if it changed (e.g. Google sign-in).
          await fs.updateUserProfile(user.uid, displayName: user.displayName);
        }
        await fs.savePreferences(
          user.uid,
          language: 'English',
          cefrLevel: state.selectedCefrLevel ?? 'A1',
          goal: state.selectedGoal ?? 'Travel',
        );
      } catch (_) {
        // Firestore sync failed — local prefs already saved, so no data loss.
      }
    }
  }

  /// Check whether the user has already completed onboarding.
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingCompletedKey) ?? false;
  }

  /// Read saved onboarding data (used to pre-filter scenarios).
  static Future<OnboardingData> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingData(
      targetLanguage: prefs.getString('onboarding_language') ?? 'English',
      cefrLevel: prefs.getString('onboarding_cefr') ?? 'A1',
      goal: prefs.getString('onboarding_goal') ?? 'Travel',
    );
  }

  /// Read saved CEFR level for scenario filtering.
  static Future<String> loadSavedCefrLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('onboarding_cefr') ?? 'A1';
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingViewModel, OnboardingState>(
  OnboardingViewModel.new,
);
