import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_vendor_params.dart';
import '../entities/register_vendor_params.dart';

/// Contract for authentication operations in the domain layer.
abstract class AuthRepository {
  /// Registers a vendor using [params].
  ///
  /// Returns [Right(void)] on successful registration,
  /// or [Left(Failure)] if registration encounters an error.
  Future<Either<Failure, void>> registerVendor(RegisterVendorParams params);

  /// Authenticates a vendor using [params].
  ///
  /// Returns [Right(void)] on successful login (or token if configured),
  /// or [Left(Failure)] if login encounters an error.
  Future<Either<Failure, void>> loginVendor(LoginVendorParams params);
}
