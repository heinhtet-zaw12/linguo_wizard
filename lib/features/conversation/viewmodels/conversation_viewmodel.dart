import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../models/message.dart';
import '../models/scenario.dart';
import '../providers/conversation_provider.dart';

/// ViewModel for the conversation screen.
///
/// Orchestrates the voice conversation loop: STT → user message → AI → TTS → repeat.
/// Owns all business logic; the screen is a pure view layer that watches state
/// and forwards user actions here.
class ConversationViewModel extends StateNotifier<ConversationState> {
  ConversationViewModel({
    required this.scenario,
    SttService? sttService,
    TtsService? ttsService,
    AiService? aiService,
  })  : _sttService = sttService ?? SttService(),
        _ttsService = ttsService ?? TtsService(),
        _aiService = aiService ?? AiService(),
        super(const ConversationState());

  final Scenario scenario;
  final SttService _sttService;
  final TtsService _ttsService;
  final AiService _aiService;

  bool _initialized = false;

  /// Initialize services, AI persona, and seed the opening message.
  ///
  /// Must be called once from the screen's `initState` after the first frame.
  Future<void> init() async {
    if (_initialized || !mounted) return;
    _initialized = true;

    await _sttService.initialize();
    await _ttsService.initialize();

    if (!mounted) return;

    _aiService.initializePersona(
      personaName: scenario.personaName,
      personaDescription: scenario.personaDescription,
      scenarioGoal: scenario.goalDescription,
    );

    final openingMessage = Message.create(
      sender: MessageSender.ai,
      transcript: scenario.openingMessage,
    );

    state = state.copyWith(
      scenario: scenario,
      messages: [openingMessage],
    );

    _ttsService.setCompletionHandler(() {
      if (mounted) {
        state = state.copyWith(
          loopState: ConversationLoopState.idle,
          isAiSpeaking: false,
        );
      }
    });
  }

  bool get servicesReady => _initialized;

  // ─── Mic button actions ───

  /// Toggle recording on/off based on current loop state.
  void onMicPressed() {
    switch (state.loopState) {
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
    if (state.turnCount >= 20) return; // maxConversationTurns

    state = state.copyWith(
      loopState: ConversationLoopState.recording,
      isRecording: true,
      currentPartialTranscript: '',
    );

    _sttService.startListening(
      onResult: (result) {
        if (!mounted) return;
        if (result.finalResult) {
          _processFinalTranscript(result.recognizedWords);
        } else {
          state = state.copyWith(
            currentPartialTranscript: result.recognizedWords,
          );
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
      state = state.copyWith(
        loopState: ConversationLoopState.idle,
        isRecording: false,
        currentPartialTranscript: '',
      );
      return;
    }

    // Transition to processing
    state = state.copyWith(
      loopState: ConversationLoopState.processing,
      isRecording: false,
      currentPartialTranscript: '',
    );

    // Add user message
    final userMessage = Message.create(
      sender: MessageSender.user,
      transcript: transcript,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      turnCount: state.turnCount + 1,
    );

    // Get AI response
    final aiResponseText = await _aiService.sendMessage(transcript);
    if (!mounted) return;

    // Add AI message
    final aiMessage = Message.create(
      sender: MessageSender.ai,
      transcript: aiResponseText,
    );
    state = state.copyWith(messages: [...state.messages, aiMessage]);

    // Transition to speaking
    state = state.copyWith(
      loopState: ConversationLoopState.speaking,
      isAiSpeaking: true,
    );

    // Speak the AI response (TTS completion handler sets back to idle)
    await _ttsService.speak(aiResponseText);
  }

  // ─── Navigation helpers ───

  /// Hint text shown below the mic button.
  String get micHint {
    switch (state.loopState) {
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
