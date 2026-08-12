# Text-Only AI Response Mode

**Date:** 2026-08-10
**Status:** Draft
**Scope:** Conversation screen toggle for text-only AI responses

## Problem

Some users prefer reading AI responses over listening to audio. Currently, every AI response triggers TTS playback with no way to disable it.

## Solution

Add a toggle on the conversation screen that disables TTS and renders AI responses as simple text bubbles instead of voice message bubbles.

## User Flow

1. User enters conversation screen
2. User taps toggle (top-right, near End button) to enable text-only mode
3. User speaks via mic (STT still active)
4. AI responds with text bubble (no audio, no waveform, no play button)
5. User can toggle back to voice mode mid-conversation

## Design

### ConversationState Changes

Add `bool textOnlyMode = false` to `ConversationState`.

### ConversationViewModel Changes

- Add `void toggleTextOnlyMode()` method
- In `_processFinalTranscript()`, skip `_ttsService.speak()` when `textOnlyMode == true`
- When skipping TTS, set state directly to `idle` (no `speaking` state)

### New Widget: TextMessageBubble

Simple glass card displaying AI transcript text:
- GlassCard with accentCyan glow (consistent with AI voice bubble style)
- Transcript text using `AppTextStyles.labelMedium`
- No play button, no waveform, no audio controls
- Aligns left (AI side)

### ConversationScreen Changes

Add toggle button in top-right area (near End Conversation button):
- Icon: `Icons.chat` (text-only) / `Icons.record_voice_over` (voice)
- Tooltip: "Text-only mode"
- Calls `viewModel.toggleTextOnlyMode()`

### Message Rendering Logic

In `conversation_screen.dart`, when building message list:
- If `textOnlyMode == true` AND `message.sender == MessageSender.ai` → render `TextMessageBubble`
- Otherwise → render `VoiceMessageBubble` (existing behavior)

## Files to Modify

| File | Change |
|------|--------|
| `lib/features/conversation/providers/conversation_provider.dart` | Add `textOnlyMode` to state |
| `lib/features/conversation/viewmodels/conversation_viewmodel.dart` | Add `toggleTextOnlyMode()`, conditionally skip TTS |
| `lib/features/conversation/screens/conversation_screen.dart` | Add toggle button, conditional bubble rendering |
| NEW: `lib/features/conversation/widgets/text_message_bubble.dart` | Simple text bubble for AI messages |

## Out of Scope

- Persisting preference across sessions (per user request)
- Text-only input mode (user still speaks via mic)
- Changing user message bubbles (remain as voice bubbles)

## Success Criteria

1. Toggle visible on conversation screen
2. When ON: AI responses render as text bubbles, no TTS plays
3. When OFF: Existing voice bubble behavior preserved
4. Toggle can be switched mid-conversation
5. `flutter analyze` passes with zero errors
