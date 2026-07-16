import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_data.dart';

const _kOnboardingCompletedKey = 'onboarding_completed';

/// State for the onboarding flow.
class OnboardingState {
  final int currentPage;
  final String? selectedLanguage;
  final String? selectedCefrLevel;
  final String? selectedGoal;

  const OnboardingState({
    this.currentPage = 0,
    this.selectedLanguage,
    this.selectedCefrLevel,
    this.selectedGoal,
  });

  OnboardingState copyWith({
    int? currentPage,
    String? selectedLanguage,
    String? selectedCefrLevel,
    String? selectedGoal,
    bool clearLanguage = false,
    bool clearCefrLevel = false,
    bool clearGoal = false,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      selectedLanguage: clearLanguage ? null : (selectedLanguage ?? this.selectedLanguage),
      selectedCefrLevel: clearCefrLevel ? null : (selectedCefrLevel ?? this.selectedCefrLevel),
      selectedGoal: clearGoal ? null : (selectedGoal ?? this.selectedGoal),
    );
  }

  bool get canProceed {
    switch (currentPage) {
      case 0:
        return selectedLanguage != null;
      case 1:
        return selectedCefrLevel != null;
      case 2:
        return selectedGoal != null;
      default:
        return false;
    }
  }

  bool get isLastPage => currentPage == 2;
}

/// ViewModel for the onboarding flow.
///
/// Synchronous state — all async work (SharedPreferences writes) is
/// fire-and-forget from methods; [build] returns the initial state directly.
class OnboardingViewModel extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void setCefrLevel(String level) {
    state = state.copyWith(selectedCefrLevel: level);
  }

  void setGoal(String goal) {
    state = state.copyWith(selectedGoal: goal);
  }

  void nextPage() {
    if (state.currentPage < 2) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Save selections to SharedPreferences and mark onboarding as completed.
  Future<void> saveAndComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_language', state.selectedLanguage ?? 'English');
    await prefs.setString('onboarding_cefr', state.selectedCefrLevel ?? 'A1');
    await prefs.setString('onboarding_goal', state.selectedGoal ?? 'Travel');
    await prefs.setBool(_kOnboardingCompletedKey, true);
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
}

final onboardingProvider =
    NotifierProvider<OnboardingViewModel, OnboardingState>(
  OnboardingViewModel.new,
);
