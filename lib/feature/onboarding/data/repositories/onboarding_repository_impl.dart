import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/onboarding_params.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_data_source.dart';

/// Implementation of [OnboardingRepository] managing data layer operations for onboarding.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  const OnboardingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ServiceCategory>>> getServiceCategories() async {
    try {
      final categories = await remoteDataSource.getServiceCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> submitOnboarding(OnboardingParams params) async {
    try {
      await remoteDataSource.submitOnboarding(params);
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
