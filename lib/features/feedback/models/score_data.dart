/// Represents the evaluation result for a completed conversation scenario.
class ScoreData {
  final int overallScore;
  final int fluencyScore;
  final int grammarScore;
  final int vocabularyScore;
  final List<GrammarCorrection> grammarCorrections;
  final int xpEarned;

  const ScoreData({
    required this.overallScore,
    required this.fluencyScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.grammarCorrections,
    required this.xpEarned,
  });

  /// Creates a [ScoreData] from a JSON map returned by Gemini structured output.
  factory ScoreData.fromJson(Map<String, dynamic> json) {
    final corrections = <GrammarCorrection>[];
    final rawCorrections = json['grammarCorrections'];
    if (rawCorrections is List) {
      for (final item in rawCorrections) {
        if (item is Map<String, dynamic>) {
          corrections.add(GrammarCorrection(
            original: item['original'] as String? ?? '',
            corrected: item['corrected'] as String? ?? '',
            explanation: item['explanation'] as String? ?? '',
          ));
        }
      }
    }

    return ScoreData(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      fluencyScore: (json['fluencyScore'] as num?)?.toInt() ?? 0,
      grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
      vocabularyScore: (json['vocabularyScore'] as num?)?.toInt() ?? 0,
      grammarCorrections: corrections,
      xpEarned: 10, // Flat rate per D-11 scope
    );
  }

  /// Fallback score data returned when evaluation fails.
  factory ScoreData.fallback() => const ScoreData(
        overallScore: 0,
        fluencyScore: 0,
        grammarScore: 0,
        vocabularyScore: 0,
        grammarCorrections: [],
        xpEarned: 0,
      );
}

/// A single grammar correction identified during evaluation.
class GrammarCorrection {
  final String original;
  final String corrected;
  final String explanation;

  const GrammarCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });
}
