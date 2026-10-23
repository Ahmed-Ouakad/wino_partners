/// Domain entity representing a city or place search autocomplete suggestion.
class CitySuggestion {
  final String name;
  final double latitude;
  final double longitude;

  const CitySuggestion({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitySuggestion &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'CitySuggestion(name: $name, lat: $latitude, lon: $longitude)';
}
