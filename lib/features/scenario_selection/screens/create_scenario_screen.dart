import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart' show GlassChip;
import '../../../core/widgets/error_banner.dart';
import '../viewmodels/create_scenario_viewmodel.dart';
import '../viewmodels/scenario_selection_viewmodel.dart';
import '../widgets/scenario_preview_card.dart';
import '../../../core/theme/app_text_styles.dart';

/// Screen for creating custom scenarios via AI generation.
class CreateScenarioScreen extends ConsumerStatefulWidget {
  const CreateScenarioScreen({super.key});

  @override
  ConsumerState<CreateScenarioScreen> createState() =>
      _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends ConsumerState<CreateScenarioScreen> {
  final _personaController = TextEditingController();
  final _contextController = TextEditingController();
  final _goalController = TextEditingController();

  static const _cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  static const _tones = ['casual', 'formal'];

  @override
  void dispose() {
    _personaController.dispose();
    _contextController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createScenarioProvider);
    final notifier = ref.read(createScenarioProvider.notifier);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: _buildContent(state, notifier),
                    ),
                  ),
                ],
              ),
              if (state.step == CreateScenarioStep.generating)
                _buildGeneratingOverlay(),
              if (state.step == CreateScenarioStep.saving)
                _buildSavingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a Scenario',
                  style: AppTextStyles.displayMedium(color: AppColors.textPrimary),
                ),
                Text(
                  'Describe who you want to talk to',
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CreateScenarioState state, CreateScenarioViewModel notifier) {
    switch (state.step) {
      case CreateScenarioStep.form:
        return _buildForm(state, notifier);
      case CreateScenarioStep.generating:
        return _buildForm(state, notifier);
      case CreateScenarioStep.preview:
        return _buildPreview(state, notifier, context);
      case CreateScenarioStep.saving:
        return _buildPreview(state, notifier, context);
      case CreateScenarioStep.saved:
        return _buildSaved(context);
    }
  }

  Widget _buildForm(CreateScenarioState state, CreateScenarioViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Who do you want to talk to?'),
        const SizedBox(height: 6),
        TextField(
          controller: _personaController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(hint: 'e.g., a barista, a taxi driver'),
          style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
          onChanged: notifier.setPersona,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Where are you?'),
        const SizedBox(height: 6),
        TextField(
          controller: _contextController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(hint: 'e.g., at a busy coffee shop in London'),
          style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
          onChanged: notifier.setContext,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel("What's your goal?"),
        const SizedBox(height: 6),
        TextField(
          controller: _goalController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(hint: 'e.g., order a flat white and ask about the menu'),
          style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
          onChanged: notifier.setGoal,
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('Your level'),
        const SizedBox(height: 8),
        _buildChipRow(
          items: _cefrLevels,
          selected: state.cefrLevel,
          onSelected: notifier.setCefrLevel,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Tone'),
        const SizedBox(height: 8),
        _buildChipRow(
          items: _tones,
          selected: state.tone,
          onSelected: notifier.setTone,
          capitalize: true,
        ),
        const SizedBox(height: 24),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ErrorBanner(message: state.errorMessage!),
          ),
        AppButton(
          label: 'Generate Scenario',
          onPressed: notifier.generate,
        ),
      ],
    );
  }

  Widget _buildPreview(CreateScenarioState state, CreateScenarioViewModel notifier, BuildContext context) {
    final scenario = state.generatedScenario;
    if (scenario == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Scenario is Ready!',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ScenarioPreviewCard(scenario: scenario),
        const SizedBox(height: 16),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ErrorBanner(message: state.errorMessage!),
          ),
        AppButton(
          label: 'Try it',
          icon: Icons.play_arrow_rounded,
          onPressed: () async {
            await notifier.save();
            final currentState = ref.read(createScenarioProvider);
            final scenario = currentState.generatedScenario;
            if (currentState.step == CreateScenarioStep.saved && scenario != null) {
              if (!context.mounted) return;
              ref.read(selectedScenarioProvider.notifier).state = scenario;
              context.push('/conversation/${scenario.id}');
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Regenerate',
                variant: AppButtonVariant.secondary,
                onPressed: notifier.regenerate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Back to Form',
                variant: AppButtonVariant.secondary,
                onPressed: notifier.edit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => _showDiscardDialog(context, notifier),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(
              'Discard',
              style: AppTextStyles.headingSmall(color: AppColors.danger),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaved(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Success!',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          'Your custom scenario has been saved.\nFind it under "My Scenarios" on the\nmain screen.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Start Conversation',
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            final state = ref.read(createScenarioProvider);
            final scenario = state.generatedScenario;
            if (scenario != null) {
              ref.read(selectedScenarioProvider.notifier).state = scenario;
              context.push('/conversation/${scenario.id}');
            }
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Back to Scenarios',
          variant: AppButtonVariant.secondary,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildGeneratingOverlay() {
    return Container(
      color: AppColors.surfaceBase.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accentCyan),
            const SizedBox(height: 24),
            Text(
              'Generating your scenario...',
              style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: AppColors.surfaceBase.withValues(alpha: 0.9),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.accentCyan),
      ),
    );
  }

  void _showDiscardDialog(BuildContext context, CreateScenarioViewModel notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface1,
        title: Text(
          'Discard scenario?',
          style: AppTextStyles.headingLarge(color: AppColors.textPrimary),
        ),
        content: Text(
          'Your generated scenario won\'t be saved.',
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep editing',
              style: AppTextStyles.labelLarge(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.reset();
              context.pop();
            },
            child: Text(
              'Discard',
              style: AppTextStyles.labelLarge(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.headingSmall(color: AppColors.textPrimary),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surfaceGlass,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.5),
      ),
    );
  }

  Widget _buildChipRow({
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
    bool capitalize = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        final label = capitalize
            ? '${item[0].toUpperCase()}${item.substring(1)}'
            : item;
        return GlassChip(
          label: label.toUpperCase(),
          selected: isSelected,
          onTap: () => onSelected(item),
        );
      }).toList(),
    );
  }
}
