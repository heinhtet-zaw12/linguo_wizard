import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/auth_provider.dart';

/// Shell scaffold with bottom navigation bar.
///
/// Uses [ConsumerWidget] to watch auth state and conditionally show
/// tabs: guests see Home + Scenarios only; authenticated users see all 4.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Scenarios',
          ),
          if (!isGuest) ...[
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Progress',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ],
      ),
    );
  }
}
