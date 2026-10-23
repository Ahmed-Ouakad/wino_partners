import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_coordinate.dart';
import '../repositories/location_repository.dart';

class SaveLocationCoordinates {
  final LocationRepository repository;

  const SaveLocationCoordinates(this.repository);

  Future<Either<Failure, void>> call(
    LocationCoordinate coordinate, {
    String? street,
  }) async {
    return await repository.saveLocationCoordinates(coordinate, street: street);
  }
}
