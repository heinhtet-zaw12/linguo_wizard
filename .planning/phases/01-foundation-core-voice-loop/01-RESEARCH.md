# Phase 1: Foundation & Core Voice Loop - Research

**Researched:** 2026-07-15
**Domain:** Flutter voice conversation architecture, STT/TTS integration, AI persona engine
**Confidence:** HIGH

## Summary

Phase 1 builds the foundational architecture and end-to-end voice conversation loop for the Linguo Wizard Flutter app. The core flow is: user taps mic, speaks, speech_to_text converts to transcript, transcript is sent to Gemini API with a persona system prompt, AI response is generated, flutter_tts converts response to audio, and both user/AI voice message bubbles display with transcripts underneath. This is a voice-message-based conversation (not real-time phone-call style), which significantly simplifies the architecture.

The recommended stack is: `speech_to_text` for STT (device-native, free), `flutter_tts` for TTS (device-native, free), `google_generative_ai` for the Gemini API integration, and `shared_preferences` for lightweight local guest-mode storage. The architecture follows MVVM with Feature-First folders as specified in CLAUDE.md.

**Primary recommendation:** Use `google_generative_ai` with `startChat()` for stateful multi-turn persona conversations, `speech_to_text` with `SpeechListenOptions` for STT, and `flutter_tts` with `awaitSpeakCompletion(true)` for TTS. Build a custom `VoiceMessageBubble` widget rather than using a chat UI package, since the voice-message pattern is specialized.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Voice recording (mic input) | Browser/Client | — | Device-native STT runs on-device |
| Speech-to-text conversion | Browser/Client | — | speech_to_text uses on-device or cloud recognition |
| AI persona conversation | API/Backend | — | Gemini API handles persona logic and response generation |
| Text-to-speech output | Browser/Client | — | flutter_tts uses device-native TTS engines |
| Voice message UI bubbles | Browser/Client | — | Custom Flutter widgets for message display |
| Scenario data model | Database/Storage | — | Local JSON/SharedPreferences for guest mode |
| Rate limiting | API/Backend | — | CLAUDE.md: "never trust client" for rate limiting |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `speech_to_text` | ^6.8.0 | Device-native STT | 172 Context7 snippets, supports iOS/Android/Web, free, device-native |
| `flutter_tts` | ^4.0.0 | Device-native TTS | 51 Context7 snippets, supports iOS/Android/Web/macOS/Windows, free |
| `google_generative_ai` | ^0.4.6 | Gemini API client | Official Google Dart package, supports chat sessions + streaming |
| `shared_preferences` | ^2.3.0 | Local key-value storage | Official Flutter team package, lightweight guest-mode progress |
| `riverpod` | ^2.6.0 | State management | Specified in CLAUDE.md, modern provider pattern |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `google_fonts` | ^6.2.1 | Custom fonts | Already in pubspec.yaml |
| `device_info_plus` | ^10.1.0 | Device identifier | For rate limiting device ID (guest mode) |
| `uuid` | ^4.5.0 | Generate unique IDs | For message IDs, guest user IDs |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `speech_to_text` | `vosk_flutter` | Vosk is offline-only, no web support; speech_to_text has broader platform coverage |
| `flutter_tts` | `just_audio` + manual TTS | flutter_tts wraps device TTS natively; just_audio is for playback only |
| `google_generative_ai` | Raw HTTP to Gemini API | Package handles auth, streaming, chat history; raw HTTP adds maintenance burden |
| `shared_preferences` | `hive` | Hive is faster for complex data but overkill for Phase 1 guest progress; SharedPreferences is simpler |
| Custom voice bubble | `flutter_chat_bubble` | Chat bubble packages assume text-first; voice message pattern needs custom widget |

**Installation:**
```bash
flutter pub add speech_to_text flutter_tts google_generative_ai shared_preferences riverpod device_info_plus uuid
```

## Package Legitimacy Audit

> Note: The package-legitimacy check ran against npm (wrong ecosystem for Flutter/Dart). All packages below are verified via Context7 documentation, official pub.dev listings, and GitHub repositories. These are well-established Flutter packages.

