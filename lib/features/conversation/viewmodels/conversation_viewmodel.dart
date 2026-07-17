import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../models/message.dart';
import '../../scenario_selection/models/scenario.dart';
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

  /// Initialize services, AI persona, and seed the opening message.
  @override
  Future<ConversationState> build(Scenario scenario) async {
    _sttService = SttService();
    _ttsService = TtsService();
    _aiService = AiService();

    await _sttService.initialize();
    await _ttsService.initialize();

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
  void onMicPressed() {
    final current = state.value;
    if (current == null) return;

    switch (current.loopState) {
      case ConversationLoopState.idle:
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
    );
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

    // Get AI response
    final aiResponseText = await _aiService.sendMessage(transcript);
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
}
