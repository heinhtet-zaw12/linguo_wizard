import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../scenario_selection/providers/scenario_provider.dart';
import '../models/message.dart';
import '../models/scenario.dart';
import '../providers/conversation_provider.dart';
import '../widgets/mic_button.dart';
import '../widgets/voice_message_bubble.dart';

/// The main conversation screen — displays the voice message loop.
///
/// Manages STT/TTS/AI service initialization and orchestrates the
/// voice conversation state machine.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late final SttService _sttService;
  late final TtsService _ttsService;
  late final AiService _aiService;

  final ScrollController _scrollController = ScrollController();
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _sttService = SttService();
    _ttsService = TtsService();
    _aiService = AiService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_servicesInitialized) return;
    _servicesInitialized = true;
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _sttService.initialize();
    await _ttsService.initialize();

    final scenario = ref.read(selectedScenarioProvider);
    if (scenario == null || !mounted) return;

    // Initialize AI persona
    _aiService.initializePersona(
      personaName: scenario.personaName,
      personaDescription: scenario.personaDescription,
      scenarioGoal: scenario.goalDescription,
    );

    // Add opening message
    final openingMessage = Message.create(
      sender: MessageSender.ai,
      transcript: scenario.openingMessage,
    );

    // Set initial state
    ref.read(conversationStateProvider.notifier).state = ConversationState(
      scenario: scenario,
      messages: [openingMessage],
    );

    // Set up TTS completion handler
    _ttsService.setCompletionHandler(() {
      if (mounted) {
        final current = ref.read(conversationStateProvider);
        ref.read(conversationStateProvider.notifier).state = current.copyWith(
          loopState: ConversationLoopState.idle,
          isAiSpeaking: false,
        );
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onMicPressed() {
    final state = ref.read(conversationStateProvider);
    final loopState = state.loopState;

    if (loopState == ConversationLoopState.idle) {
      _startRecording();
    } else if (loopState == ConversationLoopState.recording) {
      _stopRecording();
    }
  }

  void _startRecording() {
    final state = ref.read(conversationStateProvider);
    if (state.turnCount >= AppConfig.maxConversationTurns) return;

    ref.read(conversationStateProvider.notifier).state = state.copyWith(
      loopState: ConversationLoopState.recording,
      isRecording: true,
      currentPartialTranscript: '',
    );

    _sttService.startListening(
      onResult: (result) {
        if (!mounted) return;
        final transcript = result.recognizedWords;
        if (result.finalResult) {
          _processFinalTranscript(transcript);
        } else {
          final current = ref.read(conversationStateProvider);
          ref.read(conversationStateProvider.notifier).state =
              current.copyWith(currentPartialTranscript: transcript);
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
      final current = ref.read(conversationStateProvider);
      ref.read(conversationStateProvider.notifier).state = current.copyWith(
        loopState: ConversationLoopState.idle,
        isRecording: false,
        currentPartialTranscript: '',
      );
      return;
    }

    // Transition to processing
    var current = ref.read(conversationStateProvider);
    ref.read(conversationStateProvider.notifier).state = current.copyWith(
      loopState: ConversationLoopState.processing,
      isRecording: false,
      currentPartialTranscript: '',
    );

    // Add user message
    final userMessage = Message.create(
      sender: MessageSender.user,
      transcript: transcript,
    );
    current = ref.read(conversationStateProvider);
    ref.read(conversationStateProvider.notifier).state = current.copyWith(
      messages: [...current.messages, userMessage],
      turnCount: current.turnCount + 1,
    );

    // Get AI response
    final aiResponseText = await _aiService.sendMessage(transcript);

    // Add AI message
    final aiMessage = Message.create(
      sender: MessageSender.ai,
      transcript: aiResponseText,
    );
    current = ref.read(conversationStateProvider);
    ref.read(conversationStateProvider.notifier).state = current.copyWith(
      messages: [...current.messages, aiMessage],
    );

    // Transition to speaking
    ref.read(conversationStateProvider.notifier).state = ref
        .read(conversationStateProvider)
        .copyWith(
          loopState: ConversationLoopState.speaking,
          isAiSpeaking: true,
        );

    // Speak the AI response (TTS completion handler will set back to idle)
    await _ttsService.speak(aiResponseText);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_servicesInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(conversationStateProvider);
    final scenario = state.scenario;

    // Scroll to bottom when new messages arrive
    if (state.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppColors.bgTop,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(scenario),
            _buildMessageList(state),
            if (state.loopState == ConversationLoopState.recording &&
                state.currentPartialTranscript.isNotEmpty)
              _buildPartialTranscript(state.currentPartialTranscript),
            _buildBottomControls(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Scenario? scenario) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario?.title ?? 'Conversation',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scenario?.goalDescription ?? '',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ConversationState state) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          final isSpeaking =
              state.loopState == ConversationLoopState.speaking &&
                  message.sender == MessageSender.ai &&
                  index == state.messages.length - 1;

          return VoiceMessageBubble(
            message: message,
            isPlaying: isSpeaking,
          );
        },
      ),
    );
  }

  Widget _buildPartialTranscript(String transcript) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        transcript,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          color: AppColors.textMuted.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildBottomControls(ConversationState state) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Column(
        children: [
          if (state.turnCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Turn ${state.turnCount}',
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          MicButton(
            loopState: state.loopState,
            onPressed: _onMicPressed,
          ),
          const SizedBox(height: 8),
          Text(
            _getMicHint(state.loopState),
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getMicHint(ConversationLoopState loopState) {
    switch (loopState) {
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
