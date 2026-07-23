import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/scenario_service.dart';
import '../models/scenario.dart';

// State for the redesigned scenario selection screen.
class ScenarioSelectionState {
  final List<Scenario> allScenarios; // curated scenarios from cache/Firestore
  final List<Scenario> displayScenarios; // currently visible (paginated + filtered)
  final List<Scenario> customScenarios; // user-created scenarios (authenticated only)
  final bool isLoadingCustomScenarios;
  final String? selectedCefrLevel;
  final String? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  const ScenarioSelectionState({
    this.allScenarios = const [],
    this.displayScenarios = const [],
    this.customScenarios = const [],
    this.isLoadingCustomScenarios = false,
    this.selectedCefrLevel,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
  });

  ScenarioSelectionState copyWith({
    List<Scenario>? allScenarios,
    List<Scenario>? displayScenarios,
    List<Scenario>? customScenarios,
    bool? isLoadingCustomScenarios,
    String? selectedCefrLevel,
    bool clearCefrLevel = false,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool clearSearchQuery = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ScenarioSelectionState(
      allScenarios: allScenarios ?? this.allScenarios,
      displayScenarios: displayScenarios ?? this.displayScenarios,
      customScenarios: customScenarios ?? this.customScenarios,
      isLoadingCustomScenarios:
          isLoadingCustomScenarios ?? this.isLoadingCustomScenarios,
      selectedCefrLevel: clearCefrLevel
          ? null
          : (selectedCefrLevel ?? this.selectedCefrLevel),
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery:
          clearSearchQuery ? '' : (searchQuery ?? this.searchQuery),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// ViewModel for the redesigned scenario selection screen.
///
/// Manages:
/// - Loading scenarios from FirestoreScenarioService (cache-first, background refresh)
/// - Filtering by CEFR level, category, and search query (all stackable)
/// - Infinite scroll pagination (20 at a time)
class ScenarioSelectionViewModel
    extends AsyncNotifier<ScenarioSelectionState> {
  static const int _pageSize = 20;
  int _visibleCount = _pageSize;

  late final FirestoreScenarioService _scenarioService;

  @override
  Future<ScenarioSelectionState> build() async {
    _scenarioService = ref.read(scenarioServiceProvider);

    // Read saved CEFR from onboarding.
    final prefs = await SharedPreferences.getInstance();
    final savedCefr = prefs.getString('onboarding_cefr');

    // Load from service (cache-first, then background refresh).
    final scenarios = await _scenarioService.getScenarios();

    _visibleCount = _pageSize;
    final display = _computeDisplay(scenarios, null, null, '', _visibleCount);

    // Load custom scenarios for authenticated users.
    final user = ref.read(currentUserProvider);
    List<Scenario> customScenarios = [];
    if (user != null) {
      try {
        customScenarios = await _scenarioService.getCustomScenarios(user.uid);
      } catch (_) {
        // Custom scenarios failed to load — non-critical, show empty.
      }
    }

    return ScenarioSelectionState(
      allScenarios: scenarios,
      displayScenarios: display,
      customScenarios: customScenarios,
      isLoadingCustomScenarios: false,
      selectedCefrLevel: savedCefr,
      isLoading: false,
      hasMore: _visibleCount < scenarios.length,
    );
  }

  /// Set the active CEFR level filter. Pass null to show all.
  void setCefrFilter(String? level) {
    final current = state.value;
    if (current == null) return;
    _visibleCount = _pageSize;
    final display = _computeDisplay(
      current.allScenarios,
      level,
      current.selectedCategory,
      current.searchQuery,
      _visibleCount,
    );
    state = AsyncData(current.copyWith(
      selectedCefrLevel: level,
      clearCefrLevel: level == null,
      displayScenarios: display,
      hasMore: _visibleCount < _computeFilteredCount(
        current.allScenarios, level, current.selectedCategory, current.searchQuery,
      ),
    ));
  }

  /// Set the active category filter. Pass null to show all.
  /// Categories: null (All), 'travel', 'work', 'social', 'academic', 'daily-life'
  void setCategory(String? category) {
    final current = state.value;
    if (current == null) return;
    _visibleCount = _pageSize;
    final display = _computeDisplay(
      current.allScenarios,
      current.selectedCefrLevel,
      category,
      current.searchQuery,
      _visibleCount,
    );
    state = AsyncData(current.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
      displayScenarios: display,
      hasMore: _visibleCount < _computeFilteredCount(
        current.allScenarios, current.selectedCefrLevel, category, current.searchQuery,
      ),
    ));
  }

  /// Set the search query filter. Filters by title or description
  /// (case-insensitive). Resets pagination.
  void setSearchQuery(String query) {
    final current = state.value;
    if (current == null) return;
    _visibleCount = _pageSize;
    final display = _computeDisplay(
      current.allScenarios,
      current.selectedCefrLevel,
      current.selectedCategory,
      query,
      _visibleCount,
    );
    state = AsyncData(current.copyWith(
      searchQuery: query,
      clearSearchQuery: query.isEmpty,
      displayScenarios: display,
      hasMore: _visibleCount < _computeFilteredCount(
        current.allScenarios, current.selectedCefrLevel, current.selectedCategory, query,
      ),
    ));
  }

  /// Load more scenarios (next page of 20).
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    _visibleCount += _pageSize;
    final display = _computeDisplay(
      current.allScenarios,
      current.selectedCefrLevel,
      current.selectedCategory,
      current.searchQuery,
      _visibleCount,
    );

    final filteredCount = _computeFilteredCount(
      current.allScenarios,
      current.selectedCefrLevel,
      current.selectedCategory,
      current.searchQuery,
    );

    state = AsyncData(current.copyWith(
      displayScenarios: display,
      isLoadingMore: false,
      hasMore: _visibleCount < filteredCount,
    ));
  }

  /// Compute the filtered and paginated display list.
  List<Scenario> _computeDisplay(
    List<Scenario> all,
    String? cefr,
    String? category,
    String query,
    int visibleCount,
  ) {
    var filtered = all.toList();

    // Filter by CEFR level.
    if (cefr != null) {
      filtered = filtered.where((s) => s.cefrLevel == cefr).toList();
    }

    // Filter by category.
    if (category != null) {
      filtered = filtered.where((s) => s.category == category).toList();
    }

    // Filter by search query (title or description, case-insensitive).
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered
          .where((s) =>
              s.title.toLowerCase().contains(lowerQuery) ||
              s.description.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Sort by completionCount descending (popular first).
    filtered.sort((a, b) => b.completionCount.compareTo(a.completionCount));

    // Paginate.
    if (filtered.length > visibleCount) {
      return filtered.sublist(0, visibleCount);
    }
    return filtered;
  }

  /// Compute total filtered count (without pagination).
  int _computeFilteredCount(
    List<Scenario> all,
    String? cefr,
    String? category,
    String query,
  ) {
    return _computeDisplay(all, cefr, category, query, all.length).length;
  }

  /// Delete a custom scenario for the current user.
  Future<void> deleteCustomScenario(String scenarioId) async {
    final current = state.value;
    if (current == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Optimistic removal.
    final updatedCustom = current.customScenarios
        .where((s) => s.id != scenarioId)
        .toList();
    state = AsyncData(current.copyWith(customScenarios: updatedCustom));

    try {
      await _scenarioService.deleteCustomScenario(user.uid, scenarioId);
    } catch (_) {
      // Revert on failure.
      final original = await _scenarioService.getCustomScenarios(user.uid);
      state = AsyncData(current.copyWith(customScenarios: original));
    }
  }
}

// Provider for the scenario selection ViewModel.
final scenarioSelectionProvider =
    AsyncNotifierProvider<ScenarioSelectionViewModel, ScenarioSelectionState>(
  ScenarioSelectionViewModel.new,
);

// The currently selected scenario for conversation use.
final selectedScenarioProvider = StateProvider<Scenario?>((ref) => null);
