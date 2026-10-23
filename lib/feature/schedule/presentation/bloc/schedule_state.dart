import 'package:equatable/equatable.dart';
import '../../domain/entities/day_schedule.dart';

class ScheduleState extends Equatable {
  final List<DaySchedule> schedules;
  final bool sameScheduleEveryDay;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const ScheduleState({
    required this.schedules,
    this.sameScheduleEveryDay = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ScheduleState copyWith({
    List<DaySchedule>? schedules,
    bool? sameScheduleEveryDay,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      sameScheduleEveryDay: sameScheduleEveryDay ?? this.sameScheduleEveryDay,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        schedules,
        sameScheduleEveryDay,
        isSubmitting,
        isSuccess,
        errorMessage,
      ];
}
