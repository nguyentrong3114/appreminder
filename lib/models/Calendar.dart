class CalendarEvent {
  final String id;
  final String title;
  final String detail;
  final String location;
  final String description;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final bool reminder;
  final bool alarmReminder;

  CalendarEvent({
    required this.id, 
    required this.title,
    required this.userId,
    required this.detail,
    required this.location,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.allDay = false,
    this.reminder = false,
    this.alarmReminder = false,
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
