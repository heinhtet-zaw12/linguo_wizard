import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/mistake_record.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/evaluation_service.dart';
import '../../../core/services/rate_limiter.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../feedback/models/score_data.dart';
import '../../feedback/viewmodels/feedback_viewmodel.dart';
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
  late final EvaluationService _evaluationService;
  final RateLimiterService _rateLimiter = RateLimiterService();

  /// Initialize services, AI persona, and seed the opening message.
  @override
  Future<ConversationState> build(Scenario scenario) async {
    _sttService = SttService();
    _ttsService = TtsService();
    _aiService = AiService();
    _evaluationService = EvaluationService();

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
  ///
  /// Checks rate limit before starting a new recording.
  void onMicPressed() async {
    final current = state.value;
    if (current == null) return;

    switch (current.loopState) {
      case ConversationLoopState.idle:
        // Check rate limit before starting a new conversation turn.
        if (AppConfig.rateLimitEnabled) {
          final user = ref.read(currentUserProvider);
          final isAuth = user != null && !user.isAnonymous;
          bool canMakeCall;
          if (isAuth) {
            canMakeCall = await _rateLimiter.canMakeCallForUser(user.uid);
          } else {
            canMakeCall = await _rateLimiter.canMakeCall();
          }
          if (!canMakeCall) {
            state = AsyncData(current.copyWith(rateLimitExceeded: true));
            return;
          }
          // Record the call before starting.
          if (isAuth) {
            await _rateLimiter.recordCallForUser(user.uid);
          } else {
            await _rateLimiter.recordCall();
          }
        }
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

    // Call the AI evaluation service.
    final scoreData = await _evaluationService.evaluateGoal(
      scenarioGoal: current.scenario!.goalDescription,
      transcript: transcript,
    );

    // Update state with evaluation results.
    state = AsyncData(
      (state.value ?? current).copyWith(
        isEvaluating: false,
        scoreData: scoreData,
      ),
    );

    // Trigger gamification updates and sync to Firestore (fire-and-forget).
    _triggerGamification(current.scenario!, scoreData);
  }

  /// Clear the rate limit exceeded error state.
  ///
  /// Called when the user dismisses the rate limit dialog.
  void clearRateLimitError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(rateLimitExceeded: false));
  }

  /// Clear the general error message.
  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearError: true));
  }

  // ─── Gamification & Firestore sync ───

  /// Trigger gamification updates and sync scenario results to Firestore.
  ///
  /// After a successful evaluation:
  /// 1. Update streak via GamificationService
  /// 2. Award XP (AppConfig.xpPerScenario = 50)
  /// 3. Check badge eligibility
  /// 4. Extract grammar corrections into SRS
  /// 5. Save mistake records
  /// 6. Save scenario results
  ///
  /// All writes are fire-and-forget — failures don't affect the UI.
  /// Only runs for authenticated (non-guest) users.
  Future<void> _triggerGamification(Scenario scenario, ScoreData score) async {
    final user = ref.read(currentUserProvider);
    if (user == null || user.isAnonymous) return;

    try {
      final fs = ref.read(firestoreServiceProvider);
      final gamification = ref.read(gamificationServiceProvider);
      final srs = ref.read(srsServiceProvider);
      final uid = user.uid;

      // 1. Update streak.
      final streakData = await gamification.updateStreak(uid);

      // 2. Award XP.
      await gamification.awardXp(uid, AppConfig.xpPerScenario);

      // 3. Read updated progress for badge check and scenario save.
      final results = await Future.wait<Object?>([
        fs.getTotalXp(uid),
        fs.getScenariosCompleted(uid),
        fs.getScenarios(uid),
      ]);

      final totalXp = results[0] as int;
      final scenariosCompleted = results[1] as int;
      final scenarios = results[2] as List<Map<String, dynamic>>;

      // 4. Check badges.
      final newlyEarnedBadges = await gamification.checkBadges(
        uid,
        totalXp: totalXp,
        currentStreak: streakData.currentStreak,
        scenariosCompleted: scenariosCompleted,
        lastScore: score,
      );

      // Store newly earned badges in state for FeedbackScreen to display.
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(
          newlyEarnedBadges: newlyEarnedBadges,
        ));
      }

      // Also set the provider so FeedbackScreen can read it.
      ref.read(newlyEarnedBadgesProvider.notifier).state = newlyEarnedBadges;

      // 5. Extract grammar corrections into SRS (fire-and-forget).
      srs.addItemsFromScore(uid, score);

      // 6. Save mistake records from grammar corrections (fire-and-forget).
      for (final correction in score.grammarCorrections) {
        final mistake = MistakeRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: correction.original,
          category: 'grammar',
          correctedText: correction.corrected,
          explanation: correction.explanation,
          scenarioId: scenario.id,
          recordedAt: DateTime.now(),
        );
        fs.saveMistake(uid, mistake);
      }

      // 7. Save scenario results (fire-and-forget).
      final existingScenario = scenarios.firstWhere(
        (s) => s['id'] == scenario.id,
        orElse: () => {},
      );
      final existingAttempts = existingScenario['attempts'] as int? ?? 0;
      final existingScores =
          (existingScenario['scores'] as List<dynamic>?) ?? [];

      final newScoreEntry = {
        'overall': score.overallScore,
        'fluency': score.fluencyScore,
        'grammar': score.grammarScore,
        'vocabulary': score.vocabularyScore,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await fs.saveScenarioResult(
        uid,
        scenario.id,
        bestScore: score.overallScore.toDouble(),
        attempts: existingAttempts + 1,
        scores: [
          ...existingScores.map((e) => Map<String, dynamic>.from(e as Map)),
          newScoreEntry,
        ],
      );
    } catch (_) {
      // Gamification sync failed — non-critical, data will sync on next attempt.
    }
  }
}
