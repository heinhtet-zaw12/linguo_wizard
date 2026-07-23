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
  });

  /// Deserializes a [Scenario] from a JSON map.
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scenario && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
