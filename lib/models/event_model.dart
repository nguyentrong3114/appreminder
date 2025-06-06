class EventModel {
  final String id; // unique id, có thể dùng DateTime.now().millisecondsSinceEpoch.toString()
  final String title;
  final String description;
  final String location;
  final DateTime date; // ngày diễn ra sự kiện
  final String weekDay; // T2, T3, ...
  final String time; // ví dụ: "8:00 - 9:00" hoặc "Cả ngày"
  final bool allDay;
  final bool reminder;
  final bool alarmReminder;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.weekDay,
    required this.time,
    this.allDay = false,
    this.reminder = false,
    this.alarmReminder = false,
  });

  // Convert EventModel to Map (for Firebase/local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'weekDay': weekDay,
      'time': time,
      'allDay': allDay,
      'reminder': reminder,
      'alarmReminder': alarmReminder,
    };
  }

  // Create EventModel from Map
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      date: DateTime.parse(map['date']),
      weekDay: map['weekDay'] ?? '',
      time: map['time'] ?? '',
      allDay: map['allDay'] ?? false,
      reminder: map['reminder'] ?? false,
      alarmReminder: map['alarmReminder'] ?? false,
    );
  }
}