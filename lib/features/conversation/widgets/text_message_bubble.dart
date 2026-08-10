import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/message.dart';

/// A simple text-only AI response bubble — glass card with transcript text.
///
/// Used when text-only mode is enabled: no audio controls, no waveform.
class TextMessageBubble extends StatelessWidget {
  final Message message;

  const TextMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: AppRadius.bubbleAi,
          glowColor: AppColors.accentCyanGlow.withValues(alpha: 0.2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              message.transcript,
              style: AppTextStyles.labelMedium(color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
