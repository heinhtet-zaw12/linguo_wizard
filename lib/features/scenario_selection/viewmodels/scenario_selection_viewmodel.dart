import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../conversation/models/scenario.dart';

/// State for the scenario selection screen.
class ScenarioSelectionState {
  final List<Scenario> scenarios;
  final bool isLoading;
  final String? selectedCefrLevel;

  const ScenarioSelectionState({
    this.scenarios = const [],
    this.isLoading = true,
    this.selectedCefrLevel,
  });

  ScenarioSelectionState copyWith({
    List<Scenario>? scenarios,
    bool? isLoading,
    String? selectedCefrLevel,
    bool clearCefrLevel = false,
  }) {
    return ScenarioSelectionState(
      scenarios: scenarios ?? this.scenarios,
      isLoading: isLoading ?? this.isLoading,
      selectedCefrLevel: clearCefrLevel ? null : (selectedCefrLevel ?? this.selectedCefrLevel),
    );
  }

  /// Returns scenarios filtered by the selected CEFR level.
  List<Scenario> get filteredScenarios {
    if (selectedCefrLevel == null) return scenarios;
    return scenarios.where((s) => s.cefrLevel == selectedCefrLevel).toList();
  }
}

/// ViewModel for the scenario selection screen.
///
/// Loads curated scenarios from bundled JSON assets and manages
/// CEFR level filtering.
class ScenarioSelectionViewModel
    extends StateNotifier<ScenarioSelectionState> {
  ScenarioSelectionViewModel() : super(const ScenarioSelectionState());

  /// Load all curated scenarios from bundled JSON assets.
  Future<void> init() async {
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

    state = state.copyWith(scenarios: scenarios, isLoading: false);
  }

  /// Set the active CEFR level filter. Pass null to show all.
  void setCefrFilter(String? level) {
    state = state.copyWith(
      selectedCefrLevel: level,
      clearCefrLevel: level == null,
    );
  }
}

/// Provider for the scenario selection ViewModel.
final scenarioSelectionProvider =
    StateNotifierProvider<ScenarioSelectionViewModel, ScenarioSelectionState>(
        (ref) {
  return ScenarioSelectionViewModel()..init();
});

/// The currently selected scenario for conversation use.
final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);
