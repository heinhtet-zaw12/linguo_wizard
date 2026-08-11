/// CEFR language-level profiles for the AI conversation engine.
///
/// Each profile defines the vocabulary, grammar, and style constraints the AI
/// must follow when speaking at that level — plus few-shot examples that anchor
/// the model to the correct register.
class CefrProfile {
  /// CEFR level code, e.g. "A1", "B2".
  final String level;

  /// Human-readable label shown in the UI.
  final String label;

  /// Maximum words the AI should use in a single sentence.
  final int maxSentenceWords;

  /// Maximum sentences per AI turn.
  final int maxSentences;

  /// Grammar rules the AI must obey at this level.
  final String grammarConstraints;

  /// Vocabulary constraints (word-list tier, topic restrictions).
  final String vocabularyGuide;

  /// Naturalness instructions specific to this level.
  final String styleGuide;

  /// 1-2 example exchanges demonstrating the correct register.
  final String fewShotExamples;

  const CefrProfile({
    required this.level,
    required this.label,
    required this.maxSentenceWords,
    required this.maxSentences,
    required this.grammarConstraints,
    required this.vocabularyGuide,
    required this.styleGuide,
    required this.fewShotExamples,
  });

  /// Builds the CEFR constraint block injected into every system prompt.
  String toPromptFragment() => '''
LANGUAGE CONSTRAINTS — CEFR $level ($label):

GRAMMAR:
$grammarConstraints

VOCABULARY:
$vocabularyGuide

SENTENCE STRUCTURE:
- Max $maxSentenceWords words per sentence
- Max $maxSentences sentences per reply
$styleGuide

EXAMPLES OF CORRECT $level REGISTER:
$fewShotExamples
''';

  /// Builds a short reminder injected on every user turn to prevent drift.
  String toTurnReminder() => '''
REMEMBER: You are speaking at CEFR $level ($label) level.
- Max $maxSentenceWords words per sentence, max $maxSentences sentences
- Only use $level-appropriate grammar and vocabulary
''';

  // ──────────────────────────────────────────────
  //  Static registry
  // ──────────────────────────────────────────────

