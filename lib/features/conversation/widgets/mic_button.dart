import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/conversation_provider.dart';

/// Large circular mic button that reflects the current conversation loop state.
///
/// - IDLE: solid primary pink, mic icon, tappable to start recording
/// - RECORDING: pulsing coral, stop icon, tappable to stop recording
/// - PROCESSING: loading spinner, disabled
/// - SPEAKING: greyed out, volume icon, disabled
class MicButton extends StatefulWidget {
  final ConversationLoopState loopState;
  final VoidCallback? onPressed;

  const MicButton({
    super.key,
    required this.loopState,
    this.onPressed,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loopState == ConversationLoopState.recording) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.loopState == ConversationLoopState.recording
            ? _pulseAnimation.value
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _backgroundColor,
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: _buildIcon()),
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.loopState == ConversationLoopState.idle ||
        widget.loopState == ConversationLoopState.recording) {
      widget.onPressed?.call();
    }
  }

  Color get _backgroundColor {
    switch (widget.loopState) {
      case ConversationLoopState.idle:
        return AppColors.primaryPink;
      case ConversationLoopState.recording:
        return AppColors.accentCoral;
      case ConversationLoopState.processing:
        return Colors.grey.shade300;
      case ConversationLoopState.speaking:
        return Colors.grey.shade300;
    }
  }

  Color get _shadowColor {
    switch (widget.loopState) {
      case ConversationLoopState.idle:
        return AppColors.shadowPink;
      case ConversationLoopState.recording:
        return AppColors.accentCoral.withValues(alpha: 0.3);
      case ConversationLoopState.processing:
      case ConversationLoopState.speaking:
        return Colors.black12;
    }
  }

  Widget _buildIcon() {
    switch (widget.loopState) {
      case ConversationLoopState.idle:
        return const Icon(Icons.mic, color: Colors.white, size: 32);
      case ConversationLoopState.recording:
        return const Icon(Icons.stop, color: Colors.white, size: 32);
      case ConversationLoopState.processing:
        return const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
      case ConversationLoopState.speaking:
        return Icon(Icons.volume_up, color: Colors.grey.shade600, size: 32);
    }
  }
}
