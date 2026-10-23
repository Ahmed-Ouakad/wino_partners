import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/screens/main_screen.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/day_schedule_row.dart';

class ScheduleScreen extends StatelessWidget {
  final bool isUpdating;

  const ScheduleScreen({
    super.key,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                  ),

                  // Brand Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Wino Partners',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Main Content Card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: BlocConsumer<ScheduleBloc, ScheduleState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else if (state.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isUpdating
                                ? 'Horaires mis à jour avec succès !'
                                : 'Horaires enregistrés avec succès !',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      if (isUpdating) {
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Horaires',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Same Schedule Switch Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mêmes horaires chaque jours',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: state.sameScheduleEveryDay,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: primaryColor,
                                  inactiveThumbColor: isDark
                                      ? Colors.grey.shade400
                                      : Colors.white,
                                  inactiveTrackColor: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade300,
                                  onChanged: (val) {
                                    context.read<ScheduleBloc>().add(
                                          ToggleSameScheduleEveryDayEvent(val),
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Divider(
                            color: isDark ? Colors.white12 : Colors.grey.shade200,
                            thickness: 1,
                          ),
                          const SizedBox(height: 12),

                          // Days List
                          ...state.schedules.map((schedule) {
                            return DayScheduleRow(
                              schedule: schedule,
                              onToggle: (isOpen) {
                                context.read<ScheduleBloc>().add(
                                      ToggleDayEvent(
                                        dayCode: schedule.dayCode,
                                        isOpen: isOpen,
                                      ),
                                    );
                              },
                              onTimeChanged: (openTime, closeTime) {
                                context.read<ScheduleBloc>().add(
                                      UpdateTimeEvent(
                                        dayCode: schedule.dayCode,
                                        openTime: openTime,
                                        closeTime: closeTime,
                                      ),
                                    );
                              },
                            );
                          }),

                          const SizedBox(height: 36),

                          // Continuer Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: state.isSubmitting
                                  ? null
                                  : () {
                                      if (isUpdating) {
                                        context
                                            .read<ScheduleBloc>()
                                            .add(const UpdateScheduleEvent());
                                      } else {
                                        context
                                            .read<ScheduleBloc>()
                                            .add(const SubmitScheduleEvent());
                                      }
                                    },
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isUpdating
                                          ? 'Enregistrer les modifications'
                                          : 'Continuer',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
