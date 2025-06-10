import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/models/calendar.dart';

class WeekDayCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;

  const WeekDayCalendar({
    super.key,
    required this.selectedDate,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {


    final filteredEvents = events.where((event) => isEventInDay(event.startTime, event.endTime, selectedDate)).toList();

    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text(
          'Không có sự kiện',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        final color = getEventStatusColor(event.startTime, event.endTime);
        return Card(
          child: ListTile(
            leading: Icon(Icons.event, color: color),
            title: Text(event.title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            subtitle: Text(event.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('HH:mm').format(event.startTime)),
                Text(DateFormat('HH:mm').format(event.endTime)),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isEventInDay(DateTime eventStart, DateTime eventEnd, DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    // Bao gồm cả trường hợp eventStart hoặc eventEnd đúng bằng đầu/cuối ngày
    return !(eventEnd.isBefore(dayStart) || eventStart.isAfter(dayEnd));
  }
}
