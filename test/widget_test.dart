// Basic smoke test for LinguoWizardApp.
//
// Verifies the app can be instantiated and renders without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:linguo_wizard/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LinguoWizardApp(onboardingDone: false)),
    );

    // Advance past the full splash sequence (~3.5s of Future.delayed calls)
    await tester.pump(const Duration(seconds: 4));

    // App should render
    expect(find.byType(LinguoWizardApp), findsOneWidget);
  });
}
