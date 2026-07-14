# Codebase Structure

**Analysis Date:** 2026-07-14

## Current Directory Layout

```
linguo_wizard/
├── .git/                    # Git repository
├── .planning/               # Project planning documents (GSD)
│   └── codebase/            # Architecture, conventions docs
├── android/                 # Android platform code (Kotlin/Java)
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/com/example/linguo_wizard/
│       └── res/             # Android resources (icons, themes)
├── ios/                     # iOS platform code (Swift)
│   └── Runner/
│       ├── Assets.xcassets/ # iOS app icons, launch images
│       └── Base.lproj/      # iOS storyboards
├── lib/                     # Dart/Flutter application code
│   └── main.dart            # App entry point (only file — template)
├── test/                    # Test files
│   └── widget_test.dart     # Default counter widget test
├── web/                     # Web platform support
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── .gitignore
├── analysis_options.yaml    # Dart linting configuration
├── CLAUDE.md                # Project brief (architectural requirements)
├── pubspec.yaml             # Flutter package manifest
├── pubspec.lock             # Dependency lockfile
└── README.md                # Basic project README
```

## Planned Feature-First Directory Structure

Per CLAUDE.md project brief, the app uses MVVM with Feature-First organization. Below is the intended structure once features are implemented:

```
lib/
├── main.dart                          # App entry point, provider scope, MaterialApp
├── app.dart                           # (Optional) App widget if separated from main
│
├── core/                              # Shared infrastructure across all features
│   ├── config/                        # App constants, AI prompt templates
│   │   ├── app_constants.dart
│   │   ├── ai_prompts.dart            # System prompts for Gemini/Groq
│   │   └── scenario_config.dart       # Scenario metadata, CEFR mappings
│   ├── services/                      # External API and device service wrappers
│   │   ├── firebase_service.dart      # Firebase Auth + Firestore client
│   │   ├── ai_service.dart            # Gemini/Groq API client
│   │   ├── speech_service.dart        # speech_to_text wrapper
│   │   ├── tts_service.dart           # flutter_tts wrapper
│   │   └── rate_limiter.dart          # AI call quota enforcement
│   ├── repositories/                  # Data access abstraction
│   │   ├── user_repository.dart       # User profile, progress persistence
│   │   ├── scenario_repository.dart   # Scenario data loading
│   │   └── local_storage.dart         # SharedPreferences/Hive wrapper
│   ├── theme/                         # 3D Claymorphism theme
│   │   ├── app_theme.dart             # ThemeData, colorScheme, textTheme
│   │   ├── app_colors.dart            # Color palette constants
│   │   └── app_typography.dart        # Font definitions, text styles
│   ├── models/                        # Shared data models
│   │   ├── user_profile.dart
│   │   ├── cefr_level.dart            # CEFR enum (A1-C1)
│   │   └── progress_data.dart
│   └── utils/                         # Pure utility functions
│       ├── validators.dart
│       └── formatters.dart
│
├── features/                          # Feature-first grouped modules
│   ├── splash/
│   │   ├── views/
│   │   │   └── splash_screen.dart
│   │   └── viewmodels/
│   │       └── splash_viewmodel.dart
│   │
│   ├── onboarding/
│   │   ├── views/
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │       ├── language_picker.dart
│   │   │       ├── cefr_selector.dart
│   │   │       └── goal_picker.dart
│   │   ├── viewmodels/
│   │   │   └── onboarding_viewmodel.dart
│   │   └── models/
│   │       └── onboarding_preferences.dart
│   │
│   ├── scenarios/
│   │   ├── views/
│   │   │   ├── scenario_selection_screen.dart
│   │   │   └── widgets/
│   │   │       ├── scenario_card.dart
│   │   │       └── cefr_filter_chips.dart
│   │   ├── viewmodels/
│   │   │   └── scenario_selection_viewmodel.dart
│   │   └── models/
│   │       └── scenario.dart
│   │
│   ├── conversation/
│   │   ├── views/
│   │   │   ├── conversation_screen.dart
│   │   │   └── widgets/
│   │   │       ├── voice_message_bubble.dart
│   │   │       ├── mic_button.dart
│   │   │       └── goal_progress_indicator.dart
│   │   ├── viewmodels/
│   │   │   └── conversation_viewmodel.dart
│   │   └── models/
│   │       ├── voice_message.dart
│   │       └── conversation_state.dart
│   │
│   ├── feedback/
│   │   ├── views/
│   │   │   └── feedback_screen.dart
│   │   ├── viewmodels/
│   │   │   └── feedback_viewmodel.dart
│   │   └── models/
│   │       └── score_data.dart
│   │
│   ├── home/                          # Dashboard (Phase 2)
│   │   ├── views/
│   │   │   ├── home_dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── streak_display.dart
│   │   │       ├── daily_goal_ring.dart
│   │   │       └── recommended_scenarios.dart
│   │   ├── viewmodels/
│   │   │   └── home_viewmodel.dart
│   │   └── models/
│   │       └── dashboard_data.dart
│   │
│   └── auth/                          # Authentication (Phase 2)
│       ├── views/
│       │   ├── login_screen.dart
│       │   └── signup_screen.dart
│       ├── viewmodels/
│       │   └── auth_viewmodel.dart
│       └── models/
│           └── auth_state.dart
│
└── shared/                            # Shared widgets, not tied to one feature
    └── widgets/
        ├── clay_button.dart           # Reusable Claymorphism-styled button
        ├── clay_card.dart
        └── loading_indicator.dart
```

