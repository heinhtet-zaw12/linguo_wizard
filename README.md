# Linguo Wizard

Conversational English learning app — practice spoken English through simulated real-world dialogues with an AI conversation partner.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase CLI (`npm install -g firebase-tools`)
- Firebase account

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/heinhtet-zaw12/linguo_wizard.git
   cd linguo_wizard
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Firebase config (required — secrets are gitignored):
   ```bash
   flutterfire configure
   ```
   This creates `lib/core/config/firebase_options.dart` with your Firebase project keys.

4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

MVVM + Feature-first structure. See `CLAUDE.md` for full details.

## Tech Stack

- Flutter + Riverpod (state management)
- Firebase (Auth, Firestore)
- Gemini API (AI conversation)
- speech_to_text / flutter_tts (voice I/O)
