---
phase: 05-premium-and-polish
verified: 2026-07-23T23:59:00Z
status: human_needed
score: 29/32 must-haves verified
behavior_unverified: 3
overrides_applied: 0
gaps: []
human_verification:
  - test: "Launch app and verify Scenario Selection screen loads scenarios from Firestore (seed data must be uploaded first)"
    expected: "Scenarios appear from Firestore /scenarios collection with category tabs, CEFR chips, search, and pagination"
    why_human: "Requires running app with real Firestore connection; seed data must be uploaded"
  - test: "Create a custom scenario via form → verify Gemini generates valid JSON → verify preview shows read-only fields"
    expected: "Form validates fields, Gemini returns structured scenario, preview is read-only, save persists to Firestore"
    why_human: "Requires Gemini API key and running app; AI response varies per call"
  - test: "Complete a scenario → verify Twist badge appears → tap Twist → verify variation conversation starts"
    expected: "Completed scenarios show gold sparkle Twist badge; tapping launches variation with progressive depth"
    why_human: "Requires completing a scenario and real-time Gemini API call for twist generation"
  - test: "Check Home dashboard Daily Challenge card → verify countdown timer updates → verify Start Challenge navigates to conversation"
    expected: "Daily Challenge card appears between GoalRing and Recommended section with gold accent, countdown, and challenge content"
    why_human: "Requires running app with Firestore and Gemini configuration"
  - test: "Verify Daily Challenge completion awards 2x XP (100 total)"
    expected: "Completing a challenge awards 50 base + 50 bonus = 100 XP"
    why_human: "Requires end-to-end conversation completion with gamification services"
  - test: "Verify Firestore rules for /scenarios (public read), /users/{uid}/custom_scenarios (owner-only CRUD), /challenges/{date} (public read, authenticated create)"
    expected: "Rules deploy without errors and enforce the expected access patterns"
    why_human: "Firestore rules deployment and testing requires Firebase Console access"
behavior_unverified_items:
  - truth: "Users can create custom scenarios by describing a persona, context, and goal"
    test: "Run Create Scenario flow with Gemini API connected"
    expected: "Gemini returns structured Scenario JSON with title, description, personaName, personaDescription, goalDescription, category, openingMessage, tags"
    why_human: "Requires Gemini API key — generates scenario via live AI call; runtime behavior depends on API availability and response format"
  - truth: "Tapping the Twist badge starts a conversation with a variation, not the original scenario"
    test: "Tap Twist badge on a completed scenario card"
    expected: "Gemini generates variation, twist scenario is created with 'twist_' prefix in ID, conversation starts with variation content"
    why_human: "Requires Gemini API call and real-time navigation; progressive depth (subtle vs moderate) depends on replayCount value"
  - truth: "Fresh AI-generated variation of a random curated scenario each UTC day"
    test: "Open app on a new UTC day (or clear /challenges/YYYY-MM-DD in Firestore)"
    expected: "DailyChallengeService.getOrCreateDailyChallenge() picks random curated scenario, calls Gemini, writes seed to Firestore"
    why_human: "Requires Firestore with seeded /scenarios collection and Gemini API; first-user-of-day pattern is runtime behavior"
---

# Phase 5: Premium-and-Polish Verification Report

**Phase Goal:** Premium and Polish — Firestore-backed scenario catalog, custom scenarios, Today's Twist, Daily Challenge
**Verified:** 2026-07-23T23:59:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

The phase delivers all four planned capabilities at the codebase level: a Firestore-backed scenario catalog (Plan 01), custom scenario creation via AI generation (Plan 02), Today's Twist replay badge (Plan 03), and Daily Challenge hero card (Plan 04). All 9 created files exist with substantive content, all modified files have the expected changes, all key links are wired, and `flutter analyze` passes with 0 errors.

