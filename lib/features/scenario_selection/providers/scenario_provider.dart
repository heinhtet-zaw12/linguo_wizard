import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../conversation/models/scenario.dart';

/// Loads all curated scenarios from bundled JSON assets.
final scenariosProvider = FutureProvider<List<Scenario>>((ref) async {
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
  return scenarios;
});

/// The currently selected scenario for conversation use.
final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);
