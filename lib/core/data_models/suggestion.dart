class Suggestion {
  final String placeId;
  final String description;

  const Suggestion({required this.placeId, required this.description});

  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      placeId: map['place_id'] as String,
      description: map['description'] as String,
    );
  }

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
