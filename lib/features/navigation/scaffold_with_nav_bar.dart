import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/widgets/app_nav_bar.dart';

/// Shell scaffold with bottom navigation bar.
///
/// Uses [ConsumerWidget] to watch auth state and conditionally show
/// tabs: guests see Home + Scenarios only; authenticated users see all 4.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _allDestinations = [
    GradientNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    GradientNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Scenarios',
    ),
    GradientNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Progress',
    ),
    GradientNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    // Clamp index when guest — guests only see 2 tabs (Home, Scenarios).
    final destinationCount = isGuest ? 2 : 4;
    final safeIndex = navigationShell.currentIndex.clamp(
      0,
      destinationCount - 1,
    );

    // If the shell index is out of range (e.g. user was on Profile tab,
    // then signed out), redirect to the first tab.
    if (navigationShell.currentIndex >= destinationCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationShell.goBranch(0);
      });
    }

    final destinations = _allDestinations.sublist(0, destinationCount);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GradientNavBar(
        items: destinations,
        currentIndex: safeIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
