import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_schedule.dart';

/// Contract for schedule and store availability operations.
abstract class ScheduleRepository {
  /// Submits the active operating schedule days for a specific [serviceId] to the backend.
  Future<Either<Failure, void>> submitSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  });

  /// Updates all operating schedule days for a specific [serviceId] via PUT array.
  Future<Either<Failure, void>> updateSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  });
}
