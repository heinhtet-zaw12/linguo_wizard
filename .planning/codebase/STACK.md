# Technology Stack

**Analysis Date:** 2026-07-14

## Languages

**Primary:**
- Dart 3.10.8 - Flutter application logic, business logic, UI components
- Kotlin - Android native layer and platform-specific code
- Swift - iOS native layer and platform-specific code

**Secondary:**
- JavaScript/Web - Web platform support

## Runtime

**Environment:**
- Flutter 3.38.9 (stable channel)
- Dart SDK 3.10.8
- Flutter Engine revision 587c18f873 (2026-01-27)

**Package Manager:**
- Pub (Dart/Flutter native)
- Lockfile: `pubspec.lock` (present and resolved)

## Frameworks

**Core:**
- Flutter 3.38.9 - Cross-platform mobile/web/desktop UI framework
- Flutter Material Design - UI component library

**Testing:**
- flutter_test - Flutter's testing framework (integrated)
- flutter_lints 6.0.0 - Linting and static analysis

**Build/Dev:**
- Flutter build system - Native compilation for iOS, Android, Web
- Android Gradle - Android build pipeline (implicit)

## Key Dependencies

**Critical:**
- flutter (SDK) - Core framework for all UI and runtime
- cupertino_icons 1.0.8 - iOS-style icon pack
- flutter_test (SDK) - Testing framework

**Infrastructure:**
- Android SDK - Android platform support
- iOS SDK - iOS platform support

## Configuration

**Environment:**
- Environment variables: Not currently configured
- No `.env` files detected - Secrets management TBD
- Platform-specific config files:
  - `android/app/src/main/AndroidManifest.xml` - Android app manifest
  - `ios/Runner/Info.plist` (implicit) - iOS app configuration
  - `web/manifest.json` - Web app manifest

**Build:**
- `pubspec.yaml` - Dart/Flutter package manifest and dependencies
- `analysis_options.yaml` - Dart analyzer configuration (includes `flutter_lints`)
- `pubspec.lock` - Resolved dependency versions

**Platform-Specific:**
- Android: Gradle-based build, AndroidX embedding
- iOS: Xcode project-based build
- Web: index.html entry point

## Platform Requirements

**Development:**
- Flutter SDK 3.38.9+
- Dart 3.10.8+
- Android Studio or Xcode (for native platform support)
- Chrome (for web development)

**Production:**
- iOS 12.0+ (minimum)
- Android API 21+ (Android 5.0+ minimum)
- Modern browsers (Chrome, Firefox, Safari, Edge)

## Build Phases (Planned)

Based on project brief in `CLAUDE.md`:

**Phase 1 - Core MVP:**
- Splash screen and onboarding flow
- Scenario selection with CEFR level filtering
- Voice-based conversation screen (mic → voice message → AI response)
- Feedback and scoring with local-only storage

**Phase 2 - Accounts & Cloud:**
- Firebase Auth integration (email, Google, guest)
- Cloud sync via Firestore
- Home Dashboard with user state

**Phase 3 - Gamification:**
- Streaks, XP, badges
- Spaced repetition system
- Pattern analysis

**Phase 4 - Premium:**
- Subscription gating
- Advanced integrations (Azure Speech, ElevenLabs TTS)

---

*Stack analysis: 2026-07-14*
