# Phase 8: Text-Only AI Response Mode — Context

**Gathered:** 2026-08-10
**Status:** Ready for planning
**Source:** Design spec (`docs/superpowers/specs/2026-08-10-text-only-mode-design.md`)

<domain>
## Phase Boundary

Add a toggle on the conversation screen that disables TTS playback and renders AI responses as simple text bubbles instead of voice message bubbles. User still speaks via mic (STT active). Preference is not persisted across sessions.

</domain>

<decisions>
## Implementation Decisions

### State Management
- Add `bool textOnlyMode = false` to `ConversationState` in `conversation_provider.dart`
- State is not persisted (reset on each conversation entry)

### ViewModel Logic
- Add `void toggleTextOnlyMode()` method to `ConversationViewModel`
- In `_processFinalTranscript()`, skip `_ttsService.speak()` when `textOnlyMode == true`
- When skipping TTS, set state directly to `idle` (no `speaking` state transition)

### UI Toggle
- Toggle button in top-right area of conversation screen (near End Conversation button)
- Icon: `Icons.chat` (text-only ON) / `Icons.record_voice_over` (voice mode)
- Tooltip: "Text-only mode"

### New Widget: TextMessageBubble
- Simple glass card displaying AI transcript text
- GlassCard with accentCyan glow (consistent with AI voice bubble style)
- Transcript text using `AppTextStyles.labelMedium`
- No play button, no waveform, no audio controls
- Aligns left (AI side)

### Message Rendering Logic
- If `textOnlyMode == true` AND `message.sender == MessageSender.ai` → render `TextMessageBubble`
- Otherwise → render `VoiceMessageBubble` (existing behavior)
- User message bubbles always render as voice bubbles regardless of mode

### Claude's Discretion
- TextMessageBubble styling follows existing GlassCard + accentCyan glow pattern from VoiceMessageBubble
- Toggle button uses IconButton with Tooltip widget for accessibility
- No changes to user message bubbles

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Conversation Feature
- `lib/features/conversation/viewmodels/conversation_viewmodel.dart` — Core conversation logic, `_processFinalTranscript()` method to modify
- `lib/features/conversation/providers/conversation_provider.dart` — ConversationState definition to extend
- `lib/features/conversation/screens/conversation_screen.dart` — Screen to add toggle and conditional rendering
- `lib/features/conversation/widgets/voice_message_bubble.dart` — Existing voice bubble (reference for TextMessageBubble style)

### Design System
- `lib/core/widgets/app_card.dart` — GlassCard widget to use in TextMessageBubble
- `lib/core/theme/app_colors.dart` — AppColors.accentCyan for glow styling
- `lib/core/theme/app_text_styles.dart` — AppTextStyles.labelMedium for transcript text
- `lib/core/theme/app_dimensions.dart` — AppRadius tokens

### Models
- `lib/features/conversation/models/message.dart` — Message model with MessageSender enum

</canonical_refs>

<specifics>
## Specific Ideas

- The toggle persists only for the current conversation session (not across app restarts)
- STT remains active in text-only mode — user still speaks via mic
- AI responses skip TTS and go directly to idle state
- TextMessageBubble is visually simpler than VoiceMessageBubble — just text in a glass card

</specifics>

<deferred>
## Deferred Ideas

- Persisting text-only preference across sessions
- Text-only input mode (user always speaks via mic)
- Changing user message bubbles

</deferred>

---

*Phase: 08-text-only-ai-mode*
*Context gathered: 2026-08-10 from design spec*
