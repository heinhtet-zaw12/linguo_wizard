# Codebase Concerns

**Analysis Date:** 2026-07-14

## Tech Debt

**Not applicable at this stage.**
The codebase is in initial commit state (default Flutter counter demo only). No application-specific technical debt exists yet. All code from the initial template will be replaced.

**Potential Future Risk:**
- If boilerplate code is retained rather than deleted, it could create confusion about the project's purpose
- Files to eventually remove or replace: `lib/main.dart`, `test/widget_test.dart`

## Known Bugs

**Not detected.**
No application logic exists to contain bugs. The default Flutter demo functions as designed.

## Security Considerations

**API Key Management (Critical):**
- Risk: No secrets management strategy in place
- Files: `pubspec.yaml`, no `.env` files or env var handling
- Current mitigation: None
- Recommendations:
  - Implement `--dart-define` for build-time API keys (Gemini, Groq, Azure Speech)
  - Never commit secrets to version control
  - Consider using `flutter_dotenv` or platform-specific secure storage for runtime secrets
  - Document required env vars in developer setup guide

**Firebase Configuration:**
- Risk: Firebase config files could contain sensitive project information
- Files: Not yet created (Phase 2)
- Current mitigation: N/A
- Recommendations:
  - Add `firebase_options.dart` to `.gitignore` or use generated platform configs
  - Implement Firebase App Check for API protection
  - Configure Firestore security rules before deployment

**Rate Limiting & Abuse Prevention:**
- Risk: The CLAUDE.md specifies device/IP-based rate limiting but no implementation exists yet
- Files: `lib/main.dart` (no logic yet)
- Current mitigation: None
- Recommendations:
  - Never trust client-side rate limiting
  - Implement Cloud Functions for device ID verification and call counting
  - Use Firebase Functions + Firestore for server-side quota tracking
  - Implement exponential backoff in API clients

**Microphone & Network Permissions:**
- Risk: Improper permission handling could cause iOS/Android rejections
- Files: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
- Current mitigation: Default Flutter config
- Recommendations:
  - Request microphone permission only when needed (not at app launch)
  - Handle permission denial gracefully with user guidance
  - Add usage description strings for App Store compliance

## Performance Bottlenecks

**Audio Processing (Potential):**
- Problem: STT and TTS on-device can be CPU-intensive
- Files: Not yet implemented
- Cause: Device-native speech processing blocks main thread if not handled properly
- Improvement path:
  - Run speech processing on isolate/background thread
  - Cache recently used TTS audio
  - Implement audio stream buffering for smooth playback
  - Add timeout for STT/TTS operations

**AI API Latency:**
- Problem: Gemini/Groq API calls will add latency to conversation flow
- Files: Not yet implemented
- Cause: Network round-trip + model inference time
- Improvement path:
  - Implement optimistic UI updates (show "AI is thinking..." immediately)
  - Cache common responses and scenario templates
  - Pre-fetch scenario content when user browses selection screen
  - Add loading indicators for all API calls

**Local Storage Growth:**
- Problem: Conversation history and progress data could grow unbounded on device
- Files: Not yet implemented
- Cause: Guest mode stores data locally without limits
- Improvement path:
  - Set maximum local history size (e.g., last 100 conversations)
  - Implement data migration on account creation
  - Use Hive or Isar for efficient local database queries
  - Add periodic cleanup of old/unused data

## Fragile Areas

**Architecture Foundation:**
- Files: `lib/main.dart` (not yet structured)
- Why fragile: No architecture pattern implemented yet; CLAUDE.md specifies MVVM but no folders exist
- Safe modification: Delete default demo, implement feature-first folder structure immediately
- Test coverage: Not started

**State Management:**
- Files: Not yet implemented
- Why fragile: CLAUDE.md specifies Riverpod but no setup exists; decisions here cascade through entire app
- Safe modification: Set up Riverpod before implementing any features; follow official Riverpod patterns
- Test coverage: Write tests for all providers

