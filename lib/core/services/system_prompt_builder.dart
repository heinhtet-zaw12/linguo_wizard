import '../config/cefr_profile.dart';

/// Assembles the three-layer system prompt for Gemini conversations:
/// persona + CEFR constraints + scenario context.
///
/// Also provides the per-turn reminder that prevents mid-conversation
/// register drift.
class SystemPromptBuilder {
  const SystemPromptBuilder._();

  // ──────────────────────────────────────────────
  //  System instruction (set once at session start)
  // ──────────────────────────────────────────────

  /// Builds the full system instruction passed to [GenerativeModel].
  ///
  /// This is the initial prompt — stable across the entire chat session.
  static String buildSystemInstruction({
    required String personaName,
    required String personaDescription,
    required String scenarioGoal,
    required String cefrLevel,
  }) {
    final cefr = CefrProfile.forLevel(cefrLevel);

    return _personaLayer(
      personaName: personaName,
      personaDescription: personaDescription,
      scenarioGoal: scenarioGoal,
      cefrProfile: cefr,
    );
  }

  /// The stable persona layer — defines who the AI is and how it behaves.
  static String _personaLayer({
    required String personaName,
    required String personaDescription,
    required String scenarioGoal,
    required CefrProfile cefrProfile,
  }) {
    return '''
You are $personaName. $personaDescription

Your goal in this conversation: $scenarioGoal.

PERSONALITY & STYLE:
- You are a real person having a natural conversation — not a teacher, not an AI assistant.
- Use contractions naturally (I'm, don't, it's, we've).
- React with genuine emotion — surprise, agreement, curiosity, amusement.
- Use natural fillers when appropriate: "hmm", "oh", "well", "let me think".
- Vary your sentence length — some short and punchy, some longer.
- Ask follow-up questions to keep the conversation flowing.
- If the user makes a grammar mistake, gently correct it naturally within the conversation — never break character or lecture.

${cefrProfile.toPromptFragment()}
''';
  }

  // ──────────────────────────────────────────────
  //  Per-turn reminder (injected into user messages)
  // ──────────────────────────────────────────────

  /// Builds the reminder message injected into every user turn.
  ///
  /// Gemini's chat API doesn't support updating the system instruction mid-session,
  /// so we prepend this reminder to each user message to keep the CEFR constraint
  /// top-of-mind and prevent register drift as context grows.
  static String buildTurnReminder({required String cefrLevel}) {
    final cefr = CefrProfile.forLevel(cefrLevel);
    return cefr.toTurnReminder();
  }

  /// Wraps a user's spoken transcript with the per-turn CEFR reminder.
  ///
  /// The reminder is placed *after* the user text so the model processes the
  /// actual content first, then sees the constraint as a final nudge.
  static String wrapUserMessage({
    required String userText,
    required String cefrLevel,
    required int turnCount,
  }) {
    final reminder = buildTurnReminder(cefrLevel: cefrLevel);

    // Only add the reminder every N turns to reduce token overhead.
    // First 3 turns: always remind (model is still calibrating).
    // After that: every 3rd turn.
    final shouldRemind = turnCount <= 3 || (turnCount % 3 == 0);

    if (!shouldRemind) return userText;

    return '$userText\n\n---\n$reminder';
  }
}
