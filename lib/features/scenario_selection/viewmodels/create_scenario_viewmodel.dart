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
    state = state.copyWith(persona: _sanitizeInput(value), errorMessage: null);
  }

  void setContext(String value) {
    state = state.copyWith(context: _sanitizeInput(value), errorMessage: null);
  }

  void setGoal(String value) {
    state = state.copyWith(goal: _sanitizeInput(value), errorMessage: null);
  }

  /// Sanitize user input by stripping control characters and trimming whitespace.
  String _sanitizeInput(String input) {
    // Strip control characters (except newlines and tabs) and trim
    return input
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .trim();
  }

  void setCefrLevel(String level) {
    state = state.copyWith(cefrLevel: level);
  }

  void setTone(String tone) {
    state = state.copyWith(tone: tone);
  }

  /// Generate a scenario from the form inputs.
  /// Validates all fields are filled and within length limits.
  Future<void> generate() async {
    if (!state.isFormValid) {
      state = state.copyWith(
        errorMessage: 'Please fill in all fields before generating.',
      );
      return;
    }

    // Validate input lengths to prevent API abuse
    if (state.persona.length > 100) {
      state = state.copyWith(
        errorMessage: 'Persona description is too long (max 100 characters).',
      );
      return;
    }
    if (state.context.length > 150) {
      state = state.copyWith(
        errorMessage: 'Context is too long (max 150 characters).',
      );
      return;
    }
    if (state.goal.length > 200) {
      state = state.copyWith(
        errorMessage: 'Goal is too long (max 200 characters).',
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
    // Validate input lengths before regenerating
    if (state.persona.length > 100 || state.context.length > 150 || state.goal.length > 200) {
      state = state.copyWith(
        step: CreateScenarioStep.form,
        errorMessage: 'Input exceeds maximum length. Please edit your scenario.',
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
