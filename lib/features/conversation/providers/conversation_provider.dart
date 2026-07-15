import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../models/message.dart';
import '../models/scenario.dart';

/// State machine phases for the voice conversation loop.
enum ConversationLoopState { idle, recording, processing, speaking }

/// Immutable state for the conversation screen.
class ConversationState {
  final List<Message> messages;
  final bool isRecording;
  final bool isAiSpeaking;
  final String currentPartialTranscript;
  final ConversationLoopState loopState;
  final Scenario? scenario;
  final int turnCount;

  const ConversationState({
    this.messages = const [],
    this.isRecording = false,
    this.isAiSpeaking = false,
    this.currentPartialTranscript = '',
    this.loopState = ConversationLoopState.idle,
    this.scenario,
    this.turnCount = 0,
  });

  ConversationState copyWith({
    List<Message>? messages,
    bool? isRecording,
    bool? isAiSpeaking,
    String? currentPartialTranscript,
    ConversationLoopState? loopState,
    Scenario? scenario,
    int? turnCount,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isRecording: isRecording ?? this.isRecording,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      currentPartialTranscript:
          currentPartialTranscript ?? this.currentPartialTranscript,
      loopState: loopState ?? this.loopState,
      scenario: scenario ?? this.scenario,
      turnCount: turnCount ?? this.turnCount,
    );
  }
}

/// Orchestrates the STT -> AI -> TTS conversation loop.
class ConversationNotifier extends StateNotifier<ConversationState> {
  final TtsService _ttsService;
  final AiService _aiService;

  ConversationNotifier({
    required SttService sttService,
    required TtsService ttsService,
    required AiService aiService,
  })  : _ttsService = ttsService,
        _aiService = aiService,
        super(const ConversationState());

  /// Initializes the conversation with a scenario, sets up the AI persona,
  /// and adds the scenario's opening message as the first AI bubble.
  void initializeConversation(Scenario scenario) {
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
  }

  /// Transitions to RECORDING state. Only allowed when idle.
  void startRecording() {
    if (state.loopState != ConversationLoopState.idle) return;
    if (state.turnCount >= AppConfig.maxConversationTurns) return;

    state = state.copyWith(
      loopState: ConversationLoopState.recording,
      isRecording: true,
      currentPartialTranscript: '',
    );
  }

  /// Updates the partial transcript displayed while recording.
  void onPartialResult(String transcript) {
    state = state.copyWith(currentPartialTranscript: transcript);
  }

  /// Transitions to PROCESSING and kicks off the AI response pipeline.
  void stopRecording({required String finalTranscript}) {
    state = state.copyWith(
      loopState: ConversationLoopState.processing,
      isRecording: false,
      currentPartialTranscript: '',
    );
    processUserMessage(finalTranscript);
  }

  /// Processes a user message: adds it to the list, calls the AI, and speaks the response.
  Future<void> processUserMessage(String transcript) async {
    if (transcript.trim().isEmpty) {
      state = state.copyWith(loopState: ConversationLoopState.idle);
      return;
    }

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

    // Add AI message
    final aiMessage = Message.create(
      sender: MessageSender.ai,
      transcript: aiResponseText,
    );
    state = state.copyWith(
      messages: [...state.messages, aiMessage],
    );

    // Speak the AI response
    await speakAiMessage(aiResponseText);
  }

  /// Speaks the AI response via TTS and transitions back to IDLE when done.
  Future<void> speakAiMessage(String text) async {
    state = state.copyWith(
      loopState: ConversationLoopState.speaking,
      isAiSpeaking: true,
    );

    await _ttsService.speak(text);

    state = state.copyWith(
      loopState: ConversationLoopState.idle,
      isAiSpeaking: false,
    );
  }

  /// Resets the conversation to initial state.
  void reset() {
    state = const ConversationState();
  }
}

/// Provides the conversation state notifier for a given set of services.
///
/// This is a family provider — create instances via `conversationProviderFamily(stt, tts, ai)`.
final conversationProviderFamily =
    StateNotifierProvider.family<ConversationNotifier, ConversationState,
        ({SttService stt, TtsService tts, AiService ai})>((ref, services) {
  return ConversationNotifier(
    sttService: services.stt,
    ttsService: services.tts,
    aiService: services.ai,
  );
});
