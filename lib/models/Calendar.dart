import 'dart:ui';

class CalendarEvent {
  String title;
  DateTime startTime;
  DateTime endTime;
  String description;
  Color color;
  String url;
  String location;
  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description = '',
    this.url = '',
    this.location = '',
    this.color = const Color(0xFF4CD080),
  });

  @override
  String toString() {
    return 'Event: $title, Time: $startTime - $endTime, Description: $description';
  }
}
