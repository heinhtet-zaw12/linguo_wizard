import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/scenario_selection_viewmodel.dart';
import '../widgets/scenario_card.dart';

/// Screen where users browse and select a curated conversation scenario.
class ScenarioSelectionScreen extends ConsumerWidget {
  const ScenarioSelectionScreen({super.key});

  static const _cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Text('Failed to load scenarios: $e',
                  style: GoogleFonts.quicksand(color: AppColors.textMuted)),
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
    final displayScenarios = state.filteredScenarios;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose a Scenario',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pick a real-world situation to practice',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),

        // CEFR filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    state.selectedCefrLevel?.toUpperCase() ==
                        level.toUpperCase();
                return _CefrChip(
                  label: level,
                  isSelected: isSelected,
                  onTap: () => notifier.setCefrFilter(level),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Scenario grid
        Expanded(
          child: displayScenarios.isEmpty
              ? Center(
                  child: Text(
                    'No scenarios found for this level',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: displayScenarios.length,
                    itemBuilder: (context, index) {
                      final scenario = displayScenarios[index];
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
}

/// A single CEFR-level filter chip.
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
