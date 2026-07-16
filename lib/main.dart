import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/conversation/screens/conversation_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/scenario_selection/screens/scenario_selection_screen.dart';
import 'features/onboarding/viewmodels/onboarding_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadEnv();
  final onboardingDone = await OnboardingViewModel.hasCompletedOnboarding();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(ProviderScope(child: LinguoWizardApp(onboardingDone: onboardingDone)));
}

class LinguoWizardApp extends StatelessWidget {
  const LinguoWizardApp({super.key, required this.onboardingDone});

  final bool onboardingDone;

  @override
  Widget build(BuildContext context) {
    final initialRoute = onboardingDone ? '/scenarios' : '/onboarding';

    return MaterialApp(
      title: 'Linguo Wizard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(
              onSplashDone: () {
                Navigator.pushReplacementNamed(context, initialRoute);
              },
            ),
        '/onboarding': (context) => const OnboardingScreen(),
        '/scenarios': (context) => const ScenarioSelectionScreen(),
        '/conversation': (context) => const ConversationScreen(),
      },
    );
  }
}
