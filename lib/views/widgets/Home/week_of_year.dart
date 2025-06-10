import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/models/calendar.dart';
import 'package:flutter_app/provider/setting_provider.dart';

class WeekDaysEventsView extends StatelessWidget {
  final List<CalendarEvent> allEvents;
  final DateTime weekStart;

  const WeekDaysEventsView({
    super.key,
    required this.allEvents,
    required this.weekStart,
  });

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<SettingProvider>().use24HourFormat;
    // Sinh nhãn động dựa trên weekStart
    final weekLabels = List.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      // Thứ 2 = 1, ... Chủ nhật = 7
      final weekday = d.weekday;
      switch (weekday) {
        case 1:
          return 'T2';
        case 2:
          return 'T3';
        case 3:
          return 'T4';
        case 4:
          return 'T5';
        case 5:
          return 'T6';
        case 6:
          return 'T7';
        case 7:
          return 'CN';
        default:
          return '';
      }
    });
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: 7,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final day = weekStart.add(Duration(days: index));
        final events = allEvents.where((e) =>
          e.startTime.year == day.year &&
          e.startTime.month == day.month &&
          e.startTime.day == day.day
        ).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weekLabels[index]} (${DateFormat('dd/MM').format(day)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                events.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: events.map((e) {
                          final color = getEventStatusColor(e.startTime, e.endTime);
                          if (e.allDay) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Cả ngày: ${e.title}',
                                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${formatTime(e.startTime, use24HourFormat: use24Hour)} - '
                                '${formatTime(e.endTime, use24HourFormat: use24Hour)} ${e.title}',
                                style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                        }).toList(),
                      )
                    : const Text(
                        'Không có sự kiện',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}