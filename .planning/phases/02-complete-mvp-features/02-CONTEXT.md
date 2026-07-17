# Phase 2: Complete MVP Features (onboarding, feedback, local storage) - Context

**Gathered:** 2026-07-18
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase delivers the remaining MVP features needed to complete the core user loop: onboarding flow for new users, goal progress tracking during conversations, post-conversation feedback and scoring, local guest-mode persistence, and server-side rate limiting. It does NOT include authentication, cloud sync, gamification (streaks/badges), or premium features — those belong in later phases.

</domain>

<decisions>
## Implementation Decisions

### Onboarding Flow Design
- **D-01:** Onboarding is a multi-step wizard with each selection on its own screen, using large illustrations in the claymorphism style. This matches the design theme and creates an immersive first-run experience.
- **D-02:** Step order is Language → CEFR Level → Goal. Starts with the most personal choice and progressively narrows down.
- **D-03:** Onboarding is required — no skip option. Ensures preferences are always set for personalized experience.
- **D-04:** After onboarding completes, user lands on the Scenario Selection screen filtered by their chosen CEFR level. Direct path to starting a conversation.
- **D-05:** Onboarding preferences are editable later via a settings/profile section in the app.

### Goal Progress & Evaluation
- **D-06:** Goal progress indicator is a thin top bar showing the scenario goal text (e.g., "Order your coffee"). Simple, non-intrusive, always visible during conversation.
- **D-07:** AI evaluates goal achievement at the end of conversation, not during. More accurate assessment from full context, simpler implementation.
- **D-08:** Goal evaluation returns a numeric score (0-100) with breakdown. Provides granular feedback for the score screen.
- **D-09:** User ends conversation manually via an "End conversation" button. Simple, user-controlled, triggers evaluation.

### Local Storage & Rate Limiting
- **D-10:** Local storage uses shared_preferences for guest-mode data. Simple key-value store, built into Flutter, sufficient for preferences.
- **D-11:** Only onboarding preferences are persisted locally (language, CEFR level, goal). Progress data and conversation history are NOT stored in this phase — that's a future phase scope.
- **D-12:** Onboarding preferences are saved after each wizard step. Ensures partial progress is never lost if app crashes.
- **D-13:** Daily AI call limit is 10 calls/day for guest users. Enough for 4-5 scenario practices, balanced for free tier.
- **D-14:** Guest users identified via device ID + IP hash. More robust against simple bypasses like clearing storage.

### Claude's Discretion
- AI prompt design for goal evaluation (how to structure the scoring prompt)
- Feedback screen layout details (specific arrangement of score, transcript, grammar corrections)
- Error handling UX for rate limit exceeded
- Onboarding screen visual design (specific illustrations, animations)
- Settings screen location and navigation pattern

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Architecture
- `CLAUDE.md` — Project brief, MVVM architecture, design style (3D Claymorphism), build phases
- `.planning/REQUIREMENTS.md` — All requirements with traceability (CONV-07, ONBD-01, ONBD-02, PLAT-02, PLAT-03)
- `.planning/STATE.md` — Current project state, Phase 1 completion notes

### Codebase Maps
- `.planning/codebase/ARCHITECTURE.md` — System overview, component responsibilities, MVVM flow
- `.planning/codebase/STRUCTURE.md` — Directory layout, naming conventions, where to add new code
- `.planning/codebase/CONVENTIONS.md` — Coding conventions and patterns
- `.planning/codebase/STACK.md` — Technology stack details

### Prior Phase Context
- No prior CONTEXT.md files exist (Phase 1 context not captured via discuss-phase)

No external specs — requirements fully captured in decisions above.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `LinguoWizardApp` (lib/main.dart): Root widget with theme and routing — onboarding screen needs to be added to route table
- `ScenarioSelectionScreen` (lib/features/scenario_selection/screens/): Already filters by CEFR — will receive pre-filtered scenarios from onboarding preferences
- `ConversationViewModel` (lib/features/conversation/viewmodels/): Voice loop state machine — goal progress indicator reads from this ViewModel's state
- `AppConfig` (lib/core/config/app_config.dart): Environment config — rate limiting config can live here

### Established Patterns
- MVVM with Riverpod: Views are pure UI, ViewModels own logic, Services wrap external packages
- Feature-first folder structure: Each feature owns views/, viewmodels/, models/
- Services in lib/core/services/: AiService, SttService, TtsService already exist
- StateNotifier for ViewModel state: ConversationViewModel, ScenarioSelectionViewModel follow this pattern

### Integration Points
- Route table in lib/main.dart: Add onboarding and feedback screens
- ScenarioSelectionScreen: Receives CEFR filter from onboarding preferences
- ConversationViewModel: Exposes goal progress state for top bar indicator
- AiService: Will be called for goal evaluation at conversation end

</code_context>

<specifics>
## Specific Ideas

- Onboarding wizard screens should use large claymorphism-style illustrations for each step
- Goal progress bar should be thin and non-intrusive — just text showing the scenario goal
- "End conversation" button should be clearly visible but not distracting during conversation
- Rate limit exceeded should show a friendly message, not a harsh error

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-complete-mvp-features*
*Context gathered: 2026-07-18*
