---
phase: "05"
plan: "02"
subsystem: "scenario-selection"
tags: ["custom-scenarios", "ai-generation", "gemini", "firestore", "my-scenarios"]
requires: ["05-01-PLAN.md (Firestore scenario catalog)"]
provides: ["Custom-scenario-creation-flow", "AiService-generateScenario", "CreateScenarioScreen", "My-Scenarios-section"]
affects: ["scenario-selection-screen", "router", "firestore-rules", "ai-service"]
tech-stack:
  added: ["CreateScenarioScreen", "CreateScenarioViewModel", "ScenarioPreviewCard"]
  patterns: ["Gemini structured JSON for scenario generation", "Optimistic removal with revert on delete failure"]
key-files:
  created:
    - "lib/features/scenario_selection/screens/create_scenario_screen.dart"
    - "lib/features/scenario_selection/viewmodels/create_scenario_viewmodel.dart"
    - "lib/features/scenario_selection/widgets/scenario_preview_card.dart"
  modified:
    - "lib/core/services/ai_service.dart"
    - "lib/core/services/scenario_service.dart"
    - "lib/core/providers/service_providers.dart"
    - "lib/features/scenario_selection/screens/scenario_selection_screen.dart"
    - "lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart"
    - "lib/features/scenario_selection/widgets/scenario_card.dart"
    - "lib/features/navigation/router.dart"
    - "firestore.rules"
  removed: []
decisions:
  - "Added optional trailing widget to ScenarioCard for custom scenario delete menu"
  - "CustomScrollView with slivers for My Scenarios section above curated grid"
  - 'Try It button saves and immediately navigates to conversation (not double-tap)'
  - "Guest users see sign-up dialog on Create Scenario button tap"
  - "Reused existing Scenario.toJson() from Plan 05-01 (plan mentioned adding it but it already existed)"
metrics:
  duration: "22 minutes"
  completed_date: "2026-07-23"
status: "complete"
---

# Phase 5 Plan 02: Custom Scenario Creation — Summary

Users can now create unlimited custom conversation scenarios by describing a persona, context, and goal. Gemini generates a structured scenario config, the user reviews a read-only preview, and it's saved to Firestore where it appears in the "My Scenarios" section alongside curated scenarios. Every user gets unlimited creation — completely free.

## What Was Built

### 1. AiService.generateScenario (Task 1)

Added a new `generateScenario()` method to `AiService` that uses Gemini structured JSON output (`responseSchema`) to produce complete Scenario objects from free-form user input. The method accepts `persona`, `context`, `goal`, `cefrLevel`, and `tone` parameters. It includes:
- Structured JSON schema validation via `responseSchema` (8 required fields)
- 30-second timeout with `TimeoutException`
- Error handling for empty responses
- CEFR-to-difficulty mapping (`_difficultyForLevel`)
- Provider registered in `service_providers.dart`

The method is completely stateless — does not affect existing chat sessions.

### 2. Custom Scenario CRUD in ScenarioService (Task 2)

Extended `FirestoreScenarioService` with three methods:
- `saveCustomScenario()` — saves to `users/{uid}/custom_scenarios/{id}` with `createdAt` server timestamp
- `getCustomScenarios()` — loads all custom scenarios for a user, newest first (per D-12)
- `deleteCustomScenario()` — deletes a custom scenario document

The Scenario model's existing `toJson()` method (from Plan 05-01) is reused for serialization.

### 3. Create Scenario Flow (Task 3)

**CreateScenarioViewModel** — state machine with 5 steps (form, generating, preview, saving, saved):
- Form fields: persona, context, goal, CEFR level (A1-C1), tone (casual/formal)
- `generate()` validates all fields filled, calls `AiService.generateScenario()`, transitions to preview
- `regenerate()` calls generate again with same inputs
- `save()` persists to Firestore via `ScenarioService.saveCustomScenario()`
- `edit()` returns to form step
- Error handling for generation failures and save failures

**CreateScenarioScreen** — 3-step wizard:
1. Form: 3 TextFields with hints per UI-SPEC, CEFR chip selector, tone chip selector, "Generate Scenario" button
2. Preview: read-only preview card (per D-10), "Try It" button (saves + navigates), Regenerate, Back to Form, Discard (with confirmation dialog)
3. Saved: success message with "Start Conversation" and "Back to Scenarios"

Full-screen loading overlay during generation with "Generating your scenario..." text.

**ScenarioPreviewCard** — reusable widget showing generated scenario details in claymorphism card: CEFR badge, category, title, persona, description, goal (highlighted), opening message, tags.

