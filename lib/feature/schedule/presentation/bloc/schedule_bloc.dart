import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/caching_service.dart';
import '../../domain/entities/day_schedule.dart';
import '../../domain/usecases/submit_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final SubmitScheduleUseCase submitScheduleUseCase;
  final UpdateScheduleUseCase? updateScheduleUseCase;
  final CachingService cachingService;

  ScheduleBloc({
    required this.submitScheduleUseCase,
    this.updateScheduleUseCase,
    required this.cachingService,
  }) : super(ScheduleState(schedules: _defaultSchedules)) {
    on<ToggleSameScheduleEveryDayEvent>(_onToggleSameScheduleEveryDay);
    on<ToggleDayEvent>(_onToggleDay);
    on<UpdateTimeEvent>(_onUpdateTime);
    on<SubmitScheduleEvent>(_onSubmitSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
  }

  static final List<DaySchedule> _defaultSchedules = [
    const DaySchedule(
      dayCode: 'Lu',
      dayName: 'Lundi',
      apiDay: 'MONDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: true,
    ),
    const DaySchedule(
      dayCode: 'Ma',
      dayName: 'Mardi',
      apiDay: 'TUESDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: true,
    ),
    const DaySchedule(
      dayCode: 'Me',
      dayName: 'Mercredi',
      apiDay: 'WEDNESDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: true,
    ),
    const DaySchedule(
      dayCode: 'Je',
      dayName: 'Jeudi',
      apiDay: 'THURSDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: true,
    ),
    const DaySchedule(
      dayCode: 'Ve',
      dayName: 'Vendredi',
      apiDay: 'FRIDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: true,
    ),
    const DaySchedule(
      dayCode: 'Sa',
      dayName: 'Samedi',
      apiDay: 'SATURDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: false,
    ),
    const DaySchedule(
      dayCode: 'Di',
      dayName: 'Dimanche',
      apiDay: 'SUNDAY',
      openTime: '07:00',
      closeTime: '19:00',
      isOpen: false,
    ),
  ];

  void _onToggleSameScheduleEveryDay(
    ToggleSameScheduleEveryDayEvent event,
    Emitter<ScheduleState> emit,
  ) {
    if (event.value) {
      // Find the first active day to synchronize times
      final referenceDay = state.schedules.firstWhere(
        (s) => s.isOpen,
        orElse: () => state.schedules.first,
      );

      final updated = state.schedules.map((s) {
        if (s.isOpen) {
          return s.copyWith(
            openTime: referenceDay.openTime,
            closeTime: referenceDay.closeTime,
          );
        }
        return s;
      }).toList();

      emit(state.copyWith(
        sameScheduleEveryDay: true,
        schedules: updated,
      ));
    } else {
      emit(state.copyWith(sameScheduleEveryDay: false));
    }
  }

  void _onToggleDay(
    ToggleDayEvent event,
    Emitter<ScheduleState> emit,
  ) {
    final updated = state.schedules.map((s) {
      if (s.dayCode == event.dayCode) {
        return s.copyWith(isOpen: event.isOpen);
      }
      return s;
    }).toList();

    emit(state.copyWith(schedules: updated));
  }

  void _onUpdateTime(
    UpdateTimeEvent event,
    Emitter<ScheduleState> emit,
  ) {
    final newOpen = event.openTime;
    final newClose = event.closeTime;

    final updated = state.schedules.map((s) {
      if (state.sameScheduleEveryDay && s.isOpen) {
        return s.copyWith(
          openTime: newOpen ?? s.openTime,
          closeTime: newClose ?? s.closeTime,
        );
      } else if (s.dayCode == event.dayCode) {
        return s.copyWith(
          openTime: newOpen ?? s.openTime,
          closeTime: newClose ?? s.closeTime,
        );
      }
      return s;
    }).toList();

    emit(state.copyWith(schedules: updated));
  }

  Future<void> _onSubmitSchedule(
    SubmitScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final activeDays = state.schedules.where((s) => s.isOpen).toList();
    if (activeDays.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Veuillez activer au moins un jour ouvré.',
      ));
      return;
    }

    final serviceId = cachingService.getString(serviceIdKey);
    if (serviceId == null || serviceId.isEmpty) {
      emit(state.copyWith(
        errorMessage:
            'Identifiant du service introuvable. Veuillez compléter la première étape de l\'onboarding.',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
    ));

    final result = await submitScheduleUseCase(SubmitScheduleParams(
      serviceId: serviceId,
      schedules: activeDays,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ));
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final activeDays = state.schedules.where((s) => s.isOpen).toList();
    if (activeDays.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Veuillez activer au moins un jour ouvré.',
      ));
      return;
    }

    final serviceId = cachingService.getString(serviceIdKey);
    if (serviceId == null || serviceId.isEmpty) {
      emit(state.copyWith(
        errorMessage:
            'Identifiant du service introuvable. Veuillez compléter la première étape de l\'onboarding.',
      ));
      return;
    }

    if (updateScheduleUseCase == null) {
      emit(state.copyWith(
        errorMessage: 'Cas d\'utilisation de mise à jour non configuré.',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
    ));

    final result = await updateScheduleUseCase!(UpdateScheduleParams(
      serviceId: serviceId,
      schedules: activeDays,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        ));
      },
    );
  }
}
