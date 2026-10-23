import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/login_vendor_params.dart';
import '../entities/register_vendor_params.dart';

/// Contract for authentication operations in the domain layer.
abstract class AuthRepository {
  /// Registers a vendor using [params].
  ///
  /// Returns [Right(AuthResponse)] on successful registration containing tokens and hasService flag,
  /// or [Left(Failure)] if registration encounters an error.
  Future<Either<Failure, AuthResponse>> registerVendor(RegisterVendorParams params);

  /// Authenticates a vendor using [params].
  ///
  /// Returns [Right(AuthResponse)] on successful login containing tokens and hasService flag,
  /// or [Left(Failure)] if login encounters an error.
  Future<Either<Failure, AuthResponse>> loginVendor(LoginVendorParams params);
}
