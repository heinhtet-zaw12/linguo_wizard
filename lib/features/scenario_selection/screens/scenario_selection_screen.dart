import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/scenario.dart';
import '../viewmodels/scenario_selection_viewmodel.dart';
import '../viewmodels/twist_viewmodel.dart';
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

    // Watch twist provider for navigation to conversation.
    ref.listen(twistProvider, (prev, next) {
      next.whenOrNull(data: (twistScenario) {
        if (twistScenario != null) {
          ref.read(selectedScenarioProvider.notifier).state = twistScenario;
          context.push('/conversation/${twistScenario.id}');
          // Reset twist state so the next tap triggers a fresh generation.
          ref.read(twistProvider.notifier).reset();
        }
      });
    });

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
        // Header (title + search toggle + create button)
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

        // Scenario grid(s) or empty state
        Expanded(child: _buildScrollContent(context, ref, state, notifier)),
      ],
    );
  }

  /// Builds the scrollable content: My Scenarios section (if any),
  /// then curated scenarios grid with infinite scroll.
  Widget _buildScrollContent(
    BuildContext context,
    WidgetRef ref,
    ScenarioSelectionState state,
    ScenarioSelectionViewModel notifier,
  ) {
    final hasCustomScenarios = state.customScenarios.isNotEmpty;
    final hasCuratedScenarios = state.displayScenarios.isNotEmpty;
    final isSearching = state.searchQuery.isNotEmpty;

    // Show empty state if nothing to display and not loading.
    if (!hasCustomScenarios && !hasCuratedScenarios && !state.isLoading) {
      return _buildEmptyState(context, state);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 300) {
          notifier.loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── My Scenarios section ───
          if (hasCustomScenarios && !isSearching) ...[
            SliverToBoxAdapter(
              child: _buildMyScenariosHeader(),
            ),
            SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final scenario = state.customScenarios[index];
                  return _buildCustomScenarioCard(
                      context, ref, scenario, notifier);
                },
                childCount: state.customScenarios.length,
              ),
            ),
            // Divider
            if (hasCuratedScenarios)
              SliverToBoxAdapter(
                child: _buildCuratedDivider(),
              ),
          ],

          // ─── Curated scenarios grid ───
          if (hasCuratedScenarios)
            SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final scenario = state.displayScenarios[index];
                  return ScenarioCard(
                    scenario: scenario,
                    onTap: () {
                      ref
                          .read(selectedScenarioProvider.notifier)
                          .state = scenario;
                      context.push('/conversation/${scenario.id}');
                    },
                    showTwistBadge:
                        state.completedScenarioIds.contains(scenario.id),
                    onTwistTap: () {
                      final user = ref.read(currentUserProvider);
                      ref
                          .read(twistProvider.notifier)
                          .generateAndLaunchTwist(
                            originalScenario: scenario,
                            uid: user?.uid,
                          );
                    },
                  );
                },
                childCount: state.displayScenarios.length,
              ),
            ),

          // ─── Footer ───
          SliverToBoxAdapter(
            child: _buildGridFooter(state),
          ),
        ],
      ),
    );
  }

  Widget _buildGridFooter(ScenarioSelectionState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
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
    if (!state.hasMore && state.displayScenarios.isNotEmpty) {
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
    return const SizedBox(height: 80);
  }

  /// Builds a custom scenario card with a delete menu.
  Widget _buildCustomScenarioCard(
    BuildContext context,
    WidgetRef ref,
    Scenario scenario,
    ScenarioSelectionViewModel notifier,
  ) {
    return ScenarioCard(
      scenario: scenario,
      onTap: () {
        ref.read(selectedScenarioProvider.notifier).state = scenario;
        context.push('/conversation/${scenario.id}');
      },
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert,
            size: 16, color: AppColors.textMuted),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (value) {
          if (value == 'delete') {
            _showDeleteDialog(context, scenario, notifier);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    size: 18, color: AppColors.accentCoral),
                const SizedBox(width: 8),
                Text(
                  'Delete Scenario',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentCoral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Scenario scenario,
    ScenarioSelectionViewModel notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete scenario?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'This can\'t be undone.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.deleteCustomScenario(scenario.id);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: AppColors.accentCoral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyScenariosHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        'My Scenarios',
        style: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildCuratedDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.primaryPinkLight),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Curated Scenarios',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: AppColors.primaryPinkLight),
          ),
        ],
      ),
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
          // Create Scenario button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: 'Create Custom Scenario',
            onPressed: () {
              final isGuest = ref.read(isGuestProvider);
              if (isGuest) {
                _showGuestPrompt(context);
              } else {
                context.push('/create-scenario');
              }
            },
            color: AppColors.primaryPink,
          ),
          // Search toggle
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

  void _showGuestPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign up to create scenarios',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Create an account to save and use your own custom scenarios.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Not now',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/login');
            },
            child: Text(
              'Sign up',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPink,
              ),
            ),
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
