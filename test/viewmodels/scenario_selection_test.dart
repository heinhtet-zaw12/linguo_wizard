import 'package:flutter_test/flutter_test.dart';

import 'package:linguo_wizard/features/scenario_selection/models/scenario.dart';
import 'package:linguo_wizard/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart';

void main() {
  group('Scenario', () {
    test('fromJson parses valid JSON', () {
      final json = {
        'id': 'cafe',
        'title': 'Cafe Ordering',
        'description': 'Order coffee at a cafe',
        'personaName': 'Barista',
        'personaDescription': 'Friendly barista',
        'goalDescription': 'Order a coffee',
        'cefrLevel': 'A1',
        'category': 'food',
        'openingMessage': 'Hi! What can I get for you?',
      };

      final scenario = Scenario.fromJson(json);

      expect(scenario.id, 'cafe');
      expect(scenario.title, 'Cafe Ordering');
      expect(scenario.description, 'Order coffee at a cafe');
      expect(scenario.personaName, 'Barista');
      expect(scenario.personaDescription, 'Friendly barista');
      expect(scenario.goalDescription, 'Order a coffee');
      expect(scenario.cefrLevel, 'A1');
      expect(scenario.category, 'food');
      expect(scenario.openingMessage, 'Hi! What can I get for you?');
    });
  });

  group('ScenarioSelectionState', () {
    final scenarios = [
      const Scenario(
        id: '1', title: 'A1 Scene', description: '', personaName: '',
        personaDescription: '', goalDescription: '', cefrLevel: 'A1',
        category: '', openingMessage: '',
      ),
      const Scenario(
        id: '2', title: 'B1 Scene', description: '', personaName: '',
        personaDescription: '', goalDescription: '', cefrLevel: 'B1',
        category: '', openingMessage: '',
      ),
      const Scenario(
        id: '3', title: 'A1 Scene 2', description: '', personaName: '',
        personaDescription: '', goalDescription: '', cefrLevel: 'A1',
        category: '', openingMessage: '',
      ),
    ];

    test('filteredScenarios returns all when no filter', () {
      final state = ScenarioSelectionState(scenarios: scenarios);
      expect(state.filteredScenarios, scenarios);
    });

    test('filteredScenarios filters by CEFR level', () {
      final state = ScenarioSelectionState(
        scenarios: scenarios,
        selectedCefrLevel: 'A1',
      );
      expect(state.filteredScenarios, hasLength(2));
      expect(state.filteredScenarios.every((s) => s.cefrLevel == 'A1'), isTrue);
    });

    test('filteredScenarios returns empty when no match', () {
      final state = ScenarioSelectionState(
        scenarios: scenarios,
        selectedCefrLevel: 'C1',
      );
      expect(state.filteredScenarios, isEmpty);
    });

    test('copyWith preserves existing values', () {
      final state = ScenarioSelectionState(
        scenarios: scenarios,
        selectedCefrLevel: 'A1',
      );

      final updated = state.copyWith(selectedCefrLevel: 'B1');

      expect(updated.scenarios, scenarios);
      expect(updated.selectedCefrLevel, 'B1');
    });

    test('copyWith clearCefrLevel sets level to null', () {
      const state = ScenarioSelectionState(selectedCefrLevel: 'A1');
      final updated = state.copyWith(clearCefrLevel: true);
      expect(updated.selectedCefrLevel, isNull);
    });
  });
}
