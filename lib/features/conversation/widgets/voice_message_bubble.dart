import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/message.dart';

/// A voice message bubble — right-aligned for user, left-aligned for AI.
///
/// Displays an audio indicator icon inside the bubble and the transcript
/// text beneath it in a smaller muted font.
class VoiceMessageBubble extends StatelessWidget {
  final Message message;
  final bool isPlaying;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    this.isPlaying = false,
  });

  bool get _isUser => message.sender == MessageSender.user;

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
            const SizedBox(height: 4),
            _buildTranscript(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          _buildAudioIcon(iconColor),
          const SizedBox(width: 8),
          _buildAudioWaveform(iconColor),
        ],
      ),
    );
  }

  Widget _buildAudioIcon(Color color) {
    if (isPlaying && !_isUser) {
      return _AnimatedSpeakerIcon(color: color);
    }
    return Icon(
      _isUser ? Icons.mic : Icons.volume_up,
      color: color,
      size: 20,
    );
  }

  Widget _buildAudioWaveform(Color color) {
    // Simple static waveform bars to represent audio
    return SizedBox(
      width: 80,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(12, (i) {
          final heights = [8.0, 14.0, 6.0, 18.0, 10.0, 16.0, 4.0, 12.0, 8.0, 15.0, 6.0, 10.0];
          return Container(
            width: 3,
            height: heights[i],
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6),
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
        message.transcript,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 13,
          color: AppColors.textMuted,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Animated speaker icon that pulses while AI is speaking.
class _AnimatedSpeakerIcon extends StatefulWidget {
  final Color color;

  const _AnimatedSpeakerIcon({required this.color});

  @override
  State<_AnimatedSpeakerIcon> createState() => _AnimatedSpeakerIconState();
}

class _AnimatedSpeakerIconState extends State<_AnimatedSpeakerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.volume_up,
            color: widget.color,
            size: 20,
          ),
        );
      },
    );
  }
}
