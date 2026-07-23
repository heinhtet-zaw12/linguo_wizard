import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/badge.dart';
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
  final List<Badge> newlyEarnedBadges;
  final String? errorMessage;
  final String? playingMessageId;

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
    this.newlyEarnedBadges = const [],
    this.errorMessage,
    this.playingMessageId,
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
    List<Badge>? newlyEarnedBadges,
    String? errorMessage,
    String? playingMessageId,
    bool clearError = false,
    bool clearPlayingMessageId = false,
    bool clearScoreData = false,
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
      scoreData: clearScoreData ? null : (scoreData ?? this.scoreData),
      newlyEarnedBadges: newlyEarnedBadges ?? this.newlyEarnedBadges,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      playingMessageId: clearPlayingMessageId
          ? null
          : (playingMessageId ?? this.playingMessageId),
    );
  }
}

/// ViewModel provider, scoped per scenario.
final conversationProvider =
    AsyncNotifierProvider.family<ConversationViewModel, ConversationState, Scenario>(
  ConversationViewModel.new,
);
