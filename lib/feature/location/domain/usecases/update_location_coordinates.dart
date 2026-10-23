import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_coordinate.dart';
import '../repositories/location_repository.dart';

class UpdateLocationCoordinates {
  final LocationRepository repository;

  const UpdateLocationCoordinates(this.repository);

  Future<Either<Failure, void>> call(
    LocationCoordinate locationCoordinate, {
    String? street,
    required String addressId,
  }) async {
    return await repository.updateLocationCoordinates(
      locationCoordinate,
      street: street,
      addressId: addressId,
    );
  }
}
