---
status: testing
phase: 04-gamification-retention
source: [04-VERIFICATION.md]
started: 2026-07-21
updated: 2026-07-21
---

## Current Test

number: 1
name: End-to-End Gamification Flow
expected: |
  Complete a scenario as authenticated user; verify Firestore writes for streak, XP, badges, SRS, and mistakes
  All 5 Firestore writes appear in user document/subcollections
awaiting: user response

## Tests

### 1. End-to-End Gamification Flow
expected: Complete a scenario as authenticated user; verify Firestore writes for streak, XP, badges, SRS, and mistakes. All 5 Firestore writes appear in user document/subcollections.
result: [pending]

### 2. Streak Logic Across Days
expected: Complete scenarios on consecutive days, skip a day, verify streak increments and resets correctly. Streak shows correct count on Progress screen.
result: [pending]

### 3. SRS Pipeline End-to-End
expected: Complete a scenario with grammar corrections, start new scenario, verify pre-scenario review shows those corrections. PreScenarioReviewScreen displays grammar items from ScoreData.
result: [pending]

### 4. Badge Popup Visual
expected: Earn a badge, verify BadgePopup with confetti appears on FeedbackScreen. BadgePopup overlay shows with confetti and auto-dismisses after 4 seconds.
result: [pending]

### 5. Progress Screen Data Accuracy
expected: View Progress screen, verify all stats (level, XP, streak, badges, mistakes) display real data. Correct values rendered from Firestore.
result: [pending]

### 6. Leaderboard Ranking and Styling
expected: View Leaderboard, verify users ranked by XP with gold/silver/bronze for top 3. Ordered list with correct indicators.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
