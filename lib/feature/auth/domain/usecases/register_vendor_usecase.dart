import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_vendor_params.dart';
import '../repositories/auth_repository.dart';

/// Use case responsible for executing vendor registration business logic.
class RegisterVendorUseCase {
  final AuthRepository repository;

  const RegisterVendorUseCase(this.repository);

  /// Executes the vendor registration.
  Future<Either<Failure, void>> call(RegisterVendorParams params) async {
    return await repository.registerVendor(params);
  }
}
