import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_schedule.dart';
import '../repositories/schedule_repository.dart';

/// Parameters for updating store schedule.
class UpdateScheduleParams extends Equatable {
  final String serviceId;
  final List<DaySchedule> schedules;

  const UpdateScheduleParams({
    required this.serviceId,
    required this.schedules,
  });

  @override
  List<Object?> get props => [serviceId, schedules];
}

/// Use case to update vendor availability days using PUT /v1/vendor/services/{serviceId}/availability.
class UpdateScheduleUseCase {
  final ScheduleRepository repository;

  const UpdateScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(UpdateScheduleParams params) async {
    return await repository.updateSchedule(
      serviceId: params.serviceId,
      schedules: params.schedules,
    );
  }
}
