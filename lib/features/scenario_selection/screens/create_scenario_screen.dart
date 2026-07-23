import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/create_scenario_viewmodel.dart';
import '../widgets/scenario_preview_card.dart';

/// Screen for creating custom scenarios via AI generation.
///
/// 3-step wizard flow:
/// 1. Form — user describes persona, context, and goal
/// 2. Preview — user reviews the generated scenario (read-only, per D-10)
/// 3. Saved — success state with action buttons
class CreateScenarioScreen extends ConsumerStatefulWidget {
  const CreateScenarioScreen({super.key});

  @override
  ConsumerState<CreateScenarioScreen> createState() =>
      _CreateScenarioScreenState();
}

class _CreateScenarioScreenState
    extends ConsumerState<CreateScenarioScreen> {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
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

              // Generation overlay
              if (state.step == CreateScenarioStep.generating)
                _buildGeneratingOverlay(),

              // Saving overlay
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
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a Scenario',
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Describe who you want to talk to',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      CreateScenarioState state, CreateScenarioViewModel notifier) {
    switch (state.step) {
      case CreateScenarioStep.form:
        return _buildForm(state, notifier);
      case CreateScenarioStep.generating:
        // Show form underneath overlay, or blank
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
        // ─── Persona field ───
        _buildFieldLabel('Who do you want to talk to?'),
        const SizedBox(height: 6),
        TextField(
          controller: _personaController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            hint: 'e.g., a barista, a taxi driver',
          ),
          style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textDark),
          onChanged: notifier.setPersona,
        ),
        const SizedBox(height: 16),

        // ─── Context field ───
        _buildFieldLabel('Where are you?'),
        const SizedBox(height: 6),
        TextField(
          controller: _contextController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            hint: 'e.g., at a busy coffee shop in London',
          ),
          style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textDark),
          onChanged: notifier.setContext,
        ),
        const SizedBox(height: 16),

        // ─── Goal field ───
        _buildFieldLabel("What's your goal?"),
        const SizedBox(height: 6),
        TextField(
          controller: _goalController,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            hint: 'e.g., order a flat white and ask about the menu',
          ),
          style: GoogleFonts.fredoka(fontSize: 16, color: AppColors.textDark),
          onChanged: notifier.setGoal,
        ),
        const SizedBox(height: 20),

        // ─── CEFR Level ───
        _buildFieldLabel('Your level'),
        const SizedBox(height: 8),
        _buildChipRow(
          items: _cefrLevels,
          selected: state.cefrLevel,
          onSelected: notifier.setCefrLevel,
        ),
        const SizedBox(height: 16),

        // ─── Tone ───
        _buildFieldLabel('Tone'),
        const SizedBox(height: 8),
        _buildChipRow(
          items: _tones,
          selected: state.tone,
          onSelected: notifier.setTone,
          capitalize: true,
        ),
        const SizedBox(height: 24),

        // ─── Error message ───
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentCoral.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 18, color: AppColors.accentCoral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentCoral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ─── Generate button ───
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: notifier.generate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: AppColors.shadowPink,
            ),
            child: Text(
              'Generate Scenario',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(CreateScenarioState state,
      CreateScenarioViewModel notifier, BuildContext context) {
    final scenario = state.generatedScenario;
    if (scenario == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Scenario is Ready!',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),

        // Preview card
        ScenarioPreviewCard(scenario: scenario),
        const SizedBox(height: 16),

        // Error message
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentCoral.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 18, color: AppColors.accentCoral),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentCoral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ─── Try It button ───
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              // Save then navigate to conversation
              notifier.save();
              // On save success, the state transitions to saved.
              // We navigate to conversation when the user taps button on saved state.
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: Text(
              'Try it',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: AppColors.shadowPink,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ─── Action row ───
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: notifier.regenerate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPinkDark,
                  side: BorderSide(color: AppColors.primaryPinkLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Regenerate',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: notifier.edit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPinkDark,
                  side: BorderSide(color: AppColors.primaryPinkLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Back to Form',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ─── Discard button ───
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => _showDiscardDialog(context, notifier),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentCoral,
            ),
            child: Text(
              'Discard',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
            color: AppColors.primaryPinkLight.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.primaryPink,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Success!',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your custom scenario has been saved.\nFind it under "My Scenarios" on the\nmain screen.',
          textAlign: TextAlign.center,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to conversation with saved scenario
              final scenario =
                  ref.read(createScenarioProvider).generatedScenario;
              if (scenario != null) {
                context.push('/conversation/${scenario.id}');
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: Text(
              'Start Conversation',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 4,
              shadowColor: AppColors.shadowPink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPinkDark,
              side: BorderSide(color: AppColors.primaryPinkLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Back to Scenarios',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingOverlay() {
    return Container(
      color: AppColors.bgTop.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryPink,
            ),
            const SizedBox(height: 24),
            Text(
              'Generating your scenario...',
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: AppColors.bgTop.withValues(alpha: 0.9),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryPink,
        ),
      ),
    );
  }

  void _showDiscardDialog(
      BuildContext context, CreateScenarioViewModel notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Discard scenario?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          'Your generated scenario won\'t be saved.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep editing',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
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

  // ─── Helper widgets ───

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.quicksand(
        color: AppColors.textMuted.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
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
        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryPink
                  : Colors.white.withValues(alpha: 0.85),
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
              label.toUpperCase(),
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
