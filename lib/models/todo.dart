class Todo {
  final String id;
  final String title;
  final String? details;
  final String colorValue;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool reminderEnabled;
  final String? reminderTime; // Dạng "5 phút trước", "1 giờ trước", ...
  final bool isDone;
  final List<Map<String, dynamic>> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Todo({
    required this.id,
    required this.title,
    this.details,
    required this.colorValue,
    required this.startDateTime,
    required this.endDateTime,
    required this.reminderEnabled,
    this.reminderTime,
    required this.isDone,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'colorValue': colorValue,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'isDone': isDone,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      colorValue: json['colorValue'],
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      reminderEnabled: json['reminderEnabled'],
      reminderTime: json['reminderTime'],
      isDone: json['isDone'],
      tags: List<Map<String, dynamic>>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
