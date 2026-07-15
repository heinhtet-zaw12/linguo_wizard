import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/conversation/screens/conversation_screen.dart';
import 'features/scenario_selection/screens/scenario_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ProviderScope(child: LinguoWizardApp()));
}

class LinguoWizardApp extends StatelessWidget {
  const LinguoWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linguo Wizard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(
              onSplashDone: () {
                Navigator.pushReplacementNamed(context, '/scenarios');
              },
            ),
        '/scenarios': (context) => const ScenarioSelectionScreen(),
        '/conversation': (context) => const ConversationScreen(),
      },
    );
  }
}
