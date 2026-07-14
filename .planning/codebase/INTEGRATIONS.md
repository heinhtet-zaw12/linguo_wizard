# External Integrations

**Analysis Date:** 2026-07-14

## APIs & External Services

**AI Conversation Engine:**
- Primary: Gemini API (Google, free tier)
- Alternative: Groq API
- Purpose: Generate conversational AI responses for language learning scenarios
- Implementation: HTTP REST API calls from Dart/Flutter
- Rate limiting: Device/IP-based for guests, user-based for free tier

**Speech-to-Text (STT):**
- Package: `speech_to_text` (Flutter native)
- Purpose: Convert user voice input to text for AI processing
- Implementation: Device-native STT (free, no cloud dependency)
- Platform support: iOS (Speech framework), Android (SpeechRecognizer)

**Text-to-Speech (TTS):**
- Package: `flutter_tts` (Flutter native)
- Purpose: Convert AI text responses to voice output
- Implementation: Device-native TTS (free, no cloud dependency)
- Upgrade path (later phases): ElevenLabs API, Google Cloud WaveNet

**Pronunciation Scoring (Phase 4, Premium):**
- Provider: Azure Speech Services OR Speechace API
- Purpose: Phoneme-level pronunciation assessment
- Implementation: REST API integration
- Access: Paid service, premium tier only

## Data Storage

**Databases:**
- Local Storage (Phase 1): SharedPreferences or Hive for guest mode progress
- Cloud Storage (Phase 2): Firebase Firestore
  - Schema: Single user document structure (supports guest → account migration)
  - Purpose: User progress, conversation history, settings sync

**File Storage:**
- Local filesystem only (audio files, cached data)
- Potential future: Firebase Storage for user-uploaded content

**Caching:**
- None currently configured
- Recommendation: Cache API responses and conversation history locally

## Authentication & Identity

**Auth Provider (Phase 2):**
- Firebase Authentication
- Supported methods:
  - Email/password
  - Google Sign-In
  - Continue as Guest (device ID-based)
- Implementation: Firebase Auth SDK
- Guest mode: Local device ID stored in SharedPreferences, migrates to Firebase UID on signup

**Identity Management:**
- Guest mode (Phase 1): Device ID/IP-based identification
- Authenticated mode (Phase 2): Firebase Auth UID

## Monitoring & Observability

**Error Tracking:**
- Not currently configured
- Recommendation: Firebase Crashlytics (Phase 2+)

**Logs:**
- Debug: Flutter debug logging
- Production: Recommendation - Firebase Performance Monitoring

**Analytics:**
- Not currently configured
- Recommendation: Firebase Analytics (Phase 2+)

## CI/CD & Deployment

**Hosting:**
- Mobile: Apple App Store, Google Play Store
- Web: Static hosting (Firebase Hosting or Vercel)
- No CI/CD pipeline currently configured

**CI Pipeline:**
- Not configured
- Recommendation: GitHub Actions for automated testing and deployment

**Build Targets:**
- Android: APK/AAB via Flutter build
- iOS: IPA via Flutter build + Xcode
- Web: Static HTML/JS/CSS via Flutter web build

## Environment Configuration

**Required env vars (Planned):**
- `GEMINI_API_KEY` - Google Gemini API access
- `GROQ_API_KEY` - Groq API access (alternative)
- `FIREBASE_CONFIG` - Firebase project configuration
- `AZURE_SPEECH_KEY` - Azure Speech Services (Phase 4)
- `AZURE_SPEECH_REGION` - Azure region (Phase 4)

**Secrets location:**
- Not currently configured
- Recommendation: Use `--dart-define` for build-time secrets or secure storage for runtime

## Webhooks & Callbacks

**Incoming:**
- None currently configured

**Outgoing:**
- AI API callbacks (Gemini, Groq)
- Firebase event callbacks (authentication state changes)
- Speech/TTS callbacks (audio processing events)

## Device Capabilities

**Microphone Access:**
- Required for STT
- Permission: `android.permission.RECORD_AUDIO`, iOS microphone permission
- Implementation: `speech_to_text` handles permission flow

**Network Access:**
- Required for AI API calls
- Implementation: HTTP client (dio or http package, TBD)

**Storage Access:**
- Local persistence for offline progress
- Implementation: SharedPreferences/Hive (Phase 1)

## Platform-Specific Integrations

**Android:**
- AndroidManifest.xml: Standard Flutter activity configuration
- Min SDK: API 21+ (Android 5.0+)

**iOS:**
- Info.plist: iOS permissions and configuration
- Minimum: iOS 12.0+

**Web:**
- index.html: Web entry point
- Limited native API access (STT/TTS may not work in web)

---

*Integration audit: 2026-07-14*
