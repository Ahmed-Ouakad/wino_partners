import '../../domain/entities/city_suggestion.dart';
import '../../domain/entities/location_coordinate.dart';

abstract class LocationEvent {
  const LocationEvent();
}

class GetCurrentLocationEvent extends LocationEvent {}

class SearchCityEvent extends LocationEvent {
  final String cityName;

  const SearchCityEvent(this.cityName);
}

class SaveLocationEvent extends LocationEvent {
  final LocationCoordinate coordinate;
  final String? street;

  const SaveLocationEvent(this.coordinate, {this.street});
}

class UpdateLocationEvent extends LocationEvent {
  final LocationCoordinate coordinate;
  final String? street;
  final String addressId;

  const UpdateLocationEvent(
    this.coordinate, {
    this.street,
    required this.addressId,
  });
}

class GetSuggestionsEvent extends LocationEvent {
  final String query;

  const GetSuggestionsEvent(this.query);
}

class SelectSuggestionEvent extends LocationEvent {
  final CitySuggestion suggestion;

  const SelectSuggestionEvent(this.suggestion);
}

class CheckSavedLocationEvent extends LocationEvent {}
