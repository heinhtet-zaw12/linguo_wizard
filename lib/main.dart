import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const LinguoWizardApp());
}

class LinguoWizardApp extends StatelessWidget {
  const LinguoWizardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linguo Wizard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashScreen(
        onSplashDone: () {
          // TODO: navigate to onboarding / home
        },
      ),
    );
  }
}
