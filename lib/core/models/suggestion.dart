class Suggestion {
  final String placeId;
  final String description;

  const Suggestion({required this.placeId, required this.description});

  factory Suggestion.fromMap(Map<String, dynamic> parsedJson) {
    return Suggestion(
      placeId: parsedJson['place_id'] as String,
      description: parsedJson['description'] as String,
    );
  }

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
