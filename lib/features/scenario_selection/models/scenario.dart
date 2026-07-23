/// A curated conversation scenario with persona and goal details.
class Scenario {
  final String id;
  final String title;
  final String description;
  final String personaName;
  final String personaDescription;
  final String goalDescription;
  final String cefrLevel;
  final String category;
  final String openingMessage;
  final List<String> tags;
  final int difficultyRating;
  final bool isFeatured;
  final int completionCount;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.personaName,
    required this.personaDescription,
    required this.goalDescription,
    required this.cefrLevel,
    required this.category,
    required this.openingMessage,
    this.tags = const [],
    this.difficultyRating = 3,
    this.isFeatured = false,
    this.completionCount = 0,
  });

  /// Deserializes a [Scenario] from a JSON map.
  ///
  /// All new fields use safe defaults (??) so old JSON and Firestore documents
  /// without these fields still deserialize correctly.
  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      personaName: json['personaName'] as String,
      personaDescription: json['personaDescription'] as String,
      goalDescription: json['goalDescription'] as String,
      cefrLevel: json['cefrLevel'] as String,
      category: json['category'] as String,
      openingMessage: json['openingMessage'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      difficultyRating: json['difficultyRating'] as int? ?? 3,
      isFeatured: json['isFeatured'] as bool? ?? false,
      completionCount: json['completionCount'] as int? ?? 0,
    );
  }

  /// Serializes this [Scenario] to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'personaName': personaName,
        'personaDescription': personaDescription,
        'goalDescription': goalDescription,
        'cefrLevel': cefrLevel,
        'category': category,
        'openingMessage': openingMessage,
        'tags': tags,
        'difficultyRating': difficultyRating,
        'isFeatured': isFeatured,
        'completionCount': completionCount,
      };

  /// Creates a copy of this [Scenario] with the given fields replaced.
  Scenario copyWith({
    String? id,
    String? title,
    String? description,
    String? personaName,
    String? personaDescription,
    String? goalDescription,
    String? cefrLevel,
    String? category,
    String? openingMessage,
    List<String>? tags,
    int? difficultyRating,
    bool? isFeatured,
    int? completionCount,
  }) {
    return Scenario(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      personaName: personaName ?? this.personaName,
      personaDescription: personaDescription ?? this.personaDescription,
      goalDescription: goalDescription ?? this.goalDescription,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      category: category ?? this.category,
      openingMessage: openingMessage ?? this.openingMessage,
      tags: tags ?? this.tags,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      isFeatured: isFeatured ?? this.isFeatured,
      completionCount: completionCount ?? this.completionCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scenario && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
