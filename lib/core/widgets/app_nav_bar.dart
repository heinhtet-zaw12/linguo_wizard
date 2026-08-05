import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// A single navigation destination for [AppNavBar].
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
}

/// Reusable bottom navigation bar with frosted glass styling.
///
/// Decouples navigation chrome from the GoRouter shell so it can be
/// tested and themed independently.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: SizedBox(
          height: AppSizing.navBarHeight,
          child: Row(
            children: [
              for (final dest in destinations)
                Expanded(
                  child: _NavButton(
                    destination: dest,
                    isSelected: dest.index == selectedIndex,
                    onTap: () => onDestinationSelected(dest.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
     .fadeIn(duration: 300.ms);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentPrimary;
    final inactiveColor = AppColors.textTertiary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentPrimary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: AppRadius.full,
            ),
            child: Icon(
              isSelected ? destination.selectedIcon : destination.icon,
              size: AppSizing.iconLg,
              color: isSelected ? accentColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: AppTextStyles.labelSmall(
              color: isSelected ? accentColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
