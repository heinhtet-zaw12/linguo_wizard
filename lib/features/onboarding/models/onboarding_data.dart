/// User selections from the onboarding flow.
class OnboardingData {
  final String targetLanguage;
  final String cefrLevel;
  final String goal;

  const OnboardingData({
    required this.targetLanguage,
    required this.cefrLevel,
    required this.goal,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      targetLanguage: json['targetLanguage'] as String? ?? 'English',
      cefrLevel: json['cefrLevel'] as String? ?? 'A1',
      goal: json['goal'] as String? ?? 'Travel',
    );
  }

  Map<String, dynamic> toJson() => {
        'targetLanguage': targetLanguage,
        'cefrLevel': cefrLevel,
        'goal': goal,
      };
}

// ─── Preset options ───

const List<MapEntry<String, String>> kLanguages = [
  MapEntry('🇺🇸', 'English'),
  MapEntry('🇪🇸', 'Spanish'),
  MapEntry('🇫🇷', 'French'),
  MapEntry('🇯🇵', 'Japanese'),
  MapEntry('🇰🇷', 'Korean'),
  MapEntry('🇨🇳', 'Mandarin'),
];

const List<String> kCefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1'];

const List<MapEntry<String, String>> kGoals = [
  MapEntry('✈️', 'Travel'),
  MapEntry('💼', 'Work'),
  MapEntry('📝', 'Exam'),
  MapEntry('💬', 'Casual'),
];
