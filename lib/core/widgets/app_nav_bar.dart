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
    required this.activeIcon,
    required this.label,
  });

  /// Outlined/inactive icon shown when unselected.
  final IconData icon;

  /// Filled/solid icon shown when selected.
  final IconData activeIcon;

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
          crossAxisAlignment: CrossAxisAlignment.center,
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

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final GradientNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_NavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  static const double _iconSize = 20;
  static const double _selectedPillHeight = 28;
  static const double _spacing = 2;

  // Brighter unselected color for better readability on dark backgrounds.
  static const Color _unselectedColor = Color(0xFF8892A8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isSelected)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) => Transform.scale(
                scale: _bounceAnimation.value,
                child: child,
              ),
              child: Container(
                width: 44,
                height: _selectedPillHeight,
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: AppRadius.pill,
                  boxShadow: AppShadows.glowBlue,
                ),
                child: Icon(
                  widget.item.activeIcon,
                  size: _iconSize,
                  color: AppColors.textOnAccent,
                ),
              ),
            )
          else
            SizedBox(
              height: _selectedPillHeight,
              child: Icon(
                widget.item.icon,
                size: _iconSize,
                color: _unselectedColor,
              ),
            ),
          const SizedBox(height: _spacing),
          Text(
            widget.item.label,
            style: AppTextStyles.labelSmall(
              color: widget.isSelected
                  ? AppColors.textPrimary
                  : _unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
