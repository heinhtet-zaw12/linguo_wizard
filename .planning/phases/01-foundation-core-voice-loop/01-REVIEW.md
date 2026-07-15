---
phase: 01-foundation-core-voice-loop
reviewed: 2026-07-15T00:00:00Z
depth: standard
files_reviewed: 18
files_reviewed_list:
  - lib/core/config/app_config.dart
  - lib/core/services/ai_service.dart
  - lib/core/services/stt_service.dart
  - lib/core/services/tts_service.dart
  - lib/core/theme/app_theme.dart
  - lib/features/conversation/models/message.dart
  - lib/features/conversation/models/scenario.dart
  - lib/features/conversation/providers/conversation_provider.dart
  - lib/features/conversation/screens/conversation_screen.dart
  - lib/features/conversation/widgets/mic_button.dart
  - lib/features/conversation/widgets/voice_message_bubble.dart
  - lib/features/scenario_selection/providers/scenario_provider.dart
  - lib/features/scenario_selection/screens/scenario_selection_screen.dart
  - lib/features/scenario_selection/widgets/scenario_card.dart
  - lib/features/splash/splash_screen.dart
  - lib/main.dart
  - pubspec.yaml
  - test/widget_test.dart
findings:
  critical: 2
  warning: 4
  info: 1
  total: 7
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-07-15T00:00:00Z
**Depth:** standard
**Files Reviewed:** 18
**Status:** issues_found

## Summary

The Phase 1 foundation and core voice loop implementation is structurally sound — the feature-first MVVM layout is clean, Riverpod state management is used correctly, and the voice conversation state machine is well-designed. However, there are two critical issues where unhandled exceptions in async AI/TTS calls can leave the conversation UI permanently stuck in a non-recoverable state, and several warnings around missing error handling and edge cases that degrade robustness.

## Critical Issues

### CR-01: Unhandled exceptions in AI and TTS calls leave conversation permanently stuck

**File:** `lib/features/conversation/screens/conversation_screen.dart:170-191`
**Issue:** The `_processFinalTranscript` method calls `_aiService.sendMessage(transcript)` and `_ttsService.speak(aiResponseText)` without any try-catch. If the Gemini API call fails (network error, API key issue, rate limit, malformed response) or TTS fails, the exception propagates unhandled. The conversation state remains stuck in `ConversationLoopState.processing` or `ConversationLoopState.speaking` indefinitely. The user has no way to recover — the mic button is disabled in both states, so the conversation is dead.

**Fix:**
```dart
Future<void> _processFinalTranscript(String transcript) async {
  if (transcript.trim().isEmpty) {
    // ... existing empty transcript handling ...
    return;
  }

  // Transition to processing
  var current = ref.read(conversationStateProvider);
  ref.read(conversationStateProvider.notifier).state = current.copyWith(
    loopState: ConversationLoopState.processing,
    isRecording: false,
    currentPartialTranscript: '',
  );

  try {
    // Add user message
    final userMessage = Message.create(
      sender: MessageSender.user,
      transcript: transcript,
    );
    current = ref.read(conversationStateProvider);
    ref.read(conversationStateProvider.notifier).state = current.copyWith(
      messages: [...current.messages, userMessage],
      turnCount: current.turnCount + 1,
    );

    // Get AI response
    final aiResponseText = await _aiService.sendMessage(transcript);

    // Add AI message
    final aiMessage = Message.create(
      sender: MessageSender.ai,
      transcript: aiResponseText,
    );
    current = ref.read(conversationStateProvider);
    ref.read(conversationStateProvider.notifier).state = current.copyWith(
      messages: [...current.messages, aiMessage],
    );

    // Transition to speaking
    ref.read(conversationStateProvider.notifier).state = ref
        .read(conversationStateProvider)
        .copyWith(
          loopState: ConversationLoopState.speaking,
          isAiSpeaking: true,
        );

    await _ttsService.speak(aiResponseText);
  } catch (e) {
    // Reset to idle so the user can try again
    if (mounted) {
      final current = ref.read(conversationStateProvider);
      ref.read(conversationStateProvider.notifier).state = current.copyWith(
        loopState: ConversationLoopState.idle,
        isRecording: false,
        isAiSpeaking: false,
      );
    }
  }
}
```

### CR-02: Service initialization failures leave UI in permanent loading state

**File:** `lib/features/conversation/screens/conversation_screen.dart:52-89`
**Issue:** `_initializeServices()` is an async method called from `didChangeDependencies` with no error handling. If `_sttService.initialize()` or `_ttsService.initialize()` throws (e.g., microphone permission denied, TTS engine unavailable on device), the exception is unhandled. The `_servicesInitialized` flag is set to `true` before the async work completes (line 48), but if the async work fails, `_initializeServices` throws and `setState` at line 89 is never reached — however `_servicesInitialized` is already `true`, so the `build` method proceeds to watch `conversationStateProvider` which has no scenario set, leading to a conversation screen with no scenario and no way to recover.

