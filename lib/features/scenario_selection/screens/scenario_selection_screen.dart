import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/scenario_selection_viewmodel.dart';
import '../widgets/scenario_card.dart';

/// Redesigned scenario selection screen with category tabs, search bar,
/// CEFR chips, and infinite scroll pagination.
class ScenarioSelectionScreen extends ConsumerStatefulWidget {
  const ScenarioSelectionScreen({super.key});

  @override
  ConsumerState<ScenarioSelectionScreen> createState() =>
      _ScenarioSelectionScreenState();
}

class _ScenarioSelectionScreenState
    extends ConsumerState<ScenarioSelectionScreen> {
  static const _cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  static const _categories = [
    null, // "All"
    'travel',
    'work',
    'social',
    'academic',
    'daily-life',
  ];

  static const _categoryLabels = [
    'All',
    'Travel',
    'Work',
    'Social',
    'Academic',
    'Daily Life',
  ];

  bool _isSearchOpen = false;
  final _searchController = TextEditingController();
  Timer? _debounce;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Detect when the user scrolls near the bottom of the grid to trigger
  /// infinite scroll loadMore.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(scenarioSelectionProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(scenarioSelectionProvider.notifier).setSearchQuery(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(scenarioSelectionProvider);
    final notifier = ref.read(scenarioSelectionProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      "Couldn't load scenarios. Check your connection and try again.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => notifier.build(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Retry',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (state) => _buildContent(context, ref, state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ScenarioSelectionState state,
    ScenarioSelectionViewModel notifier,
  ) {
    return Column(
      children: [
        // Header (title + search toggle)
        _buildHeader(context, state, notifier),

        // Category tabs
        _buildCategoryTabs(state, notifier),

        // CEFR chips
        _buildCefrChips(state, notifier),

        // Search results header (when search is active)
        if (state.searchQuery.isNotEmpty && state.displayScenarios.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Showing ${state.displayScenarios.length} results for '${state.searchQuery}'",
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Scenario grid or empty state
        Expanded(
          child: state.displayScenarios.isEmpty && !state.isLoading
              ? _buildEmptyState(context, state)
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        _scrollController.position.pixels >=
                            _scrollController.position.maxScrollExtent -
                                300) {
                      notifier.loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: state.displayScenarios.length +
                        (state.isLoadingMore
                            ? 1
                            : state.hasMore
                                ? 1
                                : state.displayScenarios.isNotEmpty
                                    ? 1
                                    : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at bottom
                      if (index >= state.displayScenarios.length) {
                        if (state.isLoadingMore) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                            ),
                          );
                        }
                        if (!state.hasMore &&
                            state.displayScenarios.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                "You've seen them all!",
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final scenario = state.displayScenarios[index];
                      return ScenarioCard(
                        scenario: scenario,
                        onTap: () {
                          ref.read(selectedScenarioProvider.notifier).state =
                              scenario;
                          context.push('/conversation/${scenario.id}');
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, ScenarioSelectionState state, ScenarioSelectionViewModel notifier) {
    if (_isSearchOpen) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search scenarios...',
            hintStyle: GoogleFonts.quicksand(
                color: AppColors.textMuted, fontSize: 15),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textMuted),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textMuted),
              onPressed: () {
                setState(() {
                  _isSearchOpen = false;
                  _searchController.clear();
                });
                notifier.setSearchQuery('');
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.quicksand(fontSize: 15, color: AppColors.textDark),
          onChanged: _onSearchChanged,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Scenario',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a situation to practice',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark),
            onPressed: () {
              setState(() {
                _isSearchOpen = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(
      ScenarioSelectionState state, ScenarioSelectionViewModel notifier) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final label = _categoryLabels[index];
          final isSelected = state.selectedCategory == category;
          // Both null means "All" is selected
          final isAllSelected = category == null && state.selectedCategory == null;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => notifier.setCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isSelected || isAllSelected)
                      ? AppColors.primaryPink
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isSelected || isAllSelected)
                        ? AppColors.primaryPink
                        : AppColors.primaryPinkLight,
                    width: 1.5,
                  ),
                  boxShadow: (isSelected || isAllSelected)
                      ? [
                          BoxShadow(
                            color: AppColors.shadowPink,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (isSelected || isAllSelected)
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCefrChips(
      ScenarioSelectionState state, ScenarioSelectionViewModel notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _cefrLevels.length + 1, // +1 for "All"
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = state.selectedCefrLevel == null;
              return _CefrChip(
                label: 'All',
                isSelected: isSelected,
                onTap: () => notifier.setCefrFilter(null),
              );
            }
            final level = _cefrLevels[index - 1];
            final isSelected =
                state.selectedCefrLevel?.toUpperCase() == level.toUpperCase();
            return _CefrChip(
              label: level,
              isSelected: isSelected,
              onTap: () => notifier.setCefrFilter(level),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ScenarioSelectionState state) {
    String message;
    IconData icon;

    if (state.searchQuery.isNotEmpty) {
      message =
          "No scenarios match your search. Try a different keyword or CEFR level.";
      icon = Icons.search_off;
    } else if (state.selectedCefrLevel != null ||
        state.selectedCategory != null) {
      message =
          "No scenarios found. Try adjusting your filters or search.";
      icon = Icons.filter_list_off;
    } else {
      message = "Couldn't load scenarios. Check your connection and try again.";
      icon = Icons.cloud_off;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single CEFR-level filter chip (reused from the original design).
class _CefrChip extends StatelessWidget {
  const _CefrChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPink
                : AppColors.primaryPinkLight,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowPink,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
