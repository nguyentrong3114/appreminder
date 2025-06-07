import 'Calendar.dart';

class DayEvents {
  final DateTime date;
  final List<CalendarEvent> events;

  DayEvents({
    required this.date,
    required this.events,
  });
}

Map<String, List<CalendarEvent>> getEventsByDay(List<CalendarEvent> events) {
  final Map<String, List<CalendarEvent>> grouped = {};
  for (var event in events) {
    final dateKey = "${event.startTime.year}-${event.startTime.month.toString().padLeft(2, '0')}-${event.startTime.day.toString().padLeft(2, '0')}";
    grouped[dateKey] = [...(grouped[dateKey] ?? []), event];
  }
  return grouped;
}
