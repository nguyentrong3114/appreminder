import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';

class WeekDayCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;

  const WeekDayCalendar({
    Key? key,
    required this.selectedDate,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return events.isEmpty
        ? const Center(child: Text("Không có sự kiện nào", style: TextStyle(color: AppColors.text)))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event, color: AppColors.primary),
                  title: Text(event.title),
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
}

class CalendarEvent {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String location;

  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.location,
  });
}
