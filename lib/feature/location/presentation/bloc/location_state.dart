import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/location_coordinate.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationCoordinate coordinate;

  const LocationLoaded(this.coordinate);
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);
}

class LocationSaved extends LocationState {}

class LocationSuggestionsLoaded extends LocationState {
  final List<CitySuggestion> suggestions;

  const LocationSuggestionsLoaded(this.suggestions);
}

class LocationCheckEmpty extends LocationState {}

class LocationCheckSuccess extends LocationState {}
