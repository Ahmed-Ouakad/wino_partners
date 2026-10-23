import 'package:equatable/equatable.dart';

/// Entity representing the operating schedule for a single day of the week.
class DaySchedule extends Equatable {
  final String dayCode; // e.g. 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'
  final String dayName; // e.g. 'Lundi', 'Mardi', etc.
  final String apiDay; // e.g. 'MONDAY', 'TUESDAY', etc.
  final String openTime; // e.g. '08:00' (HH:mm)
  final String closeTime; // e.g. '19:00' (HH:mm)
  final bool isOpen;

  const DaySchedule({
    required this.dayCode,
    required this.dayName,
    required this.apiDay,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  DaySchedule copyWith({
    String? dayCode,
    String? dayName,
    String? apiDay,
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return DaySchedule(
      dayCode: dayCode ?? this.dayCode,
      dayName: dayName ?? this.dayName,
      apiDay: apiDay ?? this.apiDay,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': apiDay,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }

  @override
  List<Object?> get props => [
        dayCode,
        dayName,
        apiDay,
        openTime,
        closeTime,
        isOpen,
      ];
}
