# Conversation Screen Update Plan

## Overview
Two work packages across ~8 files (5 modified + 3 new/improved). Requirement 3 (Myanmar localization) is flagged as future roadmap — not implemented now.

---

## Package 1: Voice Message UI & Audio Player

### Goal
Audio-first bubbles with Play/Pause controls and collapsible transcripts.

### Files & Changes

| # | File | Change |
|---|------|--------|
| 1 | `lib/features/conversation/providers/conversation_provider.dart` | Add `playingMessageId` field to `ConversationState` to track which audio is actively playing |
| 2 | `lib/features/conversation/viewmodels/conversation_viewmodel.dart` | Add `playMessage(String id, String text)` and `stopPlayback()` methods. `playMessage` stops any current TTS, sets `playingMessageId`, and speaks the given transcript. On completion, clears `playingMessageId` back to null. |
| 3 | `lib/features/conversation/widgets/voice_message_bubble.dart` | **Major rewrite.** Add local `_showTranscript` boolean (ValueNotifier). AI bubbles: replace static volume-up icon with Play/Pause icon button. User bubbles: keep mic icon (no replayable audio). Add "Show Transcript" / "Hide Transcript" toggle button below the bubble. Transcript hidden by default. Accept `onPlayPause` callback, `isPlaying` prop. |
| 4 | `lib/features/conversation/screens/conversation_screen.dart` | Wire the new `onPlayPause` callback from bubble → ViewModel. Pass `playingMessageId` from state down to each bubble. |

### UX Flow
```
[AI Bubble]                               [User Bubble]
┌──────────────────┐                      ┌──────────────────┐
│  ▶ [waveform]    │  ← Play button       │  🎤 [waveform]   │
└──────────────────┘                      └──────────────────┘
  [Show Transcript]  ← toggle                [Show Transcript]
  (hidden by default)
```

---

## Package 2: Conversation History & Persistence

### Goal
Users can resume their last conversation or start fresh. Clear on exit is user-controlled.

### Approach: Option B (Contextual Entry/Exit Modal)
- **New Chat button** in the top bar (next to back arrow) — clears current conversation immediately with a confirmation dialog
- **Exit dialog** — when pressing back, ask: "Save conversation for later?" → Yes (persists) / No (discard)
- **Resume on re-entry** — if a saved conversation exists for this scenario, show a prompt: "Resume previous chat?" / "Start fresh"

### Files & Changes

| # | File | Change |
|---|------|--------|
| 5 | `lib/core/services/conversation_storage_service.dart` | **New file.** Persistence layer. For guests: serialize conversation state to SharedPreferences as JSON. For auth users: save to Firestore `users/{uid}/conversations/{scenarioId}`. Methods: `saveConversation`, `loadConversation`, `deleteConversation`, `hasSavedConversation`. |
| 6 | `lib/features/conversation/viewmodels/conversation_viewmodel.dart` | Add `saveConversation()`, `loadSavedConversation()`, `clearConversation()` methods that delegate to ConversationStorageService. Call `saveConversation()` on exit. Call `loadSavedConversation()` during `build()`. |
| 7 | `lib/features/conversation/providers/conversation_provider.dart` | No state changes needed — uses existing `ConversationState` fields. |
| 8 | `lib/features/conversation/screens/conversation_screen.dart` | Add "New Chat" icon button in top bar (with confirmation dialog). Back button shows exit dialog with save/discard options. On load, check for saved conversation and show resume prompt. |

### UX Flow
```
On Exit (back button):
┌─────────────────────────────────┐
│ Save conversation for later?    │
│                                 │
│ [Save & Exit]  [Discard]        │
│                                 │
│ (Saved conversations can be     │
│  resumed from scenario list)    │
└─────────────────────────────────┘

New Chat button:
┌─────────────────────────────────┐
│ Start a new conversation?       │
│ Current progress will be lost.  │
│                                 │
│ [New Chat]  [Cancel]            │
└─────────────────────────────────┘

On Re-entry (when saved exists):
┌─────────────────────────────────┐
│ You have a saved conversation   │
│ from earlier.                   │
│                                 │
│ [Resume]  [Start Fresh]         │
└─────────────────────────────────┘
```

---

## Package 3: Future Roadmap (Not implemented)

Logged for later:
- Myanmar (Burmese) language UI support in conversation view
- Dynamic transcript translation button (AI-powered translation of transcripts to Myanmar text)

---

## Implementation Order
1. Package 1 (Voice Message UI) — 4 files, self-contained
2. Package 2 (History/Persistence) — 4 files, depends on Package 1

## Dependency check
- Package 2 depends on `shared_preferences` — already in `pubspec.yaml` ✅
- Package 2 depends on `cloud_firestore` — already in `pubspec.yaml` ✅
- No new packages needed for either package