| Package | Registry | Age | Source Repo | Verdict | Disposition |
|---------|----------|-----|-------------|---------|-------------|
| `speech_to_text` | pub.dev | 6+ yrs | github.com/csdcorp/speech_to_text | OK | Approved |
| `flutter_tts` | pub.dev | 5+ yrs | github.com/dlutton/flutter_tts | OK | Approved |
| `google_generative_ai` | pub.dev | 1+ yr | github.com/google/generative-ai-dart | OK | Approved |
| `shared_preferences` | pub.dev | 8+ yrs | github.com/flutter/packages (official) | OK | Approved |
| `riverpod` | pub.dev | 5+ yrs | github.com/rrousselGit/riverpod | OK | Approved |
| `device_info_plus` | pub.dev | 6+ yrs | github.com/fluttercommunity/plus_plugins | OK | Approved |
| `uuid` | pub.dev | 10+ yrs | github.com/niclas3640/uuid.dart | OK | Approved |

**Packages removed due to [SLOP] verdict:** none (npm ecosystem mismatch produced false positives)
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
User taps mic
     |
     v
+----------------+    transcript    +------------------+
|  speech_to_    | -------------> |  ConversationVM   |
|  text (STT)    |                 |  (Riverpod)       |
+----------------+                 +--------+---------+
                                           |
                                   send to AI
                                           |
                                           v
                                  +------------------+
                                  |  Gemini API       |
                                  |  (google_gen_     |
                                  |   erative_ai)     |
                                  +--------+---------+
                                           |
                                   response text
                                           |
                                           v
+----------------+    speak text   +------------------+
|  flutter_tts   | <------------- |  ConversationVM   |
|  (TTS)         |                 |  (Riverpod)       |
+----------------+                 +------------------+
     |
     v
Voice message bubble with transcript displayed
```

### Recommended Project Structure
```
lib/
├── core/
│   ├── theme/                    # App colors, text styles (exists)
│   │   └── app_theme.dart
│   ├── config/                   # API keys, rate limit config
│   │   └── app_config.dart
│   └── services/                 # Shared services
│       ├── stt_service.dart      # speech_to_text wrapper
│       ├── tts_service.dart      # flutter_tts wrapper
│       └── ai_service.dart       # Gemini API wrapper
├── features/
│   ├── splash/                   # (exists)
│   ├── conversation/
│   │   ├── models/
│   │   │   ├── message.dart      # Message model (user/AI, transcript, audio path)
│   │   │   └── scenario.dart     # Scenario model (title, persona, goal, CEFR)
│   │   ├── providers/
│   │   │   └── conversation_provider.dart  # Riverpod providers
│   │   ├── screens/
│   │   │   └── conversation_screen.dart
│   │   └── widgets/
│   │       ├── voice_message_bubble.dart
│   │       ├── mic_button.dart
│   │       └── ai_response_bubble.dart
│   └── scenario_selection/
│       ├── models/
│       │   └── scenario.dart     # Scenario data model
│       ├── providers/
│       │   └── scenario_provider.dart
│       ├── screens/
│       │   └── scenario_selection_screen.dart
│       └── widgets/
│           └── scenario_card.dart
├── data/
│   ├── local/                    # Local storage helpers
│   │   └── local_storage.dart
│   └── scenarios/                # Curated scenario JSON files
│       ├── cafe_ordering.json
│       ├── job_interview.json
│       └── airport_navigation.json
└── main.dart
```

### Pattern 1: STT Service Wrapper
**What:** Wraps speech_to_text in a clean async interface for the conversation screen
**When to use:** Every time STT is needed -- decouples platform specifics from UI
**Example:**
```dart
// Source: Context7 /csdcorp/speech_to_text
class SttService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<void> startListening({
    required SpeechResultListener onResult,
    SpeechSoundLevelChange? onSoundLevel,
    String? localeId,
  }) async {
    await _speech.listen(
      onResult: onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
      localeId: localeId,
      onSoundLevelChange: onSoundLevel,
    );
  }

  Future<void> stopListening() async => _speech.stop();
  bool get isListening => _speech.isListening;
}
```

### Pattern 2: TTS Service with Completion Handler
**What:** Wraps flutter_tts with event handlers and awaitSpeakCompletion
**When to use:** For speaking AI responses and tracking playback state
**Example:**
```dart
// Source: Context7 /dlutton/flutter_tts
class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);  // Slower for language learners
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();

  void setCompletionHandler(VoidCallback onComplete) {
    _tts.setCompletionHandler(onComplete);
  }
}
```

### Pattern 3: Gemini AI Service with System Prompt
**What:** Creates a persona-based chat session with system instruction
**When to use:** For AI character conversations -- system prompt defines persona
**Example:**
```dart
// Source: WebSearch / google_generative_ai package
class AiService {
  late GenerativeModel _model;
  late ChatSession _chat;

