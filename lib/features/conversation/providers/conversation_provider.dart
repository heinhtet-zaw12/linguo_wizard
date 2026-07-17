import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../../scenario_selection/models/scenario.dart';
import '../viewmodels/conversation_viewmodel.dart';

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

/// ViewModel provider, scoped per scenario.
final conversationProvider =
    AsyncNotifierProvider.family<ConversationViewModel, ConversationState, Scenario>(
  ConversationViewModel.new,
);