## Directory Purposes

**`lib/`:**
- Purpose: All Dart application source code
- Contains: Single `main.dart` (template only, no feature code yet)
- Key files: `lib/main.dart`

**`lib/core/`:**
- Purpose: Shared infrastructure, services, configuration — not feature-specific
- Contains: Services, repositories, theme, shared models, utilities
- Key files: (planned) `core/services/ai_service.dart`, `core/theme/app_theme.dart`

**`lib/features/`:**
- Purpose: Feature-first grouped modules; each feature is self-contained
- Contains: views, viewmodels, models scoped to one feature
- Key files: (planned) Each feature has its own `views/`, `viewmodels/`, `models/` subdirectories

**`lib/shared/`:**
- Purpose: Reusable widgets and components used across multiple features
- Contains: Generic UI components (buttons, cards, indicators)
- Key files: (planned) `shared/widgets/clay_button.dart`

**`test/`:**
- Purpose: Unit and widget tests
- Contains: `widget_test.dart` (default counter test only)
- Key files: `test/widget_test.dart`

**`android/`, `ios/`, `web/`:**
- Purpose: Platform-specific configuration and native code
- Contains: Platform manifests, build configs, native splash/icons
- Key files: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`

**`.planning/codebase/`:**
- Purpose: GSD planning documents for codebase analysis
- Contains: Architecture, structure, conventions, testing docs
- Key files: `ARCHITECTURE.md`, `STRUCTURE.md`

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App entry point — runs MyApp, initializes Flutter engine

**Configuration:**
- `pubspec.yaml`: Flutter dependencies and project metadata
- `analysis_options.yaml`: Dart analyzer and lint configuration
- `.gitignore`: Git exclusion rules
- `CLAUDE.md`: Project brief and architectural requirements

**Core Logic:**
- (Not yet implemented) All feature code goes under `lib/features/{feature_name}/`

**Testing:**
- `test/widget_test.dart`: Only existing test file (counter template)

## Naming Conventions

**Files:**
- snake_case for all Dart files: `scenario_card.dart`, `conversation_viewmodel.dart`
- Feature folders use singular nouns: `conversation/`, `scenario/`, `feedback/`
- View files end with `_screen.dart` for full-page screens
- Widget files describe the component: `voice_message_bubble.dart`, `cef_filter_chips.dart`

**Directories:**
- Feature directories: `lib/features/{feature_name}/`
- Standard subdirectories within each feature: `views/`, `viewmodels/`, `models/`
- Shared infrastructure: `lib/core/`, `lib/shared/`

**Classes:**
- PascalCase: `ConversationScreen`, `ScenarioViewModel`, `VoiceMessage`
- ViewModels suffixed with `ViewModel`: `ConversationViewModel`
- Screens suffixed with `Screen`: `ConversationScreen`
- Services suffixed with `Service`: `AiService`, `SpeechService`

**Variables/Functions:**
- camelCase: `currentScenario`, `incrementCounter()`, `fetchScenarios()`
- Private members prefixed with underscore: `_counter`, `_buildMessageBubble()`

## Where to Add New Code

**New Feature:**
1. Create directory: `lib/features/{feature_name}/`
2. Add subdirectories: `views/`, `viewmodels/`, `models/`
3. Create ViewModel as Riverpod provider first, then build View
4. Add tests in `test/features/{feature_name}/`

**New Screen:**
- Implementation: `lib/features/{feature}/views/{screen_name}_screen.dart`
- If screen has reusable sub-widgets: `lib/features/{feature}/views/widgets/{widget_name}.dart`

**New ViewModel:**
- Implementation: `lib/features/{feature}/viewmodels/{feature}_viewmodel.dart`
- Define state class: `lib/features/{feature}/models/{feature}_state.dart`

**New Model/Data Class:**
- Feature-specific: `lib/features/{feature}/models/{model_name}.dart`
- Shared across features: `lib/core/models/{model_name}.dart`

**New Service (External API):**
- Implementation: `lib/core/services/{service_name}_service.dart`
- Interface/abstract class first, then concrete implementation

**New Shared Widget:**
- Implementation: `lib/shared/widgets/{widget_name}.dart`
- Must be generic enough to be reused across 2+ features

**New Utility Function:**
- Feature-specific (rare): `lib/features/{feature}/utils/`
- Shared: `lib/core/utils/{utility_name}.dart`

**New Test:**
- Unit tests: `test/unit/` or `test/{feature}/`
- Widget tests: `test/widget/` or `test/{feature}/`
- Test file mirrors source: `conversation_viewmodel_test.dart` tests `conversation_viewmodel.dart`

**New Configuration/Constant:**
- App-wide: `lib/core/config/app_constants.dart`
- AI prompts: `lib/core/config/ai_prompts.dart`
- Scenario metadata: `lib/core/config/scenario_config.dart`

## Special Directories

**`.dart_tool/`:**
- Purpose: Dart/Flutter build cache and package config
- Generated: Yes (by `pub get`)
- Committed: No (in `.gitignore`)

**`build/`:**
- Purpose: Compiled output (APK, IPA, web bundle)
- Generated: Yes (by `flutter build`)
- Committed: No (in `.gitignore`)

**`.planning/codebase/`:**
- Purpose: GSD codebase analysis documents
- Generated: No (manually written by GSD tools)
- Committed: Yes (part of repo)

**`android/app/build/`, `ios/Flutter/ephemeral/`:**
- Purpose: Platform build artifacts
- Generated: Yes (by platform build tools)
- Committed: No (in `.gitignore`)

## Import Organization

**Standard import order (enforce via linting):**
1. Dart SDK imports (`dart:async`, `dart:io`)
2. Flutter framework imports (`package:flutter/*`)
3. Third-party package imports (`package:riverpod/*`, `package:firebase/*`)
4. Project imports (`package:linguo_wizard/*`)
5. Relative imports (`../`, `./` — use sparingly, prefer package imports)

**Path aliases:** None configured (Flutter/Dart uses package imports by default)

**Import style:** Always use `package:linguo_wizard/...` for project imports; avoid relative imports except within same feature subdirectory.

---

*Structure analysis: 2026-07-14*
