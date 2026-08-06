import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';

/// A single navigation destination for [GradientNavBar].
class GradientNavItem {
  const GradientNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

/// Reusable bottom navigation bar with glass styling and gradient indicator.
class GradientNavBar extends StatelessWidget {
  const GradientNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GradientNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizing.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _NavButton(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
     .fadeIn(duration: 300.ms);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GradientNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _iconSize = 20;
  static const double _selectedPillHeight = 28;
  static const double _spacing = 2;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            Container(
              width: 44,
              height: _selectedPillHeight,
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: AppRadius.pill,
                boxShadow: AppShadows.glowBlue,
              ),
              child: Icon(
                item.icon,
                size: _iconSize,
                color: AppColors.textOnAccent,
              ),
            )
          else
            SizedBox(
              height: _selectedPillHeight,
              child: Icon(
                item.icon,
                size: _iconSize,
                color: AppColors.textTertiary,
              ),
            ),
          const SizedBox(height: _spacing),
          Text(
            item.label,
            style: AppTextStyles.labelSmall(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