  static const Map<String, CefrProfile> _profiles = {
    'A1': CefrProfile(
      level: 'A1',
      label: 'Beginner',
      maxSentenceWords: 8,
      maxSentences: 2,
      grammarConstraints: '''- Simple present only: "I am", "She has", "We go"
- Simple past for fixed phrases: "I want", "I need"
- Basic imperatives: "Give me", "Tell me"
- No conditionals, no passive voice, no relative clauses
- No auxiliary verbs (can't say "I don't have to")
- Use "is" and "are" for descriptions''',
      vocabularyGuide: '''- Only concrete, everyday nouns: food, family, numbers, colors, time, places
- Use basic verbs: be, have, do, go, want, like, eat, drink, need, make, take
- No abstract nouns (don't say "opportunity", say "chance" or "a way")
- No idiomatic expressions
- Pronouns: I, you, he, she, it, we, they
- Simple connectors: "and", "but", "because"''',
      styleGuide: '''- Sound like a real, friendly person — use contractions (I'm, don't, it's)
- Keep things warm and conversational, not robotic or textbook-like
- React naturally with simple words: "Oh!", "Okay!", "Nice!", "Hmm"
- Short and sweet — don't pad responses to sound smarter''',
      fewShotExamples: '''
User: I want coffee.
AI: Sure! What kind? We have latte or cappuccino.

User: Where is the bank?
AI: Go straight, then turn left. It's next to the pharmacy.

User: I like this song!
AI: Oh, nice! I like it too. What kind of music do you listen to?''',
    ),

    'A2': CefrProfile(
      level: 'A2',
      label: 'Elementary',
      maxSentenceWords: 12,
      maxSentences: 2,
      grammarConstraints: '''- Present simple, present continuous, past simple (regular + irregular)
- "going to" for plans: "I'm going to visit"
- Can/could for ability and polite requests: "Can I have...?", "Could you...?"
- Comparatives: "bigger", "more expensive"
- Superlatives: "the best", "the cheapest"
- Basic prepositions of time and place
- No conditionals, no present perfect, no passive''',
      vocabularyGuide: '''- Top 1500 frequency words — travel, food, family, work, hobbies
- Basic phrasal verbs: "look at", "pick up", "put on"
- Simple time expressions: "last week", "every day", "next month"
- Numbers up to 1000, dates, prices
- Basic adverbs: "always", "sometimes", "never", "usually"
- Simple connectors: "because", "but", "then", "so"''',
      styleGuide: '''- Sound like a real, friendly person — use contractions (I'm, don't, it's)
- React naturally: "Oh, really?", "That's cool!", "Hmm, I don't know"
- Vary sentence length — some short, some slightly longer
- Don't be afraid to use "um" or "let me think" occasionally''',
      fewShotExamples: '''
User: I want to go to the cinema tomorrow.
AI: Oh, nice! What movie do you want to see? I heard the new action film is good.

User: Can you help me find the hotel?
AI: Sure! What's the name of the hotel? Is it near here?

User: I'm learning English. It's difficult!
AI: I know it's hard, but you're doing well! How long have you been learning?''',
    ),

    'B1': CefrProfile(
      level: 'B1',
      label: 'Intermediate',
      maxSentenceWords: 15,
      maxSentences: 3,
      grammarConstraints: '''- Present perfect: "I have visited", "She has worked here for 2 years"
- First conditional: "If it rains, we'll stay inside"
- Passive voice (simple): "The hotel was built in 1990"
- Reported speech (simple): "He said that he liked it"
- Used to / would for past habits: "I used to play football"
- Past continuous: "I was walking when it started raining"
- Basic modal verbs: should, might, have to, used to''',
      vocabularyGuide: '''- Top 3000 frequency words — include abstract nouns: idea, opinion, experience, reason
- Phrasal verbs: "give up", "look forward to", "get along with"
- Linking words: "although", "however", "on the other hand"
- Time expressions: "recently", "lately", "so far", "at the moment"
- Expressing opinion: "I think", "In my opinion", "I believe"
- Degree adverbs: "quite", "rather", "fairly"''',
      styleGuide: '''- Sound natural and conversational, like a real friend
- Use hedging language: "I think", "maybe", "probably"
- Vary sentence length — mix short punchy sentences with longer ones
- React with genuine interest and emotion''',
      fewShotExamples: '''
User: I've been thinking about changing my job.
AI: Oh really? What kind of work are you interested in? Sometimes a change can be refreshing, even if it's a bit scary at first.

User: Have you been to London?
AI: I have, actually! I went last year. It was amazing — the museums are incredible, but everything's so expensive. Have you ever been?

User: If I don't get the job, what should I do?
AI: Well, first of all, don't panic. If you don't get this one, there'll be other opportunities. Maybe you could ask for feedback — that way you'll know what to improve.''',
    ),

    'B2': CefrProfile(
      level: 'B2',
      label: 'Upper-Intermediate',
      maxSentenceWords: 20,
      maxSentences: 4,
      grammarConstraints: '''- All conditionals (0, 1, 2, 3): "If I had known, I would have..."
- Passive voice (all tenses): "It has been widely reported that..."
- Reported speech (backshift): "She told me she had already left"
- Present perfect continuous: "I've been working here since 2020"
- Mixed conditionals: "If I had studied medicine, I'd be a doctor now"
- Cleft sentences: "What I really want is..."
- Relative clauses (defining and non-defining)
- Inversion for emphasis: "Not only did he arrive late, but..."''',
      vocabularyGuide: '''- Top 4500 frequency words — flexible with abstract and formal vocabulary
- Idiomatic expressions: "break the ice", "hit the nail on the head"
- Collocations: "make a decision", "do research", "strong coffee"
- Register shifts: casual vs. semi-formal
- Nuanced connectors: "nevertheless", "consequently", "in contrast"
- Hedging: "It seems that...", "This could suggest..."''',
      styleGuide: '''- Sound articulate but natural — like someone who's well-spoken in their own language
- Use discourse markers: "Well, actually...", "To be honest...", "I mean..."
- Blend formal and casual registers depending on context
- Show personality through word choice and humor''',
      fewShotExamples: '''
User: What do you think about remote work?
AI: Honestly, I think it's a game-changer. I mean, the flexibility is great, but I can see how some people might feel isolated. What about you — do you prefer working from home or going into an office?

User: I've been offered a position abroad, but I'm not sure I should take it.
AI: That's a big decision. On the one hand, living abroad is an incredible experience — you'd grow so much personally and professionally. On the other hand, leaving everything behind can be really tough. What specifically is holding you back?

User: If I had studied harder, I would have passed.
AI: Don't be too hard on yourself. The past is the past, and dwelling on "what ifs" doesn't really help. What matters is what you do next. Have you thought about retaking it?''',
    ),

    'C1': CefrProfile(
      level: 'C1',
      label: 'Advanced',
      maxSentenceWords: 25,
      maxSentences: 5,
      grammarConstraints: '''- Full command of all tenses and aspects including narrative tenses
- Advanced conditionals and hypotheticals: "Were I to suggest...", "Had they known..."
- Subjunctive mood: "If I were you, I'd..." / "It's essential that he be informed"
- Cleft and pseudo-cleft sentences for emphasis
- Advanced passive constructions including impersonal passive
- Ellipsis and substitution for conciseness
- Advanced inversion: "Rarely does one encounter...", "Not only... but also..."
- Discourse markers for sophisticated argumentation''',
      vocabularyGuide: '''- Full productive vocabulary — flexible with formal, informal, academic, colloquial
- Advanced collocations: "run the risk", "raise awareness", "draw a conclusion"
- Idiomatic and figurative language used naturally
- Register-aware: can shift between casual and professional in context
- Concessive clauses: "Despite the fact that...", "Notwithstanding..."
- Precise word choice: "argue" vs. "claim" vs. "assert" vs. "maintain"''',
      styleGuide: '''- Sound like a well-educated native speaker — articulate, nuanced, natural
- Use self-correction and reformulation: "Well, what I mean is..."
- Vary sentence structure freely — fragments, inversions, periodic sentences
- Show wit and personality — dry humor, irony when appropriate
- Never sound academic or essay-like — this is conversation, not writing''',
      fewShotExamples: '''
User: What's your take on the whole AI revolution?
AI: It's fascinating, isn't it? I mean, on the one hand there's all this potential — think about healthcare, education, climate research. But on the other, and this is where it gets tricky, we're essentially handing over decision-making to systems we don't fully understand. I'm cautiously optimistic, I suppose. What about you — are you more excited or more worried?

User: I've been working on this project for months and I'm starting to burn out.
AI: I hear you — burnout's insidious because it creeps up gradually. Have you considered stepping back, even just for a weekend? Sometimes a bit of distance is all it takes to recalibrate. And honestly, setting boundaries isn't a luxury — it's a necessity.

User: Don't you think it's unfair that some people have opportunities others don't?
AI: Of course — it's one of those uncomfortable truths that's hard to reconcile. What I will say is that acknowledging the imbalance is the first step. The real question isn't whether it's unfair — it obviously is — but what we do about it. Do you think individual action can make a difference, or does it really need systemic change?''',
    ),
  };

  /// Returns the profile for the given level, falling back to B1 if unknown.
  static CefrProfile forLevel(String level) {
    return _profiles[level.toUpperCase()] ?? _profiles['B1']!;
  }

  /// All supported CEFR levels.
  static List<String> get supportedLevels => _profiles.keys.toList();
}
