import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/day_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';

/// Implementation of [ScheduleRepository] managing schedule submission.
class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> submitSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    try {
      await remoteDataSource.submitFullSchedule(
        serviceId: serviceId,
        schedules: schedules,
      );
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
  Future<Either<Failure, void>> updateSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    try {
      await remoteDataSource.updateFullSchedule(
        serviceId: serviceId,
        schedules: schedules,
      );
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
