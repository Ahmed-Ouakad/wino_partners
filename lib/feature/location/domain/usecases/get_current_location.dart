import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_coordinate.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  const GetCurrentLocation(this.repository);

  Future<Either<Failure, LocationCoordinate>> call() async {
    return await repository.getCurrentLocation();
  }
}
