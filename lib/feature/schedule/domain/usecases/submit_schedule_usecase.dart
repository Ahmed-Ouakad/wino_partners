import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/day_schedule.dart';
import '../repositories/schedule_repository.dart';

/// Parameters for submitting store schedule.
class SubmitScheduleParams extends Equatable {
  final String serviceId;
  final List<DaySchedule> schedules;

  const SubmitScheduleParams({
    required this.serviceId,
    required this.schedules,
  });

  @override
  List<Object?> get props => [serviceId, schedules];
}

/// Use case to submit vendor availability days to the backend.
class SubmitScheduleUseCase {
  final ScheduleRepository repository;

  const SubmitScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(SubmitScheduleParams params) async {
    return await repository.submitSchedule(
      serviceId: params.serviceId,
      schedules: params.schedules,
    );
  }
}