Additionally, `setState(() {})` on line 89 is called after awaiting async operations without checking `mounted`, which can throw if the widget was disposed during initialization.

**Fix:**
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_servicesInitialized) return;
  _servicesInitialized = true;
  _initializeServices();
}

Future<void> _initializeServices() async {
  try {
    await _sttService.initialize();
    await _ttsService.initialize();
  } catch (e) {
    // Handle initialization failure — navigate back or show error
    if (mounted) {
      Navigator.of(context).pop();
    }
    return;
  }

  final scenario = ref.read(selectedScenarioProvider);
  if (scenario == null || !mounted) return;

  // ... rest of initialization ...

  if (mounted) {
    setState(() {});
  }
}
```

## Warnings

### WR-01: Scenario.fromJson crashes on missing JSON fields with no helpful error

**File:** `lib/features/conversation/models/scenario.dart:26-38`
**Issue:** `Scenario.fromJson` uses direct `as String` casts on every JSON field. If any field is missing or null in the JSON, a `TypeError` is thrown at runtime with no indication of which field is missing. Since scenarios are loaded from bundled asset JSON files, a typo or missing field in any JSON file will crash the scenario loading entirely.

**Fix:** Add null-checking with a descriptive error, or use a safer deserialization pattern:
```dart
factory Scenario.fromJson(Map<String, dynamic> json) {
  return Scenario(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Untitled',
    description: json['description'] as String? ?? '',
    personaName: json['personaName'] as String? ?? '',
    personaDescription: json['personaDescription'] as String? ?? '',
    goalDescription: json['goalDescription'] as String? ?? '',
    cefrLevel: json['cefrLevel'] as String? ?? 'A1',
    category: json['category'] as String? ?? '',
    openingMessage: json['openingMessage'] as String? ?? '',
  );
}
```

### WR-02: scenariosProvider has no error handling for missing asset files

**File:** `lib/features/scenario_selection/providers/scenario_provider.dart:9-23`
**Issue:** `rootBundle.loadString(path)` will throw a `FlutterError` if the asset file doesn't exist. The `FutureProvider` catches this and exposes it as `AsyncValue.error`, but the error message is just "Failed to load scenarios" with no retry mechanism. More importantly, if one of the three JSON files is corrupt or missing, the entire scenario list fails to load — there's no partial loading or fallback.

**Fix:** Consider wrapping individual file loads in try-catch so one corrupt file doesn't break all scenarios, or add a retry button in the UI error state.

### WR-03: _scrollToBottom called on every build when messages exist

**File:** `lib/features/conversation/screens/conversation_screen.dart:218-219`
**Issue:** `_scrollToBottom()` is called inside `build()` whenever `state.messages.isNotEmpty`. Since `build()` is called on every state change (recording, partial transcripts, processing, speaking), this triggers repeated `addPostFrameCallback` calls with scroll animations on every rebuild. This causes visual jank and wasted computation — the scroll animation restarts before the previous one finishes.

**Fix:** Only scroll when a new message is actually added, not on every rebuild. Track the previous message count and scroll only when it increases:
```dart
// In the widget state:
int _previousMessageCount = 0;

// In build():
if (state.messages.length > _previousMessageCount) {
  _previousMessageCount = state.messages.length;
  _scrollToBottom();
}
```

### WR-04: No error handling for AI response returning empty text

**File:** `lib/features/conversation/screens/conversation_screen.dart:170-180`
**Issue:** `_aiService.sendMessage` returns `response.text ?? ''` — an empty string. The conversation screen adds this as an AI message and attempts TTS on an empty string. Speaking an empty string via TTS is a no-op but still transitions through the speaking state, wasting time and confusing the user who sees an empty AI bubble. The user should see an error message or the AI response should be retried.

**Fix:** After receiving the AI response, check for empty text and either retry or show a user-visible error message in the chat:
```dart
final aiResponseText = await _aiService.sendMessage(transcript);
if (aiResponseText.isEmpty) {
  // Show error message in chat or retry
  final errorMessage = Message.create(
    sender: MessageSender.ai,
    transcript: "Sorry, I didn't catch that. Could you try again?",
  );
  // ... add to messages and skip TTS ...
  return;
}
```

## Info

### IN-01: Test coverage is minimal — only a smoke test exists

**File:** `test/widget_test.dart`
**Issue:** The test file contains a single smoke test that verifies the app renders without crashing. There are no unit tests for the conversation state machine, no tests for the AI service mock behavior, no tests for STT/TTS service wrappers, and no widget tests for individual screens. For an MVP, at minimum the conversation state transitions and message model should be tested.

**Fix:** Add unit tests for `ConversationState.copyWith` behavior, `Message.create` factory, and `Scenario.fromJson` deserialization. Add widget tests for `MicButton` state rendering and `VoiceMessageBubble` alignment.

---

_Reviewed: 2026-07-15T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