  void initializePersona({
    required String personaName,
    required String personaDescription,
    required String scenarioGoal,
  }) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.system(
        'You are $personaName. $personaDescription '
        'Your goal in this conversation: $scenarioGoal. '
        'Stay in character at all times. Keep responses short and natural '
        'for a spoken conversation (1-3 sentences). '
        'If the user makes grammar mistakes, gently correct them naturally '
        'within the conversation rather than breaking character.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String userText) async {
    final response = await _chat.sendMessage(Content.text(userText));
    return response.text ?? '';
  }

  Stream<String> sendMessageStream(String userText) async* {
    await for (final chunk in _chat.sendMessageStream(Content.text(userText))) {
      if (chunk.text != null) yield chunk.text!;
    }
  }
}
```

### Pattern 4: Voice Message Bubble Widget
**What:** Custom widget showing transcript under an audio-style bubble
**When to use:** For both user and AI message bubbles in conversation screen
**Key design:** Right-aligned for user (own side), left-aligned for AI (other side), transcript text below the bubble

### Anti-Patterns to Avoid
- **Hardcoding system prompts in UI code:** CLAUDE.md says "Keep AI system prompts server-side or in a config layer, not hardcoded per-screen"
- **Trusting client-side rate limiting:** CLAUDE.md says "implement rate limiting server-side or via Cloud Function, never trust client"
- **Using free-typing chat UI:** This is voice-message based, not text chat -- do not use text input fields for conversation
- **Ignoring platform differences:** speech_to_text has different behavior on iOS vs Android vs Web -- handle each case

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Speech recognition | Custom audio processing | `speech_to_text` | Wraps platform-native STT with permission handling |
| Text-to-speech | Custom audio playback | `flutter_tts` | Wraps platform-native TTS with language/pitch/rate control |
| AI chat sessions | Raw HTTP + manual history | `google_generative_ai` startChat() | Manages conversation history, streaming, auth automatically |
| Local storage | Manual file I/O | `shared_preferences` | Handles platform differences, type safety, async |
| Device identification | Custom hashing | `device_info_plus` | Cross-platform device ID without custom logic |

**Key insight:** The STT/TTS packages wrap complex platform-specific code (permissions, audio sessions, speech engines). Hand-rolling these would require platform channels and native code for each platform.

## Common Pitfalls

### Pitfall 1: speech_to_text Initialization Race Condition
**What goes wrong:** Calling listen() before initialize() completes causes silent failure
**Why it happens:** initialize() is async and must complete before any listen call
**How to avoid:** Always await initialize() in initState or a provider, check `_speechEnabled` before allowing mic tap
**Warning signs:** Mic button does nothing, no permission dialog appears

### Pitfall 2: TTS Speaking Before STT Stops
**What goes wrong:** On some devices, starting TTS while STT is still listening causes audio feedback loop
**Why it happens:** Both use device microphone/speaker simultaneously
**How to avoid:** Always stop STT before starting TTS. Use a state machine: RECORDING -> PROCESSING -> SPEAKING -> IDLE
**Warning signs:** Echo, garbled AI speech, STT picking up AI voice

### Pitfall 3: Gemini API Key Exposure
**What goes wrong:** API key hardcoded in source code gets committed to git
**Why it happens:** Quick development shortcut
**How to avoid:** Use `--dart-define=API_KEY=xxx` at build time, read via `String.fromEnvironment('API_KEY')`
**Warning signs:** API key visible in source control

### Pitfall 4: Web Platform STT Limitations
**What goes wrong:** speech_to_text works on iOS/Android but fails silently on web
**Why it happens:** Web speech recognition requires HTTPS and specific browser support
**How to avoid:** Check `_speechToText.initialize()` return value, show fallback UI on web if unavailable
**Warning signs:** Works on mobile, blank on web

### Pitfall 5: Conversation History Grows Unbounded
**What goes wrong:** Long conversations consume excessive tokens, API costs spike
**Why it happens:** Gemini chat sessions keep full history
**How to avoid:** Limit conversation to N turns per scenario, or trim old messages from history
**Warning signs:** Slow responses, API quota errors

## Code Examples

### Message Model
```dart
enum MessageSender { user, ai }

