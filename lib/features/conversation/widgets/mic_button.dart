import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_shadows.dart';
import '../providers/conversation_provider.dart';

/// Large circular mic button that reflects the current conversation loop state.
///
/// - IDLE: gradient fill (accentStart → accentEnd), mic icon, tappable
/// - RECORDING: accentCyan fill, stop icon, 3 pulsing concentric rings
/// - PROCESSING: gradient progress spinner, disabled
/// - SPEAKING: glass fill, volume icon in accentCyan, disabled
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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

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

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _pressAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutBack),
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
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.loopState == ConversationLoopState.idle ||
        widget.loopState == ConversationLoopState.recording) {
      _pressController.forward(from: 0.0);
      widget.onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pressAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing concentric rings (recording state only)
              if (widget.loopState == ConversationLoopState.recording) ...[
                _buildPulseRing(0),
                _buildPulseRing(1),
                _buildPulseRing(2),
              ],
              child!,
            ],
          );
        },
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: AppSizing.micButtonSize,
            height: AppSizing.micButtonSize,
            decoration: _buildDecoration(),
            child: Center(child: _buildIcon()),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseRing(int index) {
    final delay = index * 267.0; // stagger 3 rings across 800ms
    final progress = (_pulseController.value + (delay / 800.0)) % 1.0;
    final size = AppSizing.micButtonSize + (48.0 * progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.6;

    return AnimatedContainer(
      duration: Duration.zero,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: opacity),
          width: 2.0,
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.loopState) {
      case ConversationLoopState.idle:
        return BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.accent,
          boxShadow: AppShadows.glowBlue,
        );
      case ConversationLoopState.recording:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accentCyan,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyanGlow.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        );
      case ConversationLoopState.processing:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface2,
        );
      case ConversationLoopState.speaking:
        return BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceGlass,
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        );
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
            color: AppColors.accentStart,
            strokeWidth: 3,
          ),
        );
      case ConversationLoopState.speaking:
        return const Icon(Icons.volume_up, color: AppColors.accentCyan, size: 32);
    }
  }
}
