import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/evaluation_service.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../models/message.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../feedback/models/score_data.dart';
import '../providers/conversation_provider.dart';

/// ViewModel for the conversation screen.
///
/// Orchestrates the voice conversation loop: STT → user message → AI → TTS → repeat.
/// Owns all business logic; the screen is a pure view layer that watches state
/// and forwards user actions here.
class ConversationViewModel extends FamilyAsyncNotifier<ConversationState, Scenario> {
  late final SttService _sttService;
  late final TtsService _ttsService;
  late final AiService _aiService;
  late final EvaluationService _evaluationService;
  final RateLimiterService _rateLimiter = RateLimiterService();
  bool _servicesInitialized = false;

  /// Initialize services, AI persona, and seed the opening message.
  @override
  Future<ConversationState> build(Scenario scenario) async {
    // Clear any stale scoreData from a previous conversation session.
    // This runs synchronously before the screen can read the state,
    // preventing the feedback navigation guard from firing on re-entry.
    state = const AsyncData(ConversationState());

    if (!_servicesInitialized) {
      _sttService = SttService();
      _ttsService = TtsService();
      _aiService = AiService();
      _evaluationService = EvaluationService();
      await _sttService.initialize();
      await _ttsService.initialize();
      _servicesInitialized = true;
    }

    _aiService.initializePersona(
      personaName: scenario.personaName,
      personaDescription: scenario.personaDescription,
      scenarioGoal: scenario.goalDescription,
    );

    final openingMessage = Message.create(
      sender: MessageSender.ai,
      transcript: scenario.openingMessage,
    );

    _ttsService.setCompletionHandler(() {
      try {
        final current = state.value;
        if (current != null) {
          state = AsyncData(current.copyWith(
            loopState: ConversationLoopState.idle,
            isAiSpeaking: false,
          ));
        }
      } catch (_) {
        // Provider disposed — ignore.
      }
    });

    return ConversationState(
      scenario: scenario,
      messages: [openingMessage],
    );
  }

  // ─── Mic button actions ───

  /// Toggle recording on/off based on current loop state.
  ///
  /// Checks rate limit before starting a new recording.
  void onMicPressed() async {
    final current = state.value;
    if (current == null) return;

    switch (current.loopState) {
      case ConversationLoopState.idle:
        // Check rate limit before starting a new conversation turn.
        final canMakeCall = await _rateLimiter.canMakeCall();
        if (!canMakeCall) {
          state = AsyncData(current.copyWith(rateLimitExceeded: true));
          return;
        }
        // Record the call before starting.
        await _rateLimiter.recordCall();
        _startRecording();
      case ConversationLoopState.recording:
        _stopRecording();
      case ConversationLoopState.processing:
      case ConversationLoopState.speaking:
        break; // Mic is disabled during these states
    }
  }

  void _startRecording() {
    final current = state.value;
    if (current == null) return;
    if (current.turnCount >= 20) return; // maxConversationTurns

    state = AsyncData(current.copyWith(
      loopState: ConversationLoopState.recording,
      isRecording: true,
      currentPartialTranscript: '',
    ));

    _sttService.startListening(
      onResult: (result) {
        if (result.finalResult) {
          _processFinalTranscript(result.recognizedWords);
        } else {
          final current = state.value;
          if (current != null) {
            state = AsyncData(current.copyWith(
              currentPartialTranscript: result.recognizedWords,
            ));
          }
        }
      },
    ).catchError((_) {
      // Mic permission denied or STT failure — reset to idle.
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(
          loopState: ConversationLoopState.idle,
          isRecording: false,
          errorMessage: 'Could not access microphone. Please check permissions.',
        ));
      }
    });
  }

  void _stopRecording() {
    _sttService.stopListening();
    // The onResult callback with finalResult=true will handle the transition
  }

  Future<void> _processFinalTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(
          loopState: ConversationLoopState.idle,
          isRecording: false,
          currentPartialTranscript: '',
        ));
      }
      return;
    }

    var current = state.value;
    if (current == null) return;

    // Transition to processing
    state = AsyncData(current.copyWith(
      loopState: ConversationLoopState.processing,
      isRecording: false,
      currentPartialTranscript: '',
    ));

    // Add user message
    final userMessage = Message.create(
      sender: MessageSender.user,
      transcript: transcript,
    );
    current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      messages: [...current.messages, userMessage],
      turnCount: current.turnCount + 1,
    ));

    // Get AI response — handle network/API errors gracefully.
    String aiResponseText;
    try {
      aiResponseText = await _aiService.sendMessage(transcript);
    } catch (e) {
      current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(
          loopState: ConversationLoopState.idle,
          errorMessage: 'AI response failed. Check your connection and try again.',
        ));
      }
      return;
    }

    // Add AI message
    current = state.value;
    if (current == null) return;
    final aiMessage = Message.create(
      sender: MessageSender.ai,
      transcript: aiResponseText,
    );
    state = AsyncData(current.copyWith(messages: [...current.messages, aiMessage]));

    // Transition to speaking
    current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      loopState: ConversationLoopState.speaking,
      isAiSpeaking: true,
    ));

    // Speak the AI response (TTS completion handler sets back to idle)
    await _ttsService.speak(aiResponseText);
  }

  // ─── Navigation helpers ───

  /// Hint text shown below the mic button.
  String get micHint {
    final current = state.value;
    if (current == null) return '';
    switch (current.loopState) {
      case ConversationLoopState.idle:
        return 'Tap to speak';
      case ConversationLoopState.recording:
        return 'Listening... tap to stop';
      case ConversationLoopState.processing:
        return 'Thinking...';
      case ConversationLoopState.speaking:
        return 'AI is speaking...';
    }
  }

  /// End the conversation and trigger the evaluation flow.
  ///
  /// Stops any playing audio, sets the evaluating state, builds a transcript,
  /// and calls [EvaluationService] to score the conversation. The screen
  /// watches [ConversationState.scoreData] and navigates to the feedback
  /// screen when evaluation completes.
  Future<void> endConversation() async {
    final current = state.value;
    if (current == null || current.isEvaluating) return;

    // Stop any playing audio.
    await _ttsService.stop();

    // Transition to evaluating state.
    state = AsyncData(current.copyWith(
      loopState: ConversationLoopState.idle,
      isAiSpeaking: false,
      isRecording: false,
      isEvaluating: true,
    ));

    // Build transcript from messages list.
    final transcript = current.messages
        .map((m) => '${m.sender == MessageSender.user ? "User" : "AI"}: ${m.transcript}')
        .join('\n');

    // Call the AI evaluation service — fallback on failure.
    ScoreData scoreData;
    try {
      scoreData = await _evaluationService.evaluateGoal(
        scenarioGoal: current.scenario!.goalDescription,
        transcript: transcript,
      );
    } catch (_) {
      scoreData = ScoreData.fallback();
    }

    // Update state with evaluation results.
    state = AsyncData(
      (state.value ?? current).copyWith(
        isEvaluating: false,
        scoreData: scoreData,
      ),
    );
  }

  /// Clear the rate limit exceeded error state.
  ///
  /// Called when the user dismisses the rate limit dialog.
  void clearRateLimitError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(rateLimitExceeded: false));
  }

  /// Clear the current error message.
  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearError: true));
  }

}
