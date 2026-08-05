import 'package:flutter/material.dart';
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
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      index: 0,
    ),
    AppNavDestination(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: 'Scenarios',
      index: 1,
    ),
    AppNavDestination(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Progress',
      index: 2,
    ),
    AppNavDestination(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
      index: 3,
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
      bottomNavigationBar: AppNavBar(
        destinations: destinations,
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
