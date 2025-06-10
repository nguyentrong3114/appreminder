import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/models/calendar.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:flutter_app/views/widgets/Home/week_of_year.dart';

List<Map<String, DateTime>> getWeeksOfYear(DateTime year, int startWeekOn) {
  final weeks = <Map<String, DateTime>>[];
  DateTime date = DateTime(year.year, 1, 1);
  // Tìm ngày đầu tuần đầu tiên của năm
  date = getWeekStartDate(date, startWeekOn);
  while (date.year <= year.year) {
    final weekStart = date;
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.year > year.year) break;
    weeks.add({'start': weekStart, 'end': weekEnd});
    date = weekStart.add(const Duration(days: 7));
  }
  return weeks;
}

class WeekView extends StatelessWidget {
  final List<CalendarEvent> allEvents;
  final DateTime? selectedDate;

  const WeekView({super.key, required this.allEvents, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final startWeekOn = context.watch<SettingProvider>().startWeekOn;
    final weekStart = getWeekStartDate(selectedDate!, startWeekOn);
    final weekEvents = _getWeekEvents(weekStart, allEvents);
    final use24Hour = context.watch<SettingProvider>().use24HourFormat;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: weekEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final day = weekEvents[index];
        final events = day['events'] as List<CalendarEvent>;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day['label']} (${DateFormat('dd/MM').format(day['date'])})',
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

  List<Map<String, dynamic>> _getWeekEvents(DateTime weekStart, List<CalendarEvent> allEvents) {
    final List<Map<String, dynamic>> days = [];
    final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final events = allEvents.where((e) =>
        e.startTime.year == day.year &&
        e.startTime.month == day.month &&
        e.startTime.day == day.day
      ).toList();
      days.add({
        'label': labels[i],
        'date': day,
        'events': events,
      });
    }
    return days;
  }
}

class WeekListView extends StatefulWidget {
  final List<CalendarEvent> allEvents;
  final int startWeekOn;
  final DateTime selectedYear;

  const WeekListView({
    super.key,
    required this.allEvents,
    required this.startWeekOn,
    required this.selectedYear,
  });

  @override
  State<WeekListView> createState() => _WeekListViewState();
}

class _WeekListViewState extends State<WeekListView> {
  int selectedWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    final weeks = getWeeksOfYear(widget.selectedYear, widget.startWeekOn);
    selectedWeekIndex = getCurrentWeekIndex(weeks, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final weeks = getWeeksOfYear(widget.selectedYear, widget.startWeekOn);
    final currentWeekIndex = getCurrentWeekIndex(weeks, DateTime.now());

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weeks.length,
            itemBuilder: (context, index) {
              final week = weeks[index];
              final label =
                  '${DateFormat('dd/MM').format(week['start']!)} - ${DateFormat('dd/MM').format(week['end']!)}';
              final isSelected = index == selectedWeekIndex;
              final isCurrent = index == currentWeekIndex;
              return GestureDetector(
                onTap: () => setState(() => selectedWeekIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isCurrent
                            ? AppColors.secondary // màu nổi bật cho tuần hiện tại
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isCurrent
                              ? AppColors.secondary
                              : AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isCurrent
                                ? Colors.white
                                : AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: WeekDaysEventsView(
            allEvents: widget.allEvents,
            weekStart: weeks[selectedWeekIndex]['start']!,
          ),
        ),
      ],
    );
  }
}

int getCurrentWeekIndex(List<Map<String, DateTime>> weeks, DateTime today) {
  for (int i = 0; i < weeks.length; i++) {
    final start = weeks[i]['start']!;
    final end = weeks[i]['end']!;
    if (!today.isBefore(start) && !today.isAfter(end)) {
      return i;
    }
  }
  return 0;
}
