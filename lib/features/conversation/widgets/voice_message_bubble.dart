import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/message.dart';

/// A voice message bubble — audio-first with collapsible transcript.
///
/// - AI bubbles show a Play/Pause button and waveform. Transcript hidden
///   behind a toggle ("Show Transcript" / "Hide Transcript").
/// - User bubbles show a static mic icon with transcript.
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
    final backgroundColor = _isUser ? AppColors.primaryPink : Colors.white;
    final iconColor = _isUser ? Colors.white : AppColors.primaryPink;
    final shadowColor = _isUser ? AppColors.shadowPink : Colors.black12;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(_isUser ? 16 : 4),
          bottomRight: Radius.circular(_isUser ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button (AI) or mic icon (user)
          _buildPlayButton(iconColor),
          const SizedBox(width: 8),
          _buildAudioWaveform(iconColor),
        ],
      ),
    );
  }

  Widget _buildPlayButton(Color color) {
    if (_isUser) {
      return const Icon(Icons.mic, color: Colors.white, size: 20);
    }

    final isThisPlaying = widget.isPlaybackActive;
    return GestureDetector(
      onTap: widget.onPlayPause,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          key: ValueKey(isThisPlaying),
          color: color,
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
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 3,
            height: widget.isPlaybackActive ? heights[i] * 1.3 : heights[i],
            decoration: BoxDecoration(
              color: color.withValues(alpha: widget.isPlaybackActive ? 0.9 : 0.5),
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
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 13,
          color: AppColors.textMuted,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: () => setState(() => _showTranscript = !_showTranscript),
      child: Text(
        _showTranscript ? 'Hide Transcript' : 'Show Transcript',
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryPink.withValues(alpha: 0.8),
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primaryPink.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
