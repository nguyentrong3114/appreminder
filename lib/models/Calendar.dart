import 'dart:ui';

class CalendarEvent {
  final String title;
  final String detail;
  final String location;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final bool reminder;
  final bool alarmReminder;

  CalendarEvent({
    required this.title,
    required this.detail,
    required this.location,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.allDay,
    required this.reminder,
    required this.alarmReminder,
  });


  @override
  String toString() {
    return 'Event: $title, Time: $startTime - $endTime, Description: $description';
  }
}
