import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_coordinate.dart';
import '../repositories/location_repository.dart';

class SearchForCityCoordinates {
  final LocationRepository repository;

  const SearchForCityCoordinates(this.repository);

  Future<Either<Failure, LocationCoordinate>> call(String cityName) async {
    return await repository.searchForCityCoordinates(cityName);
  }
}