**Local Data Model:**
- Files: Not yet implemented
- Why fragile: Guest → account migration strategy is critical; poor schema choice will require painful refactoring
- Safe modification: Define user progress schema now, even if only storing locally; validate migration path
- Test coverage: Test schema migration before launch

**Cross-Platform Audio:**
- Files: Not yet implemented
- Why fragile: STT/TTS behavior varies significantly across iOS, Android, and Web; audio permissions are strict
- Safe modification: Implement platform-specific audio handling with proper error handling per platform
- Test coverage: Manual testing on all target platforms required

## Scaling Limits

**Guest Mode Users:**
- Current capacity: Unlimited (local storage)
- Limit: Device storage constraints; no way to migrate data if user doesn't create account
- Scaling path: Implement data export/import feature; limit guest data to essential progress only

**API Quotas:**
- Current capacity: Gemini free tier (60 requests/minute, 1500 requests/day)
- Limit: Will exceed free tier if app gains traction
- Scaling path: Implement aggressive caching; upgrade to paid tier with usage monitoring; add quota dashboard

**Conversation Length:**
- Current capacity: Unlimited per session
- Limit: Long conversations could cause memory pressure and API token exhaustion
- Scaling path: Cap conversation at 20-30 exchanges; implement conversation summarization; archive old exchanges

## Dependencies at Risk

**Flutter Lints (6.0.0):**
- Risk: May introduce breaking lint rules on upgrade
- Impact: Could break CI/CD builds
- Migration plan: Pin version; test linting in CI before upgrading; review changelog for breaking changes

**Future Dependencies (Planned):**
- `speech_to_text` - Native STT package; may have platform-specific issues
- `flutter_tts` - Native TTS package; behavior varies by device manufacturer
- `flutter_riverpod` - State management; breaking changes between major versions
- `firebase_core`, `cloud_firestore`, `firebase_auth` - Firebase SDK; update patterns can be breaking

## Missing Critical Features

**Project Structure (Blocking):**
- Problem: No MVVM/feature-first folder structure exists yet
- Blocks: All feature development; will require massive refactoring if not established first
- Priority: High - implement before any feature work

**Environment Configuration (Blocking):**
- Problem: No secrets management or environment switching
- Blocks: API integrations (Gemini, Firebase, etc.)
- Priority: High - implement before Phase 1 API work

**Error Handling Framework:**
- Problem: No error handling strategy defined
- Blocks: Graceful error recovery, user-facing error messages
- Priority: High - implement early to avoid patchwork fixes later

**Offline Capability:**
- Problem: No offline-first architecture; app assumes network connectivity
- Blocks: Guest mode without internet; graceful degradation
- Priority: Medium - important for mobile users with poor connectivity

**Analytics & Monitoring:**
- Problem: No crash reporting, analytics, or performance monitoring
- Blocks: User behavior insights, debugging production issues
- Priority: Medium - implement in Phase 2 before public launch

## Test Coverage Gaps

**No Application Tests Exist:**
- What's not tested: All application logic (none exists yet)
- Files: `test/widget_test.dart` (default demo test only)
- Risk: Cannot verify feature correctness without tests
- Priority: Critical - implement TDD from the start

**Widget/Integration Tests:**
- What's not tested: UI interactions, navigation flows, voice message handling
- Files: Not yet implemented
- Risk: UI regressions and broken user flows undetected
- Priority: High - write tests alongside features

**API Client Tests:**
- What's not tested: Gemini/Groq API calls, STT/TTS integration
- Files: Not yet implemented
- Risk: API changes or network failures could break core features
- Priority: High - mock APIs and test error scenarios

**Data Migration Tests:**
- What's not tested: Guest → account migration, schema evolution
- Files: Not yet implemented
- Risk: Data loss on account creation; corrupted user progress
- Priority: Critical - test migration extensively before Phase 2

---

*Concerns audit: 2026-07-14*
