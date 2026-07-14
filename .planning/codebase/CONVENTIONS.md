# Coding Conventions

**Analysis Date:** 2026-07-14

## Project Overview

Early-stage Flutter mobile app (Phase 1 MVP) for conversational English learning. Project initialized with default Flutter template. State management (riverpod), Firebase integration, and AI conversation engine (Gemini/Groq) not yet implemented.

## Naming Patterns

**Files:**
- Use lowercase_with_underscores for Dart file names
- Files organized by feature-first structure (as defined in CLAUDE.md architecture)
- Example: `lib/features/auth/login_screen.dart`

**Functions:**
- Use camelCase for function and method names
- Use descriptive verb-first naming: `incrementCounter()`, `handleLogin()`, `fetchScenarios()`

**Variables:**
- Private fields prefixed with underscore: `_counter`, `_isAuthenticated`
- Public fields use camelCase without prefix
- Constants use camelCase (not UPPER_SNAKE_CASE)

**Types/Classes:**
- Use PascalCase for class names
- Widget classes: `MyApp`, `ScenarioCard`, `ChatBubble`
- State classes: `_MyHomePageState`, `_ConversationScreenState`
- Use descriptive names indicating purpose: `ScenarioModel`, `AIService`, `AuthService`

## Code Style

**Formatting:**
- Tool: dart format (standard Flutter formatter)
- Run before committing: `dart format .`
- Default settings from Flutter SDK

**Linting:**
- Tool: flutter_lints v6.0.0
- Config: `analysis_options.yaml` at project root
- Current settings: Default recommended lints from `package:flutter_lints/flutter.yaml`
- No custom rules currently configured

**Analysis:**
```bash
flutter analyze        # Run static analysis
dart analyze           # Alternative command
```

## Import Organization

**Order:**
1. Dart core libraries
2. Flutter framework imports
3. Package imports (pub.dev packages)
4. Relative imports (project files)

**Style:**
- Use explicit `import` statements (not deferred or `show` unless necessary)
- One import per line
- Separate groups with blank line

**Path Aliases:**
- Use relative imports within lib: `import '../features/auth/auth_service.dart'`
- Package imports for cross-package: `import 'package:linguo_wizard/models/scenario.dart'`

**Example:**
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scenario.dart';
import '../services/ai_service.dart';
```

## Widget Structure

**StatelessWidget:**
- Keep in one file if small (<100 lines)
- Single Responsibility: one widget, one purpose
- Constructor at top with `const` when possible
- `@override` annotation on build method

**StatefulWidget:**
- State class in same file as Widget class (Flutter convention)
- Private state class with underscore prefix
- Initialize state in `initState()`, not in constructor
- Use `dispose()` to clean up controllers, streams, listeners

**Example:**
```dart
class ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final VoidCallback? onTap;

  const ScenarioCard({
    super.key,
    required this.scenario,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Widget tree
    );
  }
}
```

## Error Handling

**Patterns:**
- Use try-catch for async operations that can fail
- Throw custom exceptions for business logic errors
- Return null or empty collections rather than throwing for optional data
- Log errors with context for debugging

**Example:**
```dart
Future<Scenario?> loadScenario(String id) async {
  try {
    final data = await _firestore.getScenario(id);
    return Scenario.fromJson(data);
  } catch (e, stack) {
    _logger.error('Failed to load scenario', e, stack);
    return null;
  }
}
```

## State Management

**Framework:** riverpod (planned, not yet implemented)

**Guidelines (when implemented):**
- Use StateNotifier or AsyncNotifier for complex state
- Use StateProvider for simple primitive state
- Keep UI state in widget-level providers
- Keep business logic in service-level providers
- Never put UI code in providers

## Logging

**Framework:** TBD (recommend: `logging` or `logger` package)

**Patterns:**
- Log at entry/exit of major operations
- Log errors with stack traces
- Log user actions for analytics
- Use structured logging with categories

## Comments

**When to Comment:**
- Complex algorithms or business logic
- Workarounds or non-obvious decisions
- API integration documentation
- TODO comments for future implementation

**JSDoc/TSDoc:**
- Use `///` for public API documentation
- Document purpose, parameters, and return values
- Avoid obvious comments (don't document what code does, document why)

**Example:**
```dart
/// Calculates the user's CEFR level based on conversation performance.
///
/// Returns a score from 0-100 where:
/// 0-20: A1, 21-40: A2, 41-60: B1, 61-80: B2, 81-100: C1+
///
/// [responses] - List of user responses in the conversation
/// [accuracy] - Average pronunciation accuracy percentage
double calculateCefrLevel(List<Response> responses, double accuracy) {
  // Implementation
}
```

## Function Design

**Size:**
- Functions should be <50 lines
- Extract helpers for complex logic
- Single Responsibility: one function, one job

**Parameters:**
- Max 3-4 parameters; use data class or named parameters for more
- Use `required` keyword for mandatory params
- Use optional params with sensible defaults

**Return Values:**
- Return meaningful types (not void unless truly no result)
- Use Future/async for async operations
- Return null for optional data (or use sealed classes in Dart 3)

## Module Design

**Exports:**
- One public class/interface per file
- Use barrel files (index.dart) for feature modules with multiple exports
- Keep implementation details private (underscore prefix)

**Barrel Files:**
- Create when feature has >3 related files
- Example: `lib/features/scenarios/index.dart` exports all scenario-related classes

## Feature-First Organization (CLAUDE.md Architecture)

**Structure:**
```
lib/
├── main.dart              # Entry point
├── app.dart               # MaterialApp setup
├── core/                  # Shared utilities, constants
│   ├── constants/
│   ├── utils/
│   └── theme/
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── scenarios/         # Scenario selection & management
│   ├── conversation/      # Chat/voice interaction
│   └── progress/          # XP, streaks, feedback
├── models/                # Data models
├── services/              # Business logic, API calls
│   ├── ai/
│   ├── auth/
│   └── storage/
└── widgets/               # Shared/reusable widgets
```

## Code Quality Standards

- Run `flutter analyze` before committing
- Fix all lint warnings and errors
- No `print()` statements (use logging instead)
- No hardcoded strings (use constants or localization)
- No magic numbers (use named constants)
- Prefer composition over inheritance
- Prefer immutable data classes

---

*Convention analysis: 2026-07-14*
