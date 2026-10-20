import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/secure_caching_service.dart';
import '../../domain/entities/login_vendor_params.dart';
import '../../domain/entities/register_vendor_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_vendor_model.dart';
import '../models/register_vendor_model.dart';

/// Implementation of [AuthRepository] managing data layer operations for authentication.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureCachingService secureCachingService;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureCachingService,
  });

  @override
  Future<Either<Failure, void>> registerVendor(RegisterVendorParams params) async {
    try {
      final model = RegisterVendorModel.fromParams(params);
      await remoteDataSource.registerVendor(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> loginVendor(LoginVendorParams params) async {
    try {
      final model = LoginVendorModel.fromParams(params);
      final tokens = await remoteDataSource.loginVendor(model);
      final accessToken = tokens['access_token'] ?? '';
      final refreshToken = tokens['refresh_token'] ?? '';

      if (accessToken.isNotEmpty || refreshToken.isNotEmpty) {
        await secureCachingService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
