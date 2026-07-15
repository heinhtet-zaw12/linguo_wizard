---
status: testing
phase: 01-foundation-core-voice-loop
source: [01-VERIFICATION.md]
started: 2026-07-15T00:00:00Z
updated: 2026-07-15T00:00:00Z
---

## Current Test

number: 1
name: Conversation State Machine Full Cycle
expected: |
  Launch app, tap mic, speak, release, wait for AI response and TTS,
  tap mic again. State transitions IDLE -> RECORDING -> PROCESSING ->
  SPEAKING -> IDLE with correct button states and no audio feedback echo.
awaiting: user response

## Tests

### 1. Conversation State Machine Full Cycle
expected: State transitions IDLE -> RECORDING -> PROCESSING -> SPEAKING -> IDLE with correct button states
result: [pending]

### 2. Voice Message Bubble Visual Rendering
expected: User bubbles (right-aligned pink, mic icon, transcript) and AI bubbles (left-aligned white, volume icon, transcript) render correctly
result: [pending]

### 3. Scenario Selection Grid Display
expected: 2-column grid with 3 cards showing CEFR badge, category, title, description, persona; tap navigates to conversation
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
