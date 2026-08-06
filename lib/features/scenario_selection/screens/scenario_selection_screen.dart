import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_chip.dart' show GlassChip;
import '../../../core/widgets/app_button.dart';
import '../models/scenario.dart';
import '../viewmodels/scenario_selection_viewmodel.dart';
import '../viewmodels/twist_viewmodel.dart';
import '../widgets/scenario_card.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';

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

    ref.listen(twistProvider, (prev, next) {
      next.whenOrNull(data: (twistScenario) {
        if (twistScenario != null) {
          ref.read(selectedScenarioProvider.notifier).state = twistScenario;
          context.push('/conversation/${twistScenario.id}');
          ref.read(twistProvider.notifier).reset();
        }
      });
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentCyan),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      "Couldn't load scenarios. Check your connection and try again.",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Retry',
                      icon: Icons.refresh,
                      onPressed: () => ref.invalidate(scenarioSelectionProvider),
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
        _buildHeader(context, state, notifier),
        _buildCategoryTabs(state, notifier),
        _buildCefrChips(state, notifier),
        if (state.searchQuery.isNotEmpty && state.displayScenarios.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Showing ${state.displayScenarios.length} results for '${state.searchQuery}'",
                style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(child: _buildScrollContent(context, ref, state, notifier)),
      ],
    );
  }

  Widget _buildScrollContent(
    BuildContext context,
    WidgetRef ref,
    ScenarioSelectionState state,
    ScenarioSelectionViewModel notifier,
  ) {
    final hasCustomScenarios = state.customScenarios.isNotEmpty;
    final hasCuratedScenarios = state.displayScenarios.isNotEmpty;
    final isSearching = state.searchQuery.isNotEmpty;

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
          if (hasCustomScenarios && !isSearching) ...[
            SliverToBoxAdapter(
              child: _buildMyScenariosHeader(),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final scenario = state.customScenarios[index];
                  return _buildCustomScenarioCard(context, ref, scenario, notifier);
                },
                childCount: state.customScenarios.length,
              ),
            ),
            if (hasCuratedScenarios) SliverToBoxAdapter(child: _buildCuratedDivider()),
          ],
          if (hasCuratedScenarios)
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      ref.read(selectedScenarioProvider.notifier).state = scenario;
                      context.push('/conversation/${scenario.id}');
                    },
                    showTwistBadge: state.completedScenarioIds.contains(scenario.id),
                    onTwistTap: () {
                      final user = ref.read(currentUserProvider);
                      ref.read(twistProvider.notifier).generateAndLaunchTwist(
                            originalScenario: scenario,
                            uid: user?.uid,
                          );
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.05, duration: 400.ms, delay: (index * 50).ms);
                },
                childCount: state.displayScenarios.length,
              ),
            ),
          SliverToBoxAdapter(child: _buildGridFooter(state)),
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
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan),
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
            style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return const SizedBox(height: 80);
  }

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
        icon: Icon(Icons.more_vert, size: 16, color: AppColors.textTertiary),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
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
                Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                const SizedBox(width: 8),
                Text(
                  'Delete Scenario',
                  style: AppTextStyles.labelMedium(color: AppColors.danger),
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        backgroundColor: AppColors.surface1,
        title: Text(
          'Delete scenario?',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        content: Text(
          'This can\'t be undone.',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              notifier.deleteCustomScenario(scenario.id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelLarge(color: AppColors.danger),
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
        style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCuratedDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s5, 12, AppSpacing.s5, 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.borderSubtle)),
          Padding(
            padding: AppSpacing.horizontal3,
            child: Text(
              'Curated Scenarios',
              style: AppTextStyles.labelSmall(color: AppColors.textTertiary),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.borderSubtle)),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ScenarioSelectionState state, ScenarioSelectionViewModel notifier) {
    if (_isSearchOpen) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: AppRadius.xxl,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search scenarios...',
              hintStyle: AppTextStyles.bodyMedium(color: AppColors.textTertiary),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: AppRadius.xxl,
                borderSide: BorderSide.none,
              ),
            ),
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary),
            onChanged: _onSearchChanged,
          ),
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
                  style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a situation to practice',
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
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
            color: AppColors.accentCyan,
          ),
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textPrimary),
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        backgroundColor: AppColors.surface1,
        title: Text(
          'Sign up to create scenarios',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        content: Text(
          'Create an account to save and use your own custom scenarios.',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Not now',
              style: AppTextStyles.labelLarge(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/login');
            },
            child: Text(
              'Sign up',
              style: AppTextStyles.labelLarge(color: AppColors.accentCyan),
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
        padding: AppSpacing.horizontal4,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final label = _categoryLabels[index];
          final isSelected = state.selectedCategory == category;
          final isAllSelected = category == null && state.selectedCategory == null;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => notifier.setCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 8),
                decoration: BoxDecoration(
                  gradient: (isSelected || isAllSelected) ? AppGradients.accent : null,
                  color: (isSelected || isAllSelected) ? null : AppColors.surfaceGlass,
                  borderRadius: AppRadius.xl,
                  border: Border.all(
                    color: (isSelected || isAllSelected)
                        ? AppColors.accentStart
                        : AppColors.borderSubtle,
                    width: 1.5,
                  ),
                  boxShadow: (isSelected || isAllSelected) ? AppShadows.glowBlue : [],
                ),
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium(
                    color: (isSelected || isAllSelected)
                        ? AppColors.textOnAccent
                        : AppColors.textSecondary,
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
          itemCount: _cefrLevels.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = state.selectedCefrLevel == null;
              return GlassChip(
                label: 'All',
                selected: isSelected,
                onTap: () => notifier.setCefrFilter(null),
              );
            }
            final level = _cefrLevels[index - 1];
            final isSelected =
                state.selectedCefrLevel?.toUpperCase() == level.toUpperCase();
            return GlassChip(
              label: level,
              selected: isSelected,
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
      message = "No scenarios match your search. Try a different keyword or CEFR level.";
      icon = Icons.search_off;
    } else if (state.selectedCefrLevel != null || state.selectedCategory != null) {
      message = "No scenarios found. Try adjusting your filters or search.";
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
            Icon(icon, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
