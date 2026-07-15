import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';
import '../models/message.dart';
import '../models/scenario.dart';
import '../providers/conversation_provider.dart';
import '../viewmodels/conversation_viewmodel.dart';
import '../widgets/mic_button.dart';
import '../widgets/voice_message_bubble.dart';

/// The main conversation screen — displays the voice message loop.
///
/// Pure view layer: watches [conversationProvider] state and forwards
/// user actions (mic taps) to the ViewModel. Zero business logic here.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  Scenario? _scenario;

  @override
  void initState() {
    super.initState();
    _scenario = ref.read(selectedScenarioProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lazily read the scenario on first dependency pass (after initState).
    _scenario ??= ref.read(selectedScenarioProvider);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── User action forwarding ───

  void _onMicPressed() {
    final scenario = _scenario;
    if (scenario == null) return;
    ref.read(conversationProvider(scenario).notifier).onMicPressed();
  }

  // ─── Helpers ───

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

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final scenario = _scenario;

    // Loading state — scenario not yet selected.
    if (scenario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(conversationProvider(scenario));
    final vm = ref.read(conversationProvider(scenario).notifier);

    // Scroll to bottom when new messages arrive.
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
            _buildBottomControls(state, vm),
          ],
        ),
      ),
    );
  }

  // ─── UI building blocks ───

  Widget _buildTopBar(Scenario scenario) {
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
                  scenario.title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scenario.goalDescription,
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

  Widget _buildBottomControls(ConversationState state, ConversationViewModel vm) {
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
            vm.micHint,
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
}
