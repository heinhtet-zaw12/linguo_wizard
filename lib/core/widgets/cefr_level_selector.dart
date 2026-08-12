import 'package:flutter/material.dart';

import '../config/cefr_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// Horizontal scrollable CEFR level selector with compact chip labels.
///
/// Uses [CefrProfile] to display both the level code (A1, B2, etc.)
/// and the human-readable label (Beginner, Advanced, etc.) beneath it.
/// Falls back to just the code if the level isn't in the profile registry.
class CefrLevelSelector extends StatelessWidget {
  const CefrLevelSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.levels = const ['A1', 'A2', 'B1', 'B2', 'C1'],
  });

  /// Currently selected CEFR level code (e.g. 'B1').
  final String selected;

  /// Callback when a level is tapped.
  final ValueChanged<String> onSelected;

  /// Ordered list of level codes to show.
  /// Defaults to all supported levels from [CefrProfile].
  final List<String> levels;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If all chips fit, use a centered Wrap (no scroll bar).
        // Otherwise, use a scrollable ListView for horizontal scrolling.
        final allChipsWidth = _estimateTotalWidth(constraints.maxWidth);

        if (allChipsWidth <= constraints.maxWidth) {
          return Center(
            child: Wrap(
              spacing: AppSpacing.s2,
              runSpacing: AppSpacing.s2,
              alignment: WrapAlignment.center,
              children: levels
                  .map((level) => _buildChip(
                        level,
                        level == selected,
                        onSelected,
                      ))
                  .toList(),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: levels
                .map((level) => Padding(
                      padding: const EdgeInsets.only(
                        right: AppSpacing.s2,
                      ),
                      child: _buildChip(
                        level,
                        level == selected,
                        onSelected,
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  double _estimateTotalWidth(double maxWidth) {
    // Rough estimate: each chip ~ 70px wide, including padding.
    // 5 chips * 70 = 350px. With spacing of 8px * 4 gaps = 32px. Total ~382px.
    return levels.length * 72 + (levels.length - 1) * AppSpacing.s2;
  }

  Widget _buildChip(
    String level,
    bool isSelected,
    ValueChanged<String> onSelected,
  ) {
    final label = CefrProfile.forLevel(level).label;

    return GestureDetector(
      onTap: () => onSelected(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.accent : null,
          color: isSelected
              ? null
              : AppColors.surfaceGlass,
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: isSelected ? AppColors.accentStart : AppColors.borderGlow,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.glowBlue : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              level,
              style: AppTextStyles.headingMedium(
                color: isSelected
                    ? AppColors.textOnAccent
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            if (label.isNotEmpty)
              Text(
                label,
                style: AppTextStyles.labelSmall(
                  color: isSelected
                      ? AppColors.textOnAccent.withValues(alpha: 0.8)
                      : AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
