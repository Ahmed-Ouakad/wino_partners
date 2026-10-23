import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/city_suggestion.dart';
import '../entities/location_coordinate.dart';

/// Contract for location operations in the domain layer.
abstract class LocationRepository {
  Future<Either<Failure, LocationCoordinate>> getCurrentLocation();
  Future<Either<Failure, LocationCoordinate>> searchForCityCoordinates(String cityName);
  Future<Either<Failure, void>> saveLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    String? street,
  });
  Future<Either<Failure, void>> updateLocationCoordinates(
    LocationCoordinate locationCoordinate, {
    String? street,
    required String addressId,
  });
  Future<Either<Failure, List<CitySuggestion>>> getCitySuggestions(String query);
  Future<Either<Failure, LocationCoordinate>> getSavedLocationCoordinates();
}
