import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scenario.dart';

// State for the scenario selection screen.
class ScenarioSelectionState {
  final List<Scenario> scenarios;
  final String? selectedCefrLevel;

  const ScenarioSelectionState({
    this.scenarios = const [],
    this.selectedCefrLevel,
  });

  ScenarioSelectionState copyWith({
    List<Scenario>? scenarios,
    String? selectedCefrLevel,
    bool clearCefrLevel = false,
  }) {
    return ScenarioSelectionState(
      scenarios: scenarios ?? this.scenarios,
      selectedCefrLevel: clearCefrLevel ? null : (selectedCefrLevel ?? this.selectedCefrLevel),
    );
  }

  // Returns scenarios filtered by the selected CEFR level.
  List<Scenario> get filteredScenarios {
    if (selectedCefrLevel == null) return scenarios;
    return scenarios.where((s) => s.cefrLevel == selectedCefrLevel).toList();
  }
}

// ViewModel for the scenario selection screen.
//
// Loads curated scenarios from bundled JSON assets and manages
// CEFR level filtering.
class ScenarioSelectionViewModel extends AsyncNotifier<ScenarioSelectionState> {
  // Load all curated scenarios from bundled JSON assets and
  // pre-seed the CEFR filter from onboarding.
  @override
  Future<ScenarioSelectionState> build() async {
    final files = [
      'assets/data/scenarios/cafe_ordering.json',
      'assets/data/scenarios/job_interview.json',
      'assets/data/scenarios/airport_navigation.json',
    ];

    final scenarios = <Scenario>[];
    for (final path in files) {
      final jsonStr = await rootBundle.loadString(path);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      scenarios.add(Scenario.fromJson(json));
    }

    final prefs = await SharedPreferences.getInstance();
    final savedCefr = prefs.getString('onboarding_cefr');

    return ScenarioSelectionState(
      scenarios: scenarios,
      selectedCefrLevel: savedCefr,
    );
  }

  // Set the active CEFR level filter. Pass null to show all.
  void setCefrFilter(String? level) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      selectedCefrLevel: level,
      clearCefrLevel: level == null,
    ));
  }
}

// Provider for the scenario selection ViewModel.
final scenarioSelectionProvider =
    AsyncNotifierProvider<ScenarioSelectionViewModel, ScenarioSelectionState>(
  ScenarioSelectionViewModel.new,
);

// The currently selected scenario for conversation use.
final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);