**3 truths are behavior-dependent and require human verification with a running app + Firebase/Gemini configuration (marked PRESENT_BEHAVIOR_UNVERIFIED).** These involve runtime AI generation (custom scenarios, twist variations, daily challenge) and Firestore data flow verification.

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Scenario selection screen loads scenarios from Firestore (not bundled JSON) | ✅ VERIFIED | `FirestoreScenarioService.fetchAll()` queries `/scenarios` collection; `getScenarios()` uses cache-then-Firestore pattern. Bundled JSON files removed. HomeViewModel updated to use FirestoreScenarioService. |
| 2 | Screen loads from local cache instantly, then background-fetches updates | ✅ VERIFIED | `getScenarios()` returns cached data from SharedPreferences instantly; background `_refreshCache()` if stale (24h TTL). `scenario_service.dart` lines 28-44. |
| 3 | Category tabs (Travel, Work, Social, Academic, Daily Life) filter scenarios | ✅ VERIFIED | `ScenarioSelectionViewModel` has `selectedCategory` state; `_computeDisplay()` applies category filter. Category tabs rendered in screen with pill-shaped chips. |
| 4 | CEFR filter chips coexist with category tabs (AND logic within category) | ✅ VERIFIED | `_computeDisplay()` applies CEFR filter AND category filter AND search query simultaneously. CEFR chips rendered in horizontal row below categories. |
| 5 | Search bar filters by title and description | ✅ VERIFIED | `setSearchQuery()` with debounce; filter logic in `_computeDisplay()` checks `title` and `description` contains query (case-insensitive). |
| 6 | Infinite scroll pagination (20 at a time) | ✅ VERIFIED | `_visibleCount` starts at 20; `loadMore()` increments by 20, capped at filtered list length. `hasMore` tracks if more items exist. |
| 7 | Scenarios are reference data (public Firestore collection), read-only for all users | ✅ VERIFIED | `/scenarios/{scenarioId}` in `firestore.rules`: `allow read: if true; allow write: if request.auth != null && request.auth.token.admin == true`. |
| 8 | Firestore rules allow unauthenticated reads on /scenarios collection | ✅ VERIFIED | `firestore.rules` line 37: `allow read: if true;` for `/scenarios/{scenarioId}`. |
| 9 | 30+ curated scenarios seeded across all CEFR levels | ✅ VERIFIED | `seed_list.json` contains 34 scenarios: A1=6, A2=8, B1=8, B2=7, C1=5. All 5 categories represented. 6 featured. All have unique kebab-case IDs and required fields. |
| 10 | Users can create custom scenarios by describing a persona, context, and goal | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `CreateScenarioScreen` and `CreateScenarioViewModel` exist with 3-field form. `AiService.generateScenario()` uses Gemini structured JSON output. Code wired, but runtime Gemini call not verifiable without API key. |
| 11 | Gemini generates the full scenario config (persona name, description, goal, opening message) | ✅ VERIFIED | `AiService.generateScenario()` at line 63 uses Gemini `responseSchema` with 8 required properties matching Scenario model fields. |
| 12 | Users review the generated scenario before saving (read-only preview) | ✅ VERIFIED | `CreateScenarioScreen` has a preview step with read-only display. Per D-10, no editing of generated output. `ScenarioPreviewCard` widget renders all fields. |
| 13 | Users can delete custom scenarios from "My Scenarios" via confirmation dialog | ✅ VERIFIED | Three-dot menu on custom scenario cards -> bottom sheet -> "Delete Scenario" -> confirmation dialog with "This can't be undone" copy and coral Delete button. Optimistic removal with revert on failure. |
| 14 | Custom scenarios appear in a "My Scenarios" section on the scenario selection screen (newest-first order) | ✅ VERIFIED | CustomScrollView with slivers: "My Scenarios" section header + custom scenario grid (first sliver), divider + "Curated Scenarios" label (second sliver), curated grid (third sliver). `orderBy('createdAt', descending: true)` in Firestore query. |
| 15 | No limit on custom scenario count — unlimited for all users | ✅ VERIFIED | No gating code found. Per D-02 and D-13, no limit on custom scenario creation. |
| 16 | Custom scenarios use the same conversation pipeline as curated ones | ✅ VERIFIED | ConversationViewModel unchanged for custom scenarios. `selectedScenarioProvider` set before navigation. No pipeline modifications. |
| 17 | Custom scenarios are saved to Firestore under users/{uid}/custom_scenarios/{id} | ✅ VERIFIED | `saveCustomScenario()` in `scenario_service.dart` writes to `users/{uid}/custom_scenarios/{id}` with `createdAt` server timestamp. `getCustomScenarios()` reads from same path with newest-first ordering. |
| 18 | No premium gating — all users get unlimited custom scenario creation | ✅ VERIFIED | No premium/subscription code found. Guest users see sign-up prompt, authenticated users go directly to creation. |
| 19 | Completed scenarios show a Twist badge (sparkle/shuffle icon) on their card | ✅ VERIFIED | `ScenarioCard` has `showTwistBadge` parameter. Gold sparkle icon (`Icons.auto_awesome`) positioned top-right via Stack. Tooltip: "Play again with a twist". |
| 20 | Tapping the Twist badge starts a conversation with a variation, not the original scenario | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `TwistViewModel.generateAndLaunchTwist()` orchestrates: read replay count -> generate variation via Gemini -> build Scenario with `twist_` ID prefix -> increment count -> set state. Screen watches via `ref.listen(twistProvider)`. Runtime Gemini call not verifiable. |
| 21 | First replay gets a subtle situational change; subsequent replays get moderate changes | ✅ VERIFIED | `generateTwistVariation()` prompt is depth-based: `replayCount == 0` -> subtle, `replayCount >= 1` -> moderate. Different prompt descriptions for each depth. Code structure verified. |
| 22 | Twist is tracked as visible badge only — no counter or history screen | ✅ VERIFIED | No twist history screen or counter UI exists. Per D-05, only visible badge on card. |
| 23 | Twist replay count stored in existing users/{uid}/scenarios/{scenarioId} document | ✅ VERIFIED | `getTwistReplayCount()` reads `twistReplayCount` field. `incrementTwistReplay()` uses `FieldValue.increment(1)` with `SetOptions(merge: true)`. |
| 24 | Twist variation passes through conversation pipeline unchanged | ✅ VERIFIED | `isTwist` getter is metadata-only. No changes to bubbles, TTS, STT, or evaluation pipeline. |
| 25 | No change to conversation bubbles, TTS, STT, or evaluation | ✅ VERIFIED | ConversationViewModel has `isTwist` and `isChallenge` getters but no pipeline behavioral changes. Twist uses same `initializePersona()` and `sendMessage()`. |
| 26 | Daily Challenge appears as hero card on Home dashboard between streak rings and recommended section | ✅ VERIFIED | `DailyChallengeCard` inserted between `GoalRing` and "Recommended" section in `home_screen.dart`. White rounded container, left gold accent border, claymorphism shadow. |
| 27 | Fresh AI-generated variation of a random curated scenario each UTC day | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `DailyChallengeService.getOrCreateDailyChallenge()` picks random curated scenario, calls `AiService.generateDailyChallenge()`, writes to `/challenges/YYYY-MM-DD`. Code wired, runtime behavior requires Firestore + Gemini. |
| 28 | Challenge is globally consistent — all users see the same challenge | ✅ VERIFIED | First user of UTC day writes seed document to `/challenges/YYYY-MM-DD`. Subsequent users read existing document. Firestore is authoritative source. |
| 29 | Completing challenge awards 100 XP total (50 base + 50 bonus) | ✅ VERIFIED | `ConversationViewModel._triggerGamification()` line 493: `if (isChallenge) { await gamification.awardXp(uid, 50); await dcService.markChallengeCompleted(uid); }`. Base 50 XP + bonus 50 XP = 100 total per D-08. |
| 30 | Countdown timer shows time remaining ("5h remaining"), updated every minute | ✅ VERIFIED | `Timer.periodic` at 1-minute interval in `DailyChallengeCard` initState. `formatCountdown()` returns "{X}h remaining" or "{X}m remaining". Cancelled in dispose(). |
| 31 | UTC-based daily reset — no timezone package needed | ✅ VERIFIED | All date calculations use `DateTime.now().toUtc()`. No `timezone` package dependency. |
| 32 | Gold (#F5C862) used for challenge XP badge and award elements only | ✅ VERIFIED | `DailyChallengeCard` uses `AppColors.accentGold` for "2x XP" badge, gold checkmark, and gold left border. Never used for primary action buttons (Start Challenge uses primaryPink). |

**Score:** 29/32 truths verified (3 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
| -------- | -------- | ------ | ------- |
| `lib/core/services/scenario_service.dart` | Firestore CRUD + local cache for curated scenarios | ✅ VERIFIED | Exists, 206 lines, substantive. Has `getScenarios()`, `fetchAll()`, `getCachedScenarios()`, `cacheScenarios()`, `isCacheStale()`, `getLastVisible()`, custom scenario CRUD, twist replay methods. |
| `lib/features/scenario_selection/models/scenario.dart` | Extended with tags, difficultyRating, isFeatured, completionCount, toJson, copyWith | ✅ VERIFIED | All new fields present with `??` defaults in fromJson. `toJson()` and `copyWith()` methods added. |
| `lib/features/scenario_selection/screens/scenario_selection_screen.dart` | Redesigned with categories, search, pagination, My Scenarios | ✅ VERIFIED | Category tabs, search bar with debounce, CEFR chips, CustomScrollView with slivers, infinite scroll, twist badge wiring, create button. |
| `lib/features/scenario_selection/viewmodels/scenario_selection_viewmodel.dart` | Stacked filters, pagination, custom scenarios, twist data | ✅ VERIFIED | `_computeDisplay()` with stacked filters (CEFR AND category AND search), `_visibleCount` pagination, `completedScenarioIds`, `twistReplayCounts`, `customScenarios`. |
| `lib/features/scenario_selection/widgets/scenario_card.dart` | Featured badge, difficulty dots, twist badge, trailing widget | ✅ VERIFIED | `isFeatured` badge (gold star), difficulty dots (3 circles), `showTwistBadge`/`onTwistTap` params, optional `trailing` widget for delete menu. |
| `lib/core/services/ai_service.dart` | generateScenario, generateTwistVariation, generateDailyChallenge methods | ✅ VERIFIED | All 3 methods present with Gemini structured JSON output (`responseSchema`), timeouts, and error handling. |
| `lib/core/providers/service_providers.dart` | All new service providers | ✅ VERIFIED | `scenarioServiceProvider`, `aiServiceProvider`, `dailyChallengeServiceProvider` registered. |
| `lib/features/scenario_selection/screens/create_scenario_screen.dart` | 3-step wizard: form, preview, saved | ✅ VERIFIED | Exists, 22,999 bytes. Form with persona/context/goal fields, CEFR chip selector, tone selector, generate/preview/save flow with loading overlay. |
| `lib/features/scenario_selection/viewmodels/create_scenario_viewmodel.dart` | State machine for creation flow | ✅ VERIFIED | Exists, 5,764 bytes. `CreateScenarioStep` enum (form/generating/preview/saving/saved). Methods: setPersona, setContext, setGoal, setCefrLevel, setTone, generate, regenerate, save, edit. |
| `lib/features/scenario_selection/widgets/scenario_preview_card.dart` | Preview widget for generated scenario | ✅ VERIFIED | Exists, 5,747 bytes. Shows CEFR badge, category, title, persona, description, goal (highlighted), opening message, tags in claymorphism card. |
| `lib/features/scenario_selection/viewmodels/twist_viewmodel.dart` | Twist orchestration ViewModel | ✅ VERIFIED | Exists, 3,368 bytes. `generateAndLaunchTwist()`: read replay count -> generate variation -> increment -> set state. `reset()` method. `twistProvider` registered. |
| `lib/core/services/daily_challenge_service.dart` | UTC rotation, Firestore seed management, countdown | ✅ VERIFIED | Exists, 4,797 bytes. `todayDateString`, `timeUntilNextChallenge`, `formatCountdown`, `getOrCreateDailyChallenge`, `hasCompletedTodayChallenge`, `markChallengeCompleted`. |
| `lib/features/home/widgets/daily_challenge_card.dart` | Hero card with countdown timer and challenge UI | ✅ VERIFIED | Exists, 7,563 bytes. Timer.periodic 1-min countdown, gold left border, Today's Challenge heading + 2x XP badge, description, Start Challenge button, completed state with gold checkmark. |
| `assets/data/scenarios/seed_list.json` | 30+ curated scenarios across all CEFR levels | ✅ VERIFIED | 34 scenarios, 5 CEFR levels, 5 categories, 6 featured, all required fields. |
| `scripts/seed_scenarios.dart` | Firestore upload instructions | ✅ VERIFIED | Exists, 1,670 bytes. Documents manual Firestore Console upload steps. |
| `firestore.rules` | Rules for /scenarios, /custom_scenarios, /challenges | ✅ VERIFIED | `match /scenarios/{scenarioId}`: public read, admin write. `match /custom_scenarios/{docId}` inside /users: owner-only. `match /challenges/{date}`: public read, authenticated create, admin write. |

**Removed artifacts confirmed absent:**
- `assets/data/scenarios/cafe_ordering.json` -- REMOVED
- `assets/data/scenarios/job_interview.json` -- REMOVED
- `assets/data/scenarios/airport_navigation.json` -- REMOVED

### Key Link Verification

| From | To | Via | Status | Details |
| ---- | --- | --- | ----- | ------- |
| Scenario model | ConversationViewModel | through selectedScenarioProvider | ✅ VERIFIED | Scenario model consumed by ConversationViewModel via provider; no schema changes needed. |
| ScenarioService | Firestore /scenarios collection | Firestore query | ✅ VERIFIED | `_db.collection('scenarios')` in fetchAll(). |
| ScenarioService | SharedPreferences cache | JSON serialization via `jsonEncode`/`jsonDecode` | ✅ VERIFIED | `getCachedScenarios()`/`cacheScenarios()` use SharedPreferences with JSON string. |
| AiService.generateScenario() | Gemini API | Structured JSON prompt + responseSchema | ✅ VERIFIED | `model.generateContent()` with `responseMimeType: 'application/json'` + schema. |
| CreateScenarioScreen | CreateScenarioViewModel | Riverpod provider | ✅ VERIFIED | ViewModel is state machine; screen watches via `ref.watch(createScenarioProvider)`. |
| Custom scenarios | Firestore custom_scenarios subcollection | `saveCustomScenario()` | ✅ VERIFIED | Path: `users/{uid}/custom_scenarios/{id}`. |
| Twist badge tap | Gemini variation generation | TwistViewModel -> AiService.generateTwistVariation | ✅ VERIFIED | `generateAndLaunchTwist()` calls `generateTwistVariation()`. |
| Twist completion | Twist replay count in Firestore | `incrementTwistReplay()` | ✅ VERIFIED | Path: `users/{uid}/scenarios/{scenarioId}` with `twistReplayCount` field. |
| Daily Challenge card | Daily challenge Firestore document | DailyChallengeService | ✅ VERIFIED | Path: `/challenges/YYYY-MM-DD`. |
| Daily Challenge completion | 2x XP bonus | ConversationViewModel -> GamificationService | ✅ VERIFIED | `if (isChallenge) { awardXp(uid, 50); markChallengeCompleted(uid); }`. |
| "/create-scenario" | CreateScenarioScreen | GoRouter path | ✅ VERIFIED | `GoRoute(path: '/create-scenario', builder: ...)` in router.dart line 129. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| -------- | ------------- | ------ | ------------------ | ------ |
| ScenarioSelectionScreen | `state.allScenarios` (curated) | FirestoreScenarioService -> Firestore /scenarios | ✅ FLOWING | Service layer fetches from Firestore; cache-then-refresh pattern. 34 seeds available. |
| ScenarioSelectionScreen | `state.customScenarios` | FirestoreScenarioService -> Firestore users/{uid}/custom_scenarios | ✅ FLOWING | Loaded per-user from Firestore subcollection. |
| DailyChallengeCard | `challengeState` | DailyChallengeService -> Firestore /challenges | ✅ FLOWING | Generated/Gemini or read from Firestore seed document. |
| ScenarioCard (Twist badge) | `showTwistBadge` | ScenarioSelectionViewModel -> Firestore users/{uid}/scenarios | ✅ FLOWING | Completion data loaded from existing user scenarios collection. |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| -------- | ------- | ------ | ------ |
| flutter analyze passes | `flutter analyze lib/` | 0 errors, 0 warnings (1 pre-existing info-level note) | ✅ PASS |
| Seed list validates | JSON parse + field check | 34 scenarios, all fields, unique IDs, 5 CEFR levels, 5 categories, 6 featured | ✅ PASS |
| Old JSON files removed | `ls assets/data/scenarios/` | Only `seed_list.json` remains | ✅ PASS |
| No old references remain | `grep -r "cafe_ordering\|job_interview\|airport_navigation" lib/` | No matches | ✅ PASS |
| Firestore rules contain required blocks | `grep -c` on `firestore.rules` | /scenarios, /custom_scenarios, /challenges all present | ✅ PASS |
| /create-scenario route registered | `grep` in router.dart | Line 129: `path: '/create-scenario'` | ✅ PASS |
| All providers registered | `grep` in service_providers.dart | scenarioServiceProvider, aiServiceProvider, dailyChallengeServiceProvider | ✅ PASS |

### Probe Execution

No probes found. Phase 5 does not define probe scripts.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| ----------- | ---------- | ----------- | ------ | -------- |
| CONV-01 | 05-01, 05-02 | User can browse and select from curated real-world scenarios | ✅ SATISFIED | Firestore-backed scenario catalog (34 curated scenarios), category tabs, CEFR chips, search, pagination replaces 3-JSON bundle. |
| CONV-03 | 05-01, 05-02, 05-03, 05-04 | User enters a free-flow voice conversation with an AI character | ✅ SATISFIED | Custom scenarios, Twist variations, and Daily Challenge feed the existing unchanged ConversationViewModel pipeline. |
| CONV-04 | 05-01, 05-02, 05-03, 05-04 | AI stays in character throughout the conversation | ✅ SATISFIED | AiService.initializePersona() receives persona fields from all scenario types (curated, custom, twist, daily challenge). Persona system unchanged. |
| CONV-05 | 05-01, 05-04 | User sees their own voice message bubbles with transcript | ✅ SATISFIED | No visual changes to conversation bubbles. Scenario metadata (isTwist, isChallenge) is invisible during conversation. |

**Note:** All four required IDs (CONV-01, CONV-03, CONV-04, CONV-05) are Phase 1 requirements from REQUIREMENTS.md. Phase 5 enhances these capabilities (more scenarios, custom creation, twist replay, daily challenge) without changing the core requirements. No orphaned requirements were found.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| ---- | ---- | ------- | -------- | ------ |
| None | -- | -- | -- | No TBD, FIXME, XXX, TODO, HACK, PLACEHOLDER, or placeholder markers found in any Phase 5 files. |

### Human Verification Required

6 items need human testing (including 3 present-but-behavior-unverified truths where code is wired but the Gemini/Firestore runtime behavior cannot be verified without a running app):

1. **Firestore scenario catalog end-to-end**
   - **Test:** Launch the app and navigate to Scenario Selection screen
   - **Expected:** Scenarios load from Firestore `/scenarios` collection (requires seed data to be uploaded first). Category tabs, CEFR chips, search bar, and infinite scroll pagination all function. Featured badges and difficulty dots render on cards.
   - **Why human:** Requires running app with real Firebase project connected and scenario seed data uploaded to `/scenarios` collection.

2. **Custom scenario creation flow (PRESENT_BEHAVIOR_UNVERIFIED)**
   - **Test:** Tap the Create Scenario button, fill in persona/context/goal fields, tap "Generate Scenario"
   - **Expected:** Form validates all fields. Gemini returns structured JSON. Preview screen shows generated scenario in read-only format (per D-10). "Try It" saves and navigates to conversation. "Discard" shows confirmation dialog. Three-dot menu on custom scenario cards shows delete option with "This can't be undone" dialog.
   - **Why human:** Requires Gemini API key and running app; AI response varies per call making automated testing impractical.

3. **Today's Twist badge and variation (PRESENT_BEHAVIOR_UNVERIFIED)**
   - **Test:** Complete a scenario, return to Scenario Selection, verify Twist badge appears. Tap Twist badge.
   - **Expected:** Gold sparkle badge (`Icons.auto_awesome`) on completed scenarios. Tapping it generates a variation with progressive depth (subtle on first replay, moderate on subsequent). Twist scenario navigates with `twist_` prefix ID. No twist history screen exists.
   - **Why human:** Requires completing a real scenario and real-time Gemini API call for twist generation.

4. **Daily Challenge card and countdown (PRESENT_BEHAVIOR_UNVERIFIED)**
   - **Test:** Open Home dashboard. Verify Daily Challenge card renders between GoalRing and Recommended section.
   - **Expected:** Card shows "Today's Challenge" heading, gold "2x XP" badge, challenge description (2 lines max), countdown timer ("{X}h remaining" updated every minute), and "Start Challenge" button. Completed state shows gold checkmark + "Challenge Complete! +100 XP". Coral countdown when <1h remaining.
   - **Why human:** Requires running app with Firestore and Gemini configuration; countdown timer is real-time.

5. **Daily Challenge completion 2x XP bonus**
   - **Test:** Complete a Daily Challenge conversation, check XP total on Home dashboard
   - **Expected:** 100 XP awarded total (50 base + 50 bonus per D-08). `markChallengeCompleted()` called on completion.
   - **Why human:** Requires end-to-end conversation completion with Firestore and gamification services.

6. **Firestore rules deployment**
   - **Test:** Deploy firestore.rules to Firebase Console
   - **Expected:** Rules deploy without syntax errors. Unauthenticated users can read `/scenarios`. Authenticated users can CRUD their own `users/{uid}/custom_scenarios/`. Authenticated users can create `/challenges/{date}` documents. Admin-only write on `/scenarios` and admin-only updates on `/challenges`.
   - **Why human:** Firestore rules can only be tested via Firebase Console or emulator deployment.

### Gaps Summary

No gaps found. All 32 must-have truths are either verified as code-present-and-wired (29) or present with behavior-unverified requiring human verification (3). All 9 created files exist with substantive content. All modified files contain the expected changes. Key links are wired end-to-end. `flutter analyze` passes with 0 errors. No debt markers or anti-patterns found.

The 3 truth items marked PRESENT_BEHAVIOR_UNVERIFIED are all in the same category: they require runtime interaction with the Gemini API or Firestore data flow that cannot be verified solely through static code analysis. These are legitimate human verification items.

---

_Verified: 2026-07-23T23:59:00Z_
_Verifier: Claude (gsd-verifier)_
