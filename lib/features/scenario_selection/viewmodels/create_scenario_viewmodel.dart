import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../models/scenario.dart';

/// Steps in the custom scenario creation flow.
enum CreateScenarioStep { form, generating, preview, saved, saving }

/// State for the custom scenario creation flow.
class CreateScenarioState {
  final CreateScenarioStep step;
  final String persona;
  final String context;
  final String goal;
  final String cefrLevel;
  final String tone;
  final Scenario? generatedScenario;
  final String? errorMessage;

  const CreateScenarioState({
    this.step = CreateScenarioStep.form,
    this.persona = '',
    this.context = '',
    this.goal = '',
    this.cefrLevel = 'A1',
    this.tone = 'casual',
    this.generatedScenario,
    this.errorMessage,
  });

  CreateScenarioState copyWith({
    CreateScenarioStep? step,
    String? persona,
    String? context,
    String? goal,
    String? cefrLevel,
    String? tone,
    Scenario? generatedScenario,
    bool clearGeneratedScenario = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateScenarioState(
      step: step ?? this.step,
      persona: persona ?? this.persona,
      context: context ?? this.context,
      goal: goal ?? this.goal,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      tone: tone ?? this.tone,
      generatedScenario:
          clearGeneratedScenario ? null : (generatedScenario ?? this.generatedScenario),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// True when all form fields are filled.
  bool get isFormValid =>
      persona.trim().isNotEmpty &&
      context.trim().isNotEmpty &&
      goal.trim().isNotEmpty;
}

/// ViewModel for the custom scenario creation flow.
///
/// State machine: form -> generating -> preview -> saved
/// Users can go back (edit) from preview to form, or regenerate.
class CreateScenarioViewModel extends Notifier<CreateScenarioState> {
  @override
  CreateScenarioState build() => const CreateScenarioState();

  void setPersona(String value) {
    state = state.copyWith(persona: value, errorMessage: null);
  }

  void setContext(String value) {
    state = state.copyWith(context: value, errorMessage: null);
  }

  void setGoal(String value) {
    state = state.copyWith(goal: value, errorMessage: null);
  }

  void setCefrLevel(String level) {
    state = state.copyWith(cefrLevel: level);
  }

  void setTone(String tone) {
    state = state.copyWith(tone: tone);
  }

  /// Generate a scenario from the form inputs.
  /// Validates all fields are filled first.
  Future<void> generate() async {
    if (!state.isFormValid) {
      state = state.copyWith(
        errorMessage: 'Please fill in all fields before generating.',
      );
      return;
    }

    state = state.copyWith(
      step: CreateScenarioStep.generating,
      errorMessage: null,
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      final scenario = await aiService.generateScenario(
        persona: state.persona.trim(),
        context: state.context.trim(),
        goal: state.goal.trim(),
        cefrLevel: state.cefrLevel,
        tone: state.tone,
      );

      state = state.copyWith(
        step: CreateScenarioStep.preview,
        generatedScenario: scenario,
        clearGeneratedScenario: false,
      );
    } catch (e) {
      state = state.copyWith(
        step: CreateScenarioStep.form,
        errorMessage: e.toString(),
      );
    }
  }

  /// Regenerate with the same inputs.
  Future<void> regenerate() async {
    state = state.copyWith(
      step: CreateScenarioStep.generating,
      errorMessage: null,
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      final scenario = await aiService.generateScenario(
        persona: state.persona.trim(),
        context: state.context.trim(),
        goal: state.goal.trim(),
        cefrLevel: state.cefrLevel,
        tone: state.tone,
      );

      state = state.copyWith(
        step: CreateScenarioStep.preview,
        generatedScenario: scenario,
        clearGeneratedScenario: false,
      );
    } catch (e) {
      state = state.copyWith(
        step: CreateScenarioStep.preview,
        errorMessage: e.toString(),
      );
    }
  }

  /// Go back to the form step to edit inputs.
  void edit() {
    state = state.copyWith(
      step: CreateScenarioStep.form,
      clearGeneratedScenario: true,
      errorMessage: null,
    );
  }

  /// Save the generated scenario to Firestore.
  Future<void> save() async {
    final scenario = state.generatedScenario;
    if (scenario == null) return;

    state = state.copyWith(step: CreateScenarioStep.saving, errorMessage: null);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = state.copyWith(
          step: CreateScenarioStep.preview,
          errorMessage: 'You must be signed in to save scenarios.',
        );
        return;
      }

      final scenarioService = ref.read(scenarioServiceProvider);
      await scenarioService.saveCustomScenario(
        uid: user.uid,
        scenario: scenario,
      );

      state = state.copyWith(step: CreateScenarioStep.saved);
    } catch (e) {
      state = state.copyWith(
        step: CreateScenarioStep.preview,
        errorMessage: 'Failed to save scenario: ${e.toString()}',
      );
    }
  }

  /// Reset to initial form state.
  void reset() {
    state = const CreateScenarioState();
  }
}

/// Provider for the create scenario ViewModel.
final createScenarioProvider =
    NotifierProvider<CreateScenarioViewModel, CreateScenarioState>(
  CreateScenarioViewModel.new,
);
