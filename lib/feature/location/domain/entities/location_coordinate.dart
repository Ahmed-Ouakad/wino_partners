/// Domain entity representing geographical coordinates.
class LocationCoordinate {
  final double latitude;
  final double longitude;

  const LocationCoordinate({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoordinate &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LocationCoordinate(lat: $latitude, lon: $longitude)';
}