class Message {
  final String id;
  final MessageSender sender;
  final String transcript;
  final DateTime timestamp;
  final Duration? audioDuration;

  const Message({
    required this.id,
    required this.sender,
    required this.transcript,
    required this.timestamp,
    this.audioDuration,
  });
}
```

### Scenario Model
```dart
class Scenario {
  final String id;
  final String title;
  final String description;
  final String personaName;
  final String personaDescription;
  final String goalDescription;
  final String cefrLevel; // A1, A2, B1, B2, C1
  final String category; // travel, work, exam, daily

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.personaName,
    required this.personaDescription,
    required this.goalDescription,
    required this.cefrLevel,
    required this.category,
  });
}
```

### Curated Scenario Example (cafe_ordering.json)
```json
{
  "id": "cafe_ordering",
  "title": "Ordering at a Cafe",
  "description": "Practice ordering food and drinks at an English-speaking cafe",
  "personaName": "Emma",
  "personaDescription": "You are Emma, a friendly barista at a cozy London cafe. You are patient and encouraging with language learners.",
  "goalDescription": "Successfully order a drink and a snack, ask about ingredients, and handle the payment",
  "cefrLevel": "A2",
  "category": "travel",
  "openingMessage": "Hi there! Welcome to The Cozy Bean. What can I get for you today?"
}
```

### Riverpod Conversation Provider
```dart
@immutable
class ConversationState {
  final List<Message> messages;
  final bool isRecording;
  final bool isAiSpeaking;
  final String currentTranscript;
  final Scenario scenario;

  const ConversationState({
    required this.messages,
    required this.isRecording,
    required this.isAiSpeaking,
    required this.currentTranscript,
    required this.scenario,
  });
}

final conversationProvider = StateNotifierProvider.autoDispose<
    ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Raw platform channels for STT | `speech_to_text` package | 2019+ | Eliminates native code for speech recognition |
| Custom TTS implementations | `flutter_tts` with awaitSpeakCompletion | 2020+ | Synchronous completion handling simplifies flow |
| Manual HTTP for Gemini | `google_generative_ai` with ChatSession | 2024+ | Built-in history management, streaming, auth |
| StatefulWidget everywhere | Riverpod providers | 2022+ | Testable, composable state management |

**Deprecated/outdated:**
- `speech_to_text` listen() old parameters (listenFor, pauseFor) are deprecated -- use `SpeechListenOptions` instead
- Gemini 1.0 models -- use 1.5 Flash or newer for system instruction support

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Gemini API free tier is sufficient for Phase 1 dev/testing | Standard Stack | May need to budget for API costs during development |
| A2 | speech_to_text works on Web (Chrome/Edge) with HTTPS | Cross-Platform | Web STT may need fallback or be deferred |
| A3 | Device-native TTS quality is acceptable for language learning | TTS Service | May need to improve TTS quality — no paid APIs planned, app is 100% free |
| A4 | SharedPreferences is sufficient for guest mode data in Phase 1 | Local Storage | May need Hive if data model grows complex |

## Open Questions

1. **Gemini API key management for development**
   - What we know: Use `--dart-define` for build-time injection
   - What's unclear: How to handle key rotation, multiple developer keys
   - Recommendation: Use `.env` file with `--dart-define-from-file` (Flutter 3.7+)