**Route:** `/create-scenario` added to GoRouter.

### 4. My Scenarios Section and Create Button (Task 4)

**ScenarioSelectionViewModel** updated to:
- Load custom scenarios from Firestore for authenticated users during `build()`
- Add `customScenarios` and `isLoadingCustomScenarios` to state
- Add `deleteCustomScenario()` with optimistic removal + revert on failure

**ScenarioSelectionScreen** updated with:
- "Create Scenario" IconButton (add_circle_outline) in header alongside search icon
- Guest users shown sign-up dialog when tapping Create button
- CustomScrollView replacing simple GridView: My Scenarios section (if custom scenarios exist) above curated grid
- "My Scenarios" section header in Fredoka 20px
- "Curated Scenarios" divider label between sections
- Custom scenario cards with three-dot menu (PopupMenuButton) and "Delete Scenario" option
- Delete confirmation dialog with "This can't be undone" copy (per D-11) and coral Delete button

**ScenarioCard** updated with optional `trailing` widget for the popup menu button.

### 5. Firestore Rules (Task 5)

Added `match /custom_scenarios/{docId}` block inside `users/{userId}` with owner-only read/write access, matching the pattern of existing user subcollections.

## Deviations from Plan

### Rule 2 — Auto-add missing critical functionality

**Issue: Navigation from Create Scenario screen needed selectedScenarioProvider**
- Found during Task 3/4 integration
- The "Try It" and "Start Conversation" buttons need to set `selectedScenarioProvider` before navigating to `/conversation/{id}`, otherwise the conversation screen wouldn't know which scenario to load
- Fix: Added `ref.read(selectedScenarioProvider.notifier).state = scenario` before `context.push()`
- Files: `lib/features/scenario_selection/screens/create_scenario_screen.dart`
- Commit: `e3a3ba6`

**Issue: Custom scenario card needed delete action**
- The plan specified delete via three-dot menu, but `ScenarioCard` had no parameter for a trailing action widget
- Fix: Added optional `Widget? trailing` parameter to `ScenarioCard`
- Files: `lib/features/scenario_selection/widgets/scenario_card.dart`
- Commit: `3d36d26`

**Issue: "Try it" button in create flow needed async gap guard**
- The `await notifier.save()` call crossed an async gap, requiring a `context.mounted` check before navigation
- Fix: Added `if (!context.mounted) return;` guard
- Files: `lib/features/scenario_selection/screens/create_scenario_screen.dart`
- Commit: `e3a3ba6`

### Minor Discrepancies

**Plan stated adding toJson() to Scenario model but it already existed**
- Task 2 action said to add toJson() but it was already added in Plan 05-01
- No change needed — reused existing method

**Removed unnecessary `as Map<String, dynamic>` cast**
- `QueryDocumentSnapshot.data()` already returns `Map<String, dynamic>` (non-nullable)
- Cast was removed to fix a flutter analyze warning

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze lib/` | 0 errors, 0 warnings (1 pre-existing info-level note) |
| CreateScenarioScreen exists | PASS |
| CreateScenarioViewModel exists | PASS |
| ScenarioPreviewCard exists | PASS |
| AiService.generateScenario exists | PASS |
| Custom scenario CRUD in ScenarioService | PASS |
| Create Scenario button in header | PASS |
| My Scenarios section in CustomScrollView | PASS |
| Delete menu with confirmation dialog | PASS |
| "/create-scenario" route in router | PASS |
| Firestore rules for custom_scenarios | PASS |
| Guest user sign-up prompt | PASS |
| Try It saves and navigates | PASS |

## Known Stubs

None. The create scenario flow is fully wired: form → generation → preview → save → navigate to conversation. The My Scenarios section loads from Firestore (empty for new users). Guest users are shown a sign-up prompt instead of the create screen.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| threat_flag: new_auth_path | lib/features/navigation/router.dart | `/create-scenario` is a new route accessible to any authenticated user |
| threat_flag: owner_data_write | lib/core/services/scenario_service.dart | `saveCustomScenario` writes to `users/{uid}/custom_scenarios/{id}` — mitigated by Firestore owner-only rules |
| threat_flag: owner_data_delete | lib/core/services/scenario_service.dart | `deleteCustomScenario` deletes from owner's subcollection — mitigated by Firestore owner-only rules |

## Self-Check: PASSED

- All created files exist at their expected paths
- All 5 task commits present in git log
- `flutter analyze lib/` passes with 0 errors
