import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Toggles whether all open days should synchronize to the same hours.
class ToggleSameScheduleEveryDayEvent extends ScheduleEvent {
  final bool value;

  const ToggleSameScheduleEveryDayEvent(this.value);

  @override
  List<Object?> get props => [value];
}

/// Toggles whether a specific day is open or closed.
class ToggleDayEvent extends ScheduleEvent {
  final String dayCode;
  final bool isOpen;

  const ToggleDayEvent({
    required this.dayCode,
    required this.isOpen,
  });

  @override
  List<Object?> get props => [dayCode, isOpen];
}

/// Updates the open or close time for a day.
class UpdateTimeEvent extends ScheduleEvent {
  final String dayCode;
  final String? openTime;
  final String? closeTime;

  const UpdateTimeEvent({
    required this.dayCode,
    this.openTime,
    this.closeTime,
  });

  @override
  List<Object?> get props => [dayCode, openTime, closeTime];
}

/// Triggers submission of active schedules to the backend.
class SubmitScheduleEvent extends ScheduleEvent {
  const SubmitScheduleEvent();
}

/// Triggers updating active schedules via PUT array to the backend.
class UpdateScheduleEvent extends ScheduleEvent {
  const UpdateScheduleEvent();
}
