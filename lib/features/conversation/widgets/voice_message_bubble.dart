import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/app_card.dart';
import '../models/message.dart';
import '../../../core/theme/app_text_styles.dart';

/// A voice message bubble — audio-first with collapsible transcript.
///
/// - User bubbles: gradient fill (accentStart → accentEnd), white text
/// - AI bubbles: glass fill (GlassCard) with cyan glow border
class VoiceMessageBubble extends StatefulWidget {
  final Message message;
  final bool isPlaying;
  final bool isPlaybackActive;
  final VoidCallback? onPlayPause;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    this.isPlaying = false,
    this.isPlaybackActive = false,
    this.onPlayPause,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  bool _showTranscript = false;

  bool get _isUser => widget.message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment:
              _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildBubble(),
            if (_showTranscript) ...[
              const SizedBox(height: 4),
              _buildTranscript(),
            ],
            const SizedBox(height: 2),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble() {
    if (_isUser) {
      return _buildUserBubble();
    }
    return _buildAiBubble();
  }

  Widget _buildUserBubble() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: AppRadius.bubbleUser,
        boxShadow: [
          BoxShadow(
            color: Color(0x4D6366F1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          _buildAudioWaveform(Colors.white),
        ],
      ),
    );
  }

  Widget _buildAiBubble() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: AppRadius.bubbleAi,
      glowColor: AppColors.accentCyanGlow.withValues(alpha: 0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayButton(),
          const SizedBox(width: 8),
          _buildAudioWaveform(AppColors.accentCyan),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    final isThisPlaying = widget.isPlaybackActive;
    return GestureDetector(
      onTap: widget.onPlayPause,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          key: ValueKey(isThisPlaying),
          color: AppColors.accentCyan,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildAudioWaveform(Color color) {
    return SizedBox(
      width: 80,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(12, (i) {
          final heights = [8.0, 14.0, 6.0, 18.0, 10.0, 16.0, 4.0, 12.0, 8.0, 15.0, 6.0, 10.0];
          final barColor = Color.lerp(AppColors.accentStart, AppColors.accentEnd, i / 12.0)!;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 3,
            height: widget.isPlaybackActive ? heights[i] * 1.3 : heights[i],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  barColor.withValues(alpha: widget.isPlaybackActive ? 0.9 : 0.5),
                  color.withValues(alpha: widget.isPlaybackActive ? 0.9 : 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTranscript() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Text(
        widget.message.transcript,
        style: AppTextStyles.labelMedium(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => _showTranscript = !_showTranscript),
      child: Text(
        _showTranscript ? 'Hide Transcript' : 'Show Transcript',
        style: AppTextStyles.bodyMedium(color: AppColors.accentCyan).copyWith(
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentCyan.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
