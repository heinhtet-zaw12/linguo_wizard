import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../feedback/viewmodels/feedback_viewmodel.dart';
import '../../scenario_selection/viewmodels/scenario_selection_viewmodel.dart';
import '../models/message.dart';
import '../../scenario_selection/models/scenario.dart';
import '../providers/conversation_provider.dart';
import '../viewmodels/conversation_viewmodel.dart';
import '../widgets/mic_button.dart';
import '../widgets/voice_message_bubble.dart';
import '../widgets/text_message_bubble.dart';
import '../../../core/theme/app_text_styles.dart';

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
  bool _hasNavigatedToFeedback = false;
  bool _hasCheckedSaved = false;
  bool _scenarioTimedOut = false;

  @override
  void initState() {
    super.initState();
    _scenario = ref.read(selectedScenarioProvider);

    // Fallback: if scenario never arrives (deep link, app restart), redirect after 3s.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_scenario == null && ref.read(selectedScenarioProvider) == null) {
        setState(() {
          _scenarioTimedOut = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lazily read the scenario on first dependency pass (after initState).
    _scenario ??= ref.read(selectedScenarioProvider);

    // Clear stale scoreData from a previous evaluation so the guard on line 278
    // (scoreData != null → navigate to feedback) doesn't trigger on re-entry.
    // Deferred via post-frame callback because Riverpod forbids modifying
    // providers during the widget tree build lifecycle (didChangeDependencies).
    final scenario = _scenario;
    if (scenario != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(conversationProvider(scenario).notifier).clearScoreData();
      });
    }

    _checkForSavedConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Persistence helpers ───

  Future<void> _checkForSavedConversation() async {
    if (_hasCheckedSaved) return;
    final scenario = _scenario;
    if (scenario == null) return;

    final vm = ref.read(conversationProvider(scenario).notifier);
    final hasSaved = await vm.hasSavedConversation(scenario);
    if (!hasSaved || !mounted) return;

    _hasCheckedSaved = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Saved Conversation Found',
          style: AppTextStyles.bodyMedium(),
        ),
        content: Text(
          'You have a saved conversation from earlier. '
          'Would you like to resume where you left off?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctx.pop();
              _startFresh();
            },
            child: Text(
              'Start Fresh',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              final snapshot = await vm.loadSavedConversation(scenario);
              if (snapshot != null && mounted) {
                vm.restoreConversation(snapshot);
              }
            },
            child: Text(
              'Resume',
              style: AppTextStyles.bodyMedium(color: AppColors.accentStart),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startFresh() async {
    final scenario = _scenario;
    if (scenario == null) return;
    final vm = ref.read(conversationProvider(scenario).notifier);
    await vm.startFreshConversation();
  }

  Future<bool> _onWillPop() async {
    final scenario = _scenario;
    if (scenario == null) return true;

    final vm = ref.read(conversationProvider(scenario).notifier);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Save Progress?',
          style: AppTextStyles.bodyMedium(),
        ),
        content: Text(
          'Do you want to save this conversation so you can continue later?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop('discard'),
            child: Text(
              'Discard',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => ctx.pop('save'),
            child: Text(
              'Save & Exit',
              style: AppTextStyles.bodyMedium(color: AppColors.accentStart),
            ),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await vm.saveConversation();
    } else if (result == 'discard') {
      await vm.deleteSavedConversation();
    }

    return true;
  }

  /// Show exit dialog when back button/gesture is triggered.
  void _showExitDialog() {
    final scenario = _scenario;
    if (scenario == null) {
      context.pop();
      return;
    }

    final vm = ref.read(conversationProvider(scenario).notifier);

    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Save Progress?',
          style: AppTextStyles.bodyMedium(),
        ),
        content: Text(
          'Do you want to save this conversation so you can continue later?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await vm.deleteSavedConversation();
              if (mounted) context.pop();
            },
            child: Text(
              'Discard',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await vm.saveConversation();
              if (mounted) context.pop();
            },
            child: Text(
              'Save & Exit',
              style: AppTextStyles.bodyMedium(color: AppColors.accentStart),
            ),
          ),
        ],
      ),
    );
  }

  // ─── User action forwarding ───

  void _onMicPressed() {
    HapticFeedback.lightImpact();
    final scenario = _scenario;
    if (scenario == null) return;
    ref.read(conversationProvider(scenario).notifier).onMicPressed();
  }

  void _onNewChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'New Conversation',
          style: AppTextStyles.bodyMedium(),
        ),
        content: Text(
          'Start a fresh conversation? Current progress will be lost.',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              _startFresh();
            },
            child: Text(
              'New Chat',
              style: AppTextStyles.bodyMedium(color: AppColors.accentStart),
            ),
          ),
        ],
      ),
    );
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

    // Scenario not yet selected.
    if (scenario == null) {
      if (_scenarioTimedOut) {
        // Fallback: scenario never arrived (deep link, app restart, etc.)
        return Scaffold(
          body: GradientBackground(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scenario selected',
                    style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please choose a scenario to start practicing.',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Browse Scenarios',
                    onPressed: () => context.go('/scenarios'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // Brief loading state while scenario is being passed from selection screen.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final asyncState = ref.watch(conversationProvider(scenario));
    final vm = ref.read(conversationProvider(scenario).notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
      body: GradientBackground(
        child: SafeArea(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: AppTextStyles.bodyMedium()),
          ),
          data: (state) {
            // Scroll to bottom when new messages arrive.
            if (state.messages.isNotEmpty) {
              _scrollToBottom();
            }

            // Navigate to feedback screen when evaluation completes (only once).
            if (state.scoreData != null && !state.isEvaluating && !_hasNavigatedToFeedback) {
              _hasNavigatedToFeedback = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Set the score data and newly earned badges before navigating.
                ref.read(currentScoreProvider.notifier).state = state.scoreData;
                ref.read(newlyEarnedBadgesProvider.notifier).state = state.newlyEarnedBadges;
                context.go('/feedback');
              });
            }

            // Show rate limit exceeded dialog.
            if (state.rateLimitExceeded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Daily Limit Reached',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    content: Text(
                      "You've used all your practices for today. Come back tomorrow!",
                      style: AppTextStyles.bodyMedium(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          vm.clearRateLimitError();
                          context.pop();
                        },
                        child: Text(
                          'OK',
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }

            // Show error dialog for AI/network failures.
            if (state.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Something went wrong',
                      style: AppTextStyles.bodyMedium(),
                    ),
                    content: Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodyMedium(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          vm.clearError();
                          context.pop();
                        },
                        child: Text(
                          'OK',
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }

            return Column(
              children: [
                _buildTopBar(scenario, state),
                _buildMessageList(state, vm),
                if (state.loopState == ConversationLoopState.recording &&
                    state.currentPartialTranscript.isNotEmpty)
                  _buildPartialTranscript(state.currentPartialTranscript),
                _buildBottomControls(state, vm),
              ],
            );
          },
        ),
        ),
        ),
      ),
    );
  }

  // ─── UI building blocks ───

  Widget _buildTopBar(Scenario scenario, ConversationState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => context.pop(),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: AppTextStyles.headingMedium(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  scenario.goalDescription,
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Thin gradient progress bar — driven by turn count (max 20)
                ClipRRect(
                  borderRadius: AppRadius.xxs,
                  child: Container(
                    height: 3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: (state.turnCount / 20).clamp(0.0, 1.0),
                        child: Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            tooltip: 'New Chat',
            onPressed: _onNewChat,
            color: AppColors.accentStart,
          ),
          IconButton(
            icon: Icon(
              state.textOnlyMode ? Icons.chat : Icons.record_voice_over,
              size: 22,
            ),
            tooltip: 'Text-only mode',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(conversationProvider(scenario).notifier).toggleTextOnlyMode();
            },
            color: state.textOnlyMode ? AppColors.accentCyan : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ConversationState state, ConversationViewModel vm) {
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

          final isPlaybackActive =
              state.playingMessageId == message.id;

          final isUser = message.sender == MessageSender.user;

          final showTextBubble = state.textOnlyMode && message.sender == MessageSender.ai;

          return showTextBubble
              ? TextMessageBubble(message: message)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: -0.1, duration: 300.ms, curve: Curves.easeOut)
              : VoiceMessageBubble(
            message: message,
            isPlaying: isSpeaking || isPlaybackActive,
            isPlaybackActive: isPlaybackActive,
            onPlayPause: message.sender == MessageSender.ai
                ? () {
                    if (isPlaybackActive) {
                      vm.stopPlayback();
                    } else {
                      vm.playMessage(message.id, message.transcript);
                    }
                  }
                : null,
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(
                begin: isUser ? 0.1 : -0.1,
                duration: 300.ms,
                curve: Curves.easeOut,
              );
        },
      ),
    );
  }

  Widget _buildPartialTranscript(String transcript) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6, vertical: 8),
      child: Text(
        transcript,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildBottomControls(ConversationState state, ConversationViewModel vm) {
    return Container(
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          if (state.turnCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Turn ${state.turnCount}',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
            ),
          MicButton(
            loopState: state.loopState,
            onPressed: _onMicPressed,
          ),
          const SizedBox(height: 8),
          Text(
            vm.micHint,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
          if (state.turnCount > 0 && state.loopState == ConversationLoopState.idle)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(
                label: 'End Conversation',
                isLoading: state.isEvaluating,
                onPressed: state.isEvaluating ? null : () => vm.endConversation(),
              ),
            ),
        ],
      ),
    );
  }
}
