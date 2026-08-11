# 🧙 Linguo Wizard

> Practice spoken English through simulated real-world dialogues with an AI conversation partner.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth+%7C+Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-004E8A?logo=dart&logoColor=white)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Testing](#testing)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)
- [Contact](#contact)

---

## About

Linguo Wizard is a mobile app that helps learners improve their spoken English by dropping them into simulated real-world conversations — ordering coffee, job interviews, travel situations, and more. An AI conversation partner responds in real-time using voice, so users practice speaking from session one.

The app adapts to your level (A1–C1 CEFR), tracks your progress with XP and streaks, and provides AI-powered feedback with grammar corrections after every conversation.

**100% free** — no paid APIs, no subscriptions. Voice I/O uses device-native STT/TTS, and conversations run on the Gemini free tier.

---

## How It Works

The core conversation loop runs entirely on-device for voice I/O, with Gemini handling only the AI responses:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User picks  │────▶│  AI sets the │────▶│  User speaks │
│  a scenario  │     │  scene (TTS) │     │  (mic input) │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Evaluation  │◀────│  AI responds │◀────│  STT trans-  │
│  & scoring   │     │  (Gemini)   │     │  cribes text │
└─────────────┘     └─────────────┘     └─────────────┘
```

1. **Scenario setup** — user selects a scenario (e.g., "ordering coffee"), which loads a system prompt describing the AI's persona and the conversation goal
2. **Conversation** — user speaks into the mic, `speech_to_text` transcribes the audio, the transcript is sent to Gemini, and the AI response is spoken back via `flutter_tts` with the text shown below the voice bubble
3. **Text-only mode** — toggle off voice for quiet environments; AI replies as text bubbles instead
4. **Turn limit** — after 20 turns (configurable), the user is prompted to end the conversation
5. **Evaluation** — Gemini scores the conversation on fluency, grammar, and vocabulary, and returns grammar corrections with explanations
6. **Progress** — XP is awarded, streaks update, and missed phrases are queued for spaced repetition review

Guest users get 10 AI calls per day (device-based rate limit). Authenticated users share the same cap but tracked via Firestore.

---

## Features

| Feature | Description |
|---|---|
| 🎤 **Voice Conversations** | Speak naturally — the AI listens and responds with voice, just like a real conversation partner |
| 📱 **Text-Only Mode** | Toggle off voice — AI replies as text bubbles for quiet environments or accessibility needs |
| 🌍 **Real-World Scenarios** | Curated scenarios: ordering food, job interviews, doctor visits, travel, networking, and more |
| 📊 **CEFR Level Adaptation** | Filter scenarios by level (A1–C1) and receive AI prompts tuned to your proficiency |
| 📝 **AI Feedback & Scoring** | After each conversation, get scored on fluency, grammar, and vocabulary with detailed corrections |
| 🏆 **XP & Streaks** | Earn XP per scenario, maintain daily streaks, and unlock badges |
| 🔁 **Spaced Repetition (SRS)** | Previously missed phrases resurface in later scenarios so you actually learn from mistakes |
| 🏅 **Badges & Leaderboard** | Unlock achievement badges and compete on the leaderboard |
| 🎯 **Daily Challenge** | Fresh AI-generated scenario every day with 2× XP bonus |
| 👤 **Profile & Progress** | Track your journey with a personal dashboard showing stats, history, and improvement over time |
| 🔐 **Auth Options** | Sign up with email, Google, or continue as a guest — guest progress migrates cleanly on signup |
| 🚫 **Rate Limiting** | Server-side daily AI call limits prevent abuse (10 calls/day for guests) |
| 🌑 **Dark Theme** | Full dark mode with glassmorphism UI — semi-transparent cards, neon glow accents, mesh gradient backgrounds |

---

## Screenshots

<!-- Add screenshots here once available -->
<!-- ![Home Screen](docs/screenshots/home.png) -->
<!-- ![Conversation](docs/screenshots/conversation.png) -->
<!-- ![Feedback](docs/screenshots/feedback.png) -->

> Screenshots coming soon. The app features a futuristic dark theme with glassmorphism cards, neon glow accents, and mesh gradient backgrounds.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x, Dart 3.10 |
| **State Management** | Riverpod 2.x |
| **Routing** | go_router 17.x |
| **Backend** | Firebase (Auth + Cloud Firestore) |
| **AI Engine** | Google Gemini (`gemini-3.1-flash-lite` via `google_generative_ai`) |
| **Voice Input** | `speech_to_text` (device-native STT) |
| **Voice Output** | `flutter_tts` (device-native TTS) |
| **Auth** | `firebase_auth`, `google_sign_in` (email + Google sign-in) |
| **Local Storage** | `shared_preferences`, `path_provider` |
| **Device ID** | `device_info_plus` (for guest rate limiting) |
| **Config** | `flutter_dotenv` (API keys loaded from `.env`) |
| **Animations** | `flutter_animate`, `confetti` |
| **Fonts** | `google_fonts` |
| **Design** | Futuristic dark theme — glassmorphism, neon glow, mesh gradients |

---

## Architecture

**Pattern:** MVVM (Model-View-ViewModel) + Feature-first folder structure.

```
lib/
├── core/                        # Shared infrastructure
│   ├── config/                  # App config, Firebase options, CEFR profiles
│   ├── models/                  # Cross-feature data classes (Badge, SrsItem, StreakData)
│   ├── providers/               # Global Riverpod providers (auth, services)
│   ├── services/                # AI, Auth, Firestore, TTS, STT, evaluation, SRS, rate limiting
│   ├── theme/                   # Design tokens (colors, dimensions, gradients, shadows, text styles)
│   └── widgets/                 # Reusable UI components (buttons, cards, chips, nav bar)
│
└── features/                    # Feature modules — each owns its own models/viewmodels/screens/widgets
    ├── auth/                    # Login, signup, forgot password
    ├── badge/                   # Badge popup widgets
    ├── conversation/            # Core voice conversation loop (incl. text-only mode)
    ├── feedback/                # Post-conversation scoring & grammar corrections
    ├── home/                    # Dashboard (streak, goals, scenario cards, daily challenge)
    ├── leaderboard/             # Leaderboard screen & viewmodel
    ├── navigation/              # Router config & scaffold with bottom nav
    ├── onboarding/              # First-run setup (language, CEFR level, goals)
    ├── profile/                 # User profile screen
    ├── progress/                # Progress tracking (badges, levels, mistakes)
    ├── scenario_selection/      # Browse & filter scenarios by CEFR level
    ├── splash/                  # App splash/loading screen
    └── srs/                     # Spaced repetition review sessions
```

### Layer Rules

- **Screens** (Views) → Never call services directly. Go through the ViewModel.
- **ViewModels** → Business logic + state machine. Extend `StateNotifier`. Never import widgets.
- **Models** → Plain Dart classes. No framework dependencies.
- **Services** → Stateless wrappers around packages. Injected into ViewModels.

For full architectural details, see [`CLAUDE.md`](CLAUDE.md).

### Firestore Schema

All user data lives under `users/{userId}`, with owner-only access enforced by Security Rules:

```
users/{userId}                        # Profile, streak, XP, display name
├── rateLimits/{date}                 # Daily call counters (10/day cap)
├── conversations/{conversationId}    # Scenario ID, transcript, scores
├── badges/{badgeId}                  # Earned badge metadata
├── srs_items/{itemId}                # Spaced repetition queue (missed phrases)
├── mistakes/{mistakeId}             # Grammar mistake records
└── custom_scenarios/{scenarioId}    # User-created scenarios (Phase 5+)

scenarios/{scenarioId}                # Public curated catalog (read: all, write: admin only)
challenges/{date}                     # Daily challenge definitions (read: all, write: admin only)
```

Security Rules enforce three access patterns:
- **Authenticated users** → read/write only their own `users/{userId}` subcollections
- **Public catalog** → `scenarios/` and `challenges/` are readable by anyone
- **Admin writes** → only users with an `admin` flag on their auth token can write to public collections

---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.x (with Dart 3.10+) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Firebase CLI** — `npm install -g firebase-tools`
- **FlutterFire CLI** — `dart pub global activate flutterfire_cli`
- A **Firebase project** with Auth and Firestore enabled
- A **Gemini API key** — [Get one free](https://aistudio.google.com/apikey)

### Installation

1. **Clone the repo:**
   ```bash
   git clone https://github.com/heinhtet-zaw12/linguo_wizard.git
   cd linguo_wizard
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   Create a `.env` file in the project root:
   ```bash
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   > ⚠️ The `.env` file is gitignored. Never commit API keys.

4. **Generate Firebase config** (required — secrets are gitignored):
   ```bash
   flutterfire configure
   ```
   This creates `lib/core/config/firebase_options.dart` with your Firebase project keys.

5. **Run the app:**
   ```bash
   flutter run
   ```

---

## Configuration

| Variable | Description | Where to set |
|---|---|---|
| `GEMINI_API_KEY` | Google Gemini API key for AI conversations | `.env` file in project root |
| `firebase_options.dart` | Firebase project config (auto-generated) | Generated by `flutterfire configure` |

### Key Constants (`lib/core/config/app_config.dart`)

| Constant | Default | Description |
|---|---|---|
| `geminiModel` | `gemini-3.1-flash-lite` | Gemini model used for conversations |
| `maxConversationTurns` | `20` | Max turns before prompting to end |
| `sttListenTimeout` | `30s` | Max STT listening duration |
| `sttPauseTimeout` | `60s` | Safety-net silence timeout before auto-stopping mic |
| `rateLimitEnabled` | `true` | Toggle daily rate limiting (must be `true` in production) |
| `maxDailyCalls` | `10` | Max AI calls/day for guests |
| `xpPerScenario` | `50` | XP earned per completed scenario |

---

## Testing

Tests live in the `test/` directory and cover models and viewmodels:

```bash
flutter test
```

### Test Structure

```
test/
├── models/
│   ├── message_test.dart
│   ├── onboarding_data_test.dart
│   └── score_data_test.dart
├── viewmodels/
│   ├── feedback_viewmodel_test.dart
│   ├── onboarding_viewmodel_test.dart
│   └── scenario_selection_test.dart
└── widget_test.dart
```

---

## Contributing

Contributions are welcome! To get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- Code follows the MVVM architecture rules (see [Architecture](#architecture))
- New features include corresponding tests
- `flutter analyze` passes with no issues
- Commits are descriptive and focused

---

## Security

This project has undergone a security audit. Key measures:

- **Server-side rate limiting** enforced via Firebase Security Rules (owner-only access to user subcollections)
- **API keys loaded from `.env`** via `flutter_dotenv` — never bundled in compiled app binaries
- **Firestore rules** restrict all user data to authenticated owner-only reads/writes
- **Input sanitization** on user-generated content (display names, chat messages)

For full details on security fixes and production deployment requirements, see [`SECURITY.md`](SECURITY.md).

> **Production note:** For production deployments, proxy Gemini API calls through Firebase Cloud Functions to keep the API key server-side. See `SECURITY.md` for the recommended Cloud Function implementation.

---

## License

This project is licensed under the MIT License.

---

## Contact

**Heinhtet Zaw** — [GitHub](https://github.com/heinhtet-zaw12)

Project Link: [https://github.com/heinhtet-zaw12/linguo_wizard](https://github.com/heinhtet-zaw12/linguo_wizard)
