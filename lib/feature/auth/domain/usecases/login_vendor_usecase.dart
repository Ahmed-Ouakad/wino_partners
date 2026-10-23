import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/login_vendor_params.dart';
import '../repositories/auth_repository.dart';

/// Use case responsible for executing vendor login business logic.
class LoginVendorUseCase {
  final AuthRepository repository;

  const LoginVendorUseCase(this.repository);

  /// Executes the vendor authentication.
  Future<Either<Failure, AuthResponse>> call(LoginVendorParams params) async {
    return await repository.loginVendor(params);
  }
}
