# Testing Patterns

**Analysis Date:** 2026-07-14

## Test Framework

**Runner:**
- Flutter Test (built-in Flutter SDK)
- Config: No separate config file; uses pubspec.yaml and test/ directory structure
- Version: Matches Flutter SDK version

**Assertion Library:**
- flutter_test (built-in)
- Matchers for widget testing

**Run Commands:**
```bash
flutter test                          # Run all tests
flutter test --coverage               # Run with coverage report
flutter test test/widget_test.dart    # Run specific test file
flutter test --watch                  # Watch mode (not built-in; use fswatch or IDE)
```

## Test File Organization

**Location:**
- Separate `test/` directory at project root (standard Flutter convention)
- One test file per source file
- Mirror lib/ directory structure in test/

**Naming:**
- Test files: `*_test.dart`
- Example: `lib/features/auth/login_screen.dart` → `test/features/auth/login_screen_test.dart`

**Structure:**
```
test/
├── features/           # Feature-specific tests
│   ├── auth/
│   ├── scenarios/
│   ├── conversation/
│   └── progress/
├── widgets/            # Shared widget tests
├── services/           # Service/unit tests
└── widget_test.dart    # Root-level smoke test (current)
```

## Test Structure

**Suite Organization:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:linguo_wizard/features/[feature]/[file].dart';

void main() {
  group('FeatureGroup', () {
    setUp(() {
      // Setup before each test
    });

    tearDown(() {
      // Cleanup after each test
    });

    testWidgets('description of what it tests', (WidgetTester tester) async {
      // Arrange: Setup test data and mocks
      // Act: Perform the action
      // Assert: Verify results
    });
  });
}
```

**Patterns:**
- Use `group()` to organize related tests
- Use `setUp()` for repeated initialization
- Use `tearDown()` for cleanup
- Use descriptive test names that explain expected behavior

## Widget Testing

**Basic Pattern:**
```dart
testWidgets('ScenarioCard displays scenario title', (WidgetTester tester) async {
  // Arrange
  final scenario = Scenario(id: '1', title: 'At the Restaurant', level: 'A1');

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: ScenarioCard(scenario: scenario),
    ),
  );

  // Assert
  expect(find.text('At the Restaurant'), findsOneWidget);
  expect(find.text('A1'), findsOneWidget);
});
```

**User Interaction Testing:**
```dart
testWidgets('tapping increment button increases counter', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: MyHomePage()));

  // Verify initial state
  expect(find.text('0'), findsOneWidget);

  // Perform action
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  // Verify result
  expect(find.text('1'), findsOneWidget);
  expect(find.text('0'), findsNothing);
});
```

## Mocking

**Framework:** mockito or mocktail (recommended; not yet installed)

**Patterns (when implemented):**
```dart
// Define mock class
class MockAIService extends Mock implements AIService {}

// In test
late MockAIService mockAIService;

setUp(() {
  mockAIService = MockAIService();
  when(() => mockAIService.generateResponse(any()))
      .thenAnswer((_) async => 'Hello! How can I help you?');
});

// Use in test
testWidgets('conversation screen loads AI response', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        aiServiceProvider.overrideWithValue(mockAIService),
      ],
      child: MaterialApp(home: ConversationScreen()),
    ),
  );
  await tester.pump();
  // Assertions
});
```

**What to Mock:**
- External API calls (Gemini, Groq)
- Firebase services (Firestore, Auth)
- Device services (speech_to_text, flutter_tts)
- Local storage operations
- Network requests

**What NOT to Mock:**
- Flutter widgets (use real widgets)
- Dart core types (use real or fakes)
- Simple data classes (use real instances)
- Business logic in isolation (use real services with mocked dependencies)

## Fixtures and Factories

**Test Data:**
```dart
// Factory method pattern
class ScenarioFactory {
  static Scenario create({
    String? id,
    String? title,
    String? level,
  }) {
    return Scenario(
      id: id ?? 'test_id',
      title: title ?? 'Test Scenario',
      level: level ?? 'A1',
    );
  }
}

// Usage in tests
final scenario = ScenarioFactory.create(title: 'At the Airport');
```

**Location:**
- Create `test/fixtures/` directory for test data files
- JSON fixtures for API responses
- Factory classes for Dart objects

## Coverage

**Requirements:** None enforced currently (recommended: 80%+ for new code)

**View Coverage:**
```bash
flutter test --coverage                    # Generate coverage
genhtml coverage/lcov.info -o coverage     # Generate HTML report (requires lcov)
open coverage/index.html                   # View in browser
```

**Coverage Targets:**
- Critical paths (auth, conversation, scoring): 90%+
- UI widgets: 80%+
- Utilities/helpers: 95%+
- Overall project: 80%+

## Test Types

**Unit Tests:**
- Scope: Individual functions, methods, classes
- Location: `test/services/`, `test/models/`
- Focus: Business logic, calculations, data transformations
- Example: `calculateCefrLevel()` function

**Widget Tests:**
- Scope: Individual widgets in isolation
- Location: `test/features/[feature]/`, `test/widgets/`
- Focus: UI rendering, user interaction, widget state
- Example: `ScenarioCard` displays correctly

**Integration Tests:**
- Scope: Multiple components working together
- Location: `integration_test/` directory (not created yet)
- Focus: End-to-end user flows, feature integration
- Example: Full conversation flow from scenario selection to feedback

**E2E Tests:**
- Framework: integration_test (Flutter built-in) or patrol (for advanced native integration)
- Not yet implemented
- Should cover: User login → scenario selection → conversation → feedback

## Common Patterns

**Async Testing:**
```dart
testWidgets('loads scenarios asynchronously', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: ScenarioSelectionScreen()));
  await tester.pump(); // Trigger initial build

  // Show loading indicator
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Wait for async operation to complete
  await tester.pump(Duration(seconds: 1));

  // Verify loaded state
  expect(find.byType(ScenarioCard), findsWidgets);
});
```

**Error Testing:**
```dart
testWidgets('shows error message when API fails', (WidgetTester tester) async {
  when(() => mockAIService.generateResponse(any()))
      .thenThrow(Exception('API Error'));

  await tester.pumpWidget(MaterialApp(home: ConversationScreen()));
  await tester.pump(Duration(seconds: 1));

  expect(find.textContaining('Error'), findsOneWidget);
});
```

**State Management Testing (Riverpod):**
```dart
testWidgets('provider updates when state changes', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: Consumer(
        builder: (context, ref, child) {
          final count = ref.watch(counterProvider);
          return Text('$count');
        },
      )),
    ),
  );

  // Verify initial state
  expect(find.text('0'), findsOneWidget);

  // Trigger state change
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pump();

  // Verify updated state
  expect(find.text('1'), findsOneWidget);
});
```

## Testing Checklist

For each new feature:
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Mock external dependencies
- [ ] Test error states
- [ ] Test loading states
- [ ] Test empty states
- [ ] Test edge cases
- [ ] Achieve 80%+ coverage
- [ ] Run `flutter analyze` and fix all issues

## CI/CD Integration (Future)

**Commands:**
```yaml
# GitHub Actions or similar CI
- flutter test
- flutter test --coverage
- flutter analyze
- dart format --set-exit-if-changed .
```

**Coverage Enforcement:**
- Fail build if coverage < 75%
- Generate coverage report as artifact
- Post coverage to PR comments

---

*Testing analysis: 2026-07-14*
