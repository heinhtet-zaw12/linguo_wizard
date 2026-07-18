import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../../scenario_selection/models/scenario.dart';
import '../../feedback/models/score_data.dart';
import '../viewmodels/conversation_viewmodel.dart';

/// State machine phases for the voice conversation loop.
enum ConversationLoopState { idle, recording, processing, speaking }

/// Immutable state for the conversation screen.
class ConversationState {
  final List<Message> messages;
  final bool isRecording;
  final bool isAiSpeaking;
  final bool isEvaluating;
  final bool rateLimitExceeded;
  final String currentPartialTranscript;
  final ConversationLoopState loopState;
  final Scenario? scenario;
  final int turnCount;
  final ScoreData? scoreData;

  const ConversationState({
    this.messages = const [],
    this.isRecording = false,
    this.isAiSpeaking = false,
    this.isEvaluating = false,
    this.rateLimitExceeded = false,
    this.currentPartialTranscript = '',
    this.loopState = ConversationLoopState.idle,
    this.scenario,
    this.turnCount = 0,
    this.scoreData,
  });

  ConversationState copyWith({
    List<Message>? messages,
    bool? isRecording,
    bool? isAiSpeaking,
    bool? isEvaluating,
    bool? rateLimitExceeded,
    String? currentPartialTranscript,
    ConversationLoopState? loopState,
    Scenario? scenario,
    int? turnCount,
    ScoreData? scoreData,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isRecording: isRecording ?? this.isRecording,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      rateLimitExceeded: rateLimitExceeded ?? this.rateLimitExceeded,
      currentPartialTranscript:
          currentPartialTranscript ?? this.currentPartialTranscript,
      loopState: loopState ?? this.loopState,
      scenario: scenario ?? this.scenario,
      turnCount: turnCount ?? this.turnCount,
      scoreData: scoreData ?? this.scoreData,
    );
  }
}

/// ViewModel provider, scoped per scenario.
final conversationProvider =
    AsyncNotifierProvider.family<ConversationViewModel, ConversationState, Scenario>(
  ConversationViewModel.new,
);
