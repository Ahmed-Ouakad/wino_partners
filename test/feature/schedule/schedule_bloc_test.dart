import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/core/error/failures.dart';
import 'package:wino_partners/core/services/caching_service.dart';
import 'package:wino_partners/feature/schedule/domain/entities/day_schedule.dart';
import 'package:wino_partners/feature/schedule/domain/repositories/schedule_repository.dart';
import 'package:wino_partners/feature/schedule/domain/usecases/submit_schedule_usecase.dart';
import 'package:wino_partners/feature/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:wino_partners/feature/schedule/presentation/bloc/schedule_event.dart';
import 'package:wino_partners/feature/schedule/presentation/bloc/schedule_state.dart';

class MockCachingService implements CachingService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> clear() async => _storage.clear();

  @override
  double? getDouble(String key) => _storage[key] as double?;

  @override
  String? getString(String key) => _storage[key] as String?;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> saveDouble(String key, double value) async => _storage[key] = value;

  @override
  Future<void> saveString(String key, String value) async => _storage[key] = value;
}

class MockScheduleRepository implements ScheduleRepository {
  Either<Failure, void> result = const Right(null);
  String? capturedServiceId;
  List<DaySchedule>? capturedSchedules;

  @override
  Future<Either<Failure, void>> submitSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    capturedServiceId = serviceId;
    capturedSchedules = schedules;
    return result;
  }

  @override
  Future<Either<Failure, void>> updateSchedule({
    required String serviceId,
    required List<DaySchedule> schedules,
  }) async {
    capturedServiceId = serviceId;
    capturedSchedules = schedules;
    return result;
  }
}

void main() {
  late MockCachingService mockCachingService;
  late MockScheduleRepository mockRepository;
  late SubmitScheduleUseCase useCase;
  late ScheduleBloc bloc;

  setUp(() {
    mockCachingService = MockCachingService();
    mockRepository = MockScheduleRepository();
    useCase = SubmitScheduleUseCase(mockRepository);
    bloc = ScheduleBloc(
      submitScheduleUseCase: useCase,
      cachingService: mockCachingService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has 7 days matching standard schedule layout', () {
    expect(bloc.state.schedules.length, 7);
    expect(bloc.state.schedules[0].dayCode, 'Lu');
    expect(bloc.state.schedules[0].isOpen, true);
    expect(bloc.state.schedules[5].dayCode, 'Sa');
    expect(bloc.state.schedules[5].isOpen, false);
    expect(bloc.state.sameScheduleEveryDay, false);
  });

  test('ToggleDayEvent changes day open status', () async {
    bloc.add(const ToggleDayEvent(dayCode: 'Sa', isOpen: true));

    await expectLater(
      bloc.stream,
      emits(predicate<ScheduleState>((state) {
        final saturday = state.schedules.firstWhere((s) => s.dayCode == 'Sa');
        return saturday.isOpen == true;
      })),
    );
  });

  test('ToggleSameScheduleEveryDayEvent copies times across all active days', () async {
    bloc.add(const UpdateTimeEvent(
      dayCode: 'Lu',
      openTime: '08:30',
      closeTime: '21:30',
    ));
    bloc.add(const ToggleSameScheduleEveryDayEvent(true));

    await expectLater(
      bloc.stream,
      emitsThrough(predicate<ScheduleState>((state) {
        if (!state.sameScheduleEveryDay) return false;
        final tuesday = state.schedules.firstWhere((s) => s.dayCode == 'Ma');
        return tuesday.openTime == '08:30' && tuesday.closeTime == '21:30';
      })),
    );
  });

  test('SubmitScheduleEvent emits error if serviceId is missing from cache', () async {
    bloc.add(const SubmitScheduleEvent());

    await expectLater(
      bloc.stream,
      emits(predicate<ScheduleState>((state) {
        return state.errorMessage != null &&
            state.errorMessage!.contains('Identifiant du service introuvable');
      })),
    );
  });

  test('SubmitScheduleEvent calls usecase and emits isSuccess=true when serviceId exists', () async {
    await mockCachingService.saveString(serviceIdKey, 'test-service-123');

    bloc.add(const SubmitScheduleEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<ScheduleState>((state) => state.isSubmitting == true),
        predicate<ScheduleState>((state) =>
            state.isSubmitting == false && state.isSuccess == true),
      ]),
    );

    expect(mockRepository.capturedServiceId, 'test-service-123');
    expect(mockRepository.capturedSchedules?.isNotEmpty, true);
  });
}
