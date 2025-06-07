class EventModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool allDay;
  final bool reminder;
  final bool alarmReminder;

  EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.allDay = false,
    this.reminder = false,
    this.alarmReminder = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'allDay': allDay,
      'reminder': reminder,
      'alarmReminder': alarmReminder,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      allDay: map['allDay'] ?? false,
      reminder: map['reminder'] ?? false,
      alarmReminder: map['alarmReminder'] ?? false,
    );
  }
}
