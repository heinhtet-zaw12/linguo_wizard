import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linguo_wizard/features/onboarding/viewmodels/onboarding_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingState', () {
    test('canProceed returns false on page 0 with no language', () {
      const state = OnboardingState(currentPage: 0);
      expect(state.canProceed, isFalse);
    });

    test('canProceed returns true on page 0 with language selected', () {
      const state = OnboardingState(currentPage: 0, selectedLanguage: 'English');
      expect(state.canProceed, isTrue);
    });

    test('canProceed returns true on page 1 with CEFR selected', () {
      const state = OnboardingState(currentPage: 1, selectedCefrLevel: 'B1');
      expect(state.canProceed, isTrue);
    });

    test('canProceed returns true on page 2 with goal selected', () {
      const state = OnboardingState(currentPage: 2, selectedGoal: 'Travel');
      expect(state.canProceed, isTrue);
    });

    test('isLastPage returns true only on page 2', () {
      expect(const OnboardingState(currentPage: 0).isLastPage, isFalse);
      expect(const OnboardingState(currentPage: 1).isLastPage, isFalse);
      expect(const OnboardingState(currentPage: 2).isLastPage, isTrue);
    });

    test('copyWith preserves existing values', () {
      const state = OnboardingState(
        currentPage: 1,
        selectedLanguage: 'English',
        selectedCefrLevel: 'A2',
      );

      final updated = state.copyWith(selectedGoal: 'Work');

      expect(updated.currentPage, 1);
      expect(updated.selectedLanguage, 'English');
      expect(updated.selectedCefrLevel, 'A2');
      expect(updated.selectedGoal, 'Work');
    });

    test('copyWith clearLanguage sets language to null', () {
      const state = OnboardingState(selectedLanguage: 'English');
      final updated = state.copyWith(clearLanguage: true);
      expect(updated.selectedLanguage, isNull);
    });
  });

  group('OnboardingViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is page 0 with no selections', () {
      final state = container.read(onboardingProvider);

      expect(state.currentPage, 0);
      expect(state.selectedLanguage, isNull);
      expect(state.selectedCefrLevel, isNull);
      expect(state.selectedGoal, isNull);
    });

    test('setLanguage updates state and persists', () async {
      container.read(onboardingProvider.notifier).setLanguage('Spanish');

      final state = container.read(onboardingProvider);
      expect(state.selectedLanguage, 'Spanish');

      // Wait for fire-and-forget SharedPreferences write to complete.
      await Future.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('onboarding_language'), 'Spanish');
    });

    test('setCefrLevel updates state and persists', () async {
      container.read(onboardingProvider.notifier).setCefrLevel('B2');

      final state = container.read(onboardingProvider);
      expect(state.selectedCefrLevel, 'B2');

      await Future.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('onboarding_cefr'), 'B2');
    });

    test('setGoal updates state and persists', () async {
      container.read(onboardingProvider.notifier).setGoal('Exam');

      final state = container.read(onboardingProvider);
      expect(state.selectedGoal, 'Exam');

      await Future.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('onboarding_goal'), 'Exam');
    });

    test('nextPage increments page', () {
      final notifier = container.read(onboardingProvider.notifier);

      notifier.nextPage();
      expect(container.read(onboardingProvider).currentPage, 1);

      notifier.nextPage();
      expect(container.read(onboardingProvider).currentPage, 2);
    });

    test('nextPage does not exceed page 2', () {
      final notifier = container.read(onboardingProvider.notifier);

      notifier.nextPage();
      notifier.nextPage();
      notifier.nextPage(); // Should not go to page 3

      expect(container.read(onboardingProvider).currentPage, 2);
    });

    test('previousPage decrements page', () {
      final notifier = container.read(onboardingProvider.notifier);

      notifier.nextPage();
      notifier.nextPage();
      notifier.previousPage();

      expect(container.read(onboardingProvider).currentPage, 1);
    });

    test('previousPage does not go below page 0', () {
      final notifier = container.read(onboardingProvider.notifier);

      notifier.previousPage(); // Should stay at page 0

      expect(container.read(onboardingProvider).currentPage, 0);
    });

    test('saveAndComplete persists all selections', () async {
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setLanguage('French');
      notifier.setCefrLevel('C1');
      notifier.setGoal('Work');
      await notifier.saveAndComplete();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('onboarding_language'), 'French');
      expect(prefs.getString('onboarding_cefr'), 'C1');
      expect(prefs.getString('onboarding_goal'), 'Work');
      expect(prefs.getBool('onboarding_completed'), isTrue);
    });

    test('hasCompletedOnboarding returns false initially', () async {
      expect(await OnboardingViewModel.hasCompletedOnboarding(), isFalse);
    });

    test('hasCompletedOnboarding returns true after saveAndComplete', () async {
      final notifier = container.read(onboardingProvider.notifier);
      await notifier.saveAndComplete();

      expect(await OnboardingViewModel.hasCompletedOnboarding(), isTrue);
    });

    test('loadSavedData returns defaults when nothing saved', () async {
      final data = await OnboardingViewModel.loadSavedData();

      expect(data.targetLanguage, 'English');
      expect(data.cefrLevel, 'A1');
      expect(data.goal, 'Travel');
    });

    test('loadSavedData returns saved values', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_language', 'Korean');
      await prefs.setString('onboarding_cefr', 'B1');
      await prefs.setString('onboarding_goal', 'Casual');

      final data = await OnboardingViewModel.loadSavedData();

      expect(data.targetLanguage, 'Korean');
      expect(data.cefrLevel, 'B1');
      expect(data.goal, 'Casual');
    });

    test('loadSavedCefrLevel returns saved CEFR level', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_cefr', 'B2');

      expect(await OnboardingViewModel.loadSavedCefrLevel(), 'B2');
    });

    test('loadSavedCefrLevel returns A1 by default', () async {
      expect(await OnboardingViewModel.loadSavedCefrLevel(), 'A1');
    });
  });
}