2. **Web STT reliability**
   - What we know: speech_to_text supports web via Web Speech API
   - What's unclear: How reliable is web STT for continuous speech vs short commands
   - Recommendation: Test early; if unreliable, mark web as "best effort" for voice features

3. **Scenario data storage location**
   - What we know: CLAUDE.md says "server-side or config layer" for AI prompts
   - What's unclear: Should scenarios be bundled as JSON assets or fetched from Firebase
   - Recommendation: Bundle as JSON assets for Phase 1 (no auth yet), migrate to Firestore in Phase 2

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All | Check via `flutter --version` | 3.10.8+ (pubspec) | — |
| Dart SDK | All | Check via `dart --version` | ^3.10.8 (pubspec) | — |
| iOS Simulator/Device | iOS testing | Check via `xcrun simctl list` | — | Android-only dev |
| Android Emulator/Device | Android testing | Check via `flutter devices` | — | iOS-only dev |
| Chrome | Web testing | Check via `which chrome` | — | Mobile-only dev |

**Missing dependencies with no fallback:**
- None identified -- all are standard Flutter development tools

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | none -- uses default |
| Quick run command | `flutter test` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CONV-01 | Browse and select scenarios | unit | `flutter test features/scenario_selection/` | Wave 0 |
| CONV-03 | Free-flow voice conversation | integration | Manual -- requires mic + AI API | Wave 0 |
| CONV-04 | AI stays in character | integration | Manual -- requires AI API response check | Wave 0 |
| CONV-05 | User voice message bubbles with transcript | widget | `flutter test features/conversation/widgets/` | Wave 0 |
| CONV-06 | AI response bubbles with transcript | widget | `flutter test features/conversation/widgets/` | Wave 0 |
| PLAT-01 | Works on iOS, Android, Web | platform | `flutter build` for each platform | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test`
- **Per wave merge:** `flutter test`
- **Phase gate:** All tests green + manual voice conversation verification

### Wave 0 Gaps
- [ ] `flutter test` -- framework is built-in, no install needed
- [ ] Widget tests for voice_message_bubble -- needs mock STT/TTS
- [ ] Unit test for scenario loading from JSON assets
- [ ] Integration test for conversation flow -- needs API key in test env

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No (Phase 1, no auth) | N/A |
| V3 Session Management | No | N/A |
| V4 Access Control | No | N/A |
| V5 Input Validation | Yes | Validate AI response before display, sanitize user transcripts |
| V6 Cryptography | Yes | API key via --dart-define, never in source code |

### Known Threat Patterns for Flutter + Gemini Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| API key exposure | Information Disclosure | Use --dart-define, never commit keys, rotate keys |
| Excessive AI API calls (abuse) | Denial of Service | Server-side rate limiting (Phase 4 concern, but design for it now) |
| Injection via user speech | Tampering | Sanitize transcript before sending to AI, though LLMs handle this reasonably |
| Audio recording permission abuse | Elevation of Privilege | Only request mic permission when user taps record button |

## Sources

### Primary (HIGH confidence)
- Context7 `/csdcorp/speech_to_text` - 172 snippets, initialization, listen(), SpeechListenOptions, permissions
- Context7 `/dlutton/flutter_tts` - 51 snippets, speak(), event handlers, awaitSpeakCompletion
- Official pub.dev `google_generative_ai` - chat sessions, system instructions, streaming
- CLAUDE.md project brief - architecture, tech stack, Phase 1 requirements

### Secondary (MEDIUM confidence)
- WebSearch results for voice message bubble UI patterns
- WebSearch results for Google Generative AI Dart integration

### Tertiary (LOW confidence)
- None -- all findings backed by Context7 docs or official sources

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH - All packages verified via Context7 documentation with code examples
- Architecture: HIGH - MVVM + Feature-First is well-documented Flutter pattern, CLAUDE.md specifies it
- Pitfalls: HIGH - Based on documented package limitations and common Flutter patterns

**Research date:** 2026-07-15
**Valid until:** 2026-08-15 (30 days -- Flutter packages are stable)

---

## RESEARCH COMPLETE
