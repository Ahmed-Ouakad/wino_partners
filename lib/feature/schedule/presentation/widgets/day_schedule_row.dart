import 'package:flutter/material.dart';
import '../../domain/entities/day_schedule.dart';

class DayScheduleRow extends StatelessWidget {
  final DaySchedule schedule;
  final ValueChanged<bool> onToggle;
  final Function(String? openTime, String? closeTime) onTimeChanged;

  const DayScheduleRow({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onTimeChanged,
  });

  Future<void> _pickTime({
    required BuildContext context,
    required String currentTime,
    required bool isOpenTime,
  }) async {
    if (!schedule.isOpen) return;

    final parts = currentTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 8;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isOpenTime) {
        onTimeChanged(formatted, null);
      } else {
        onTimeChanged(null, formatted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = schedule.isOpen
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white38 : Colors.grey.shade400);

    final underlineColor = schedule.isOpen
        ? (isDark ? Colors.white30 : Colors.grey.shade300)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          // Day Badge Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: schedule.isOpen
                  ? primaryColor
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            alignment: Alignment.center,
            child: Text(
              schedule.dayCode,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: schedule.isOpen
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.grey.shade500),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Open Time
          Expanded(
            child: InkWell(
              onTap: schedule.isOpen
                  ? () => _pickTime(
                        context: context,
                        currentTime: schedule.openTime,
                        isOpenTime: true,
                      )
                  : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: underlineColor,
                      width: 1.5,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  schedule.openTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '-',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          // Close Time
          Expanded(
            child: InkWell(
              onTap: schedule.isOpen
                  ? () => _pickTime(
                        context: context,
                        currentTime: schedule.closeTime,
                        isOpenTime: false,
                      )
                  : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: underlineColor,
                      width: 1.5,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  schedule.closeTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Open / Closed Switch
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: schedule.isOpen,
              activeThumbColor: Colors.white,
              activeTrackColor: primaryColor,
              inactiveThumbColor: isDark ? Colors.grey.shade400 : Colors.white,
              inactiveTrackColor:
                  isDark ? Colors.white12 : Colors.grey.shade300,
              onChanged: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}
