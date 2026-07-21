import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/screens/forgot_password_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/signup_screen.dart';
import '../conversation/screens/conversation_screen.dart';
import '../feedback/screens/feedback_screen.dart';
import '../home/screens/home_screen.dart';
import '../leaderboard/screens/leaderboard_screen.dart';
import '../onboarding/screens/onboarding_screen.dart';
import '../progress/screens/progress_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../scenario_selection/screens/scenario_selection_screen.dart';
import '../srs/screens/pre_scenario_review_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// GoRouter configuration for the app.
///
/// Provides declarative routing with auth guards, onboarding guards,
/// and a StatefulShellRoute for bottom navigation with state preservation.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;
    final isOnAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot-password';
    final isOnOnboardingRoute = state.matchedLocation == '/onboarding';
    final isOnSplashRoute = state.matchedLocation == '/splash';

    // Splash is always accessible (no guard).
    if (isOnSplashRoute) return null;

    // Not authenticated — redirect to login (unless already on auth route).
    if (!isAuthenticated && !isOnAuthRoute) return '/login';

    // Authenticated but onboarding not completed — redirect to onboarding.
    if (isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool('onboarding_completed') ?? false;
      if (!onboarded && !isOnOnboardingRoute) return '/onboarding';
    }

    return null; // No redirect needed.
  },
  routes: [
    // ─── Auth routes (standalone, no bottom nav) ───
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ─── Bottom nav shell (preserves tab state) ───
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scenarios',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScenarioSelectionScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProgressScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),

    // ─── Full-screen routes (no bottom nav) ───
    GoRoute(
      path: '/conversation/:id',
      builder: (context, state) => const ConversationScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/pre-scenario-review',
      builder: (context, state) {
        final scenarioId = state.extra as String? ?? '';
        return PreScenarioReviewScreen(scenarioId: scenarioId);
      },
    ),
  ],
);
