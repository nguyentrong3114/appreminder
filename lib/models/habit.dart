class Habit {
  final String id;
  final String title;
  final String iconCodePoint;
  final String colorValue;
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasEndDate;
  final HabitType type;
  final RepeatType repeatType;
  final List<int> selectedWeekdays;
  final List<int> selectedMonthlyDays;
  final bool reminderEnabled;
  final List<String> reminderTimes;
  final bool streakEnabled;
  final List<Map<String, dynamic>> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    required this.colorValue,
    required this.startDate,
    this.endDate,
    required this.hasEndDate,
    required this.type,
    required this.repeatType,
    required this.selectedWeekdays,
    required this.selectedMonthlyDays,
    required this.reminderEnabled,
    required this.reminderTimes,
    required this.streakEnabled,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'hasEndDate': hasEndDate,
      'type': type.toString(),
      'repeatType': repeatType.toString(),
      'selectedWeekdays': selectedWeekdays,
      'selectedMonthlyDays': selectedMonthlyDays,
      'reminderEnabled': reminderEnabled,
      'reminderTimes': reminderTimes,
      'streakEnabled': streakEnabled,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      hasEndDate: json['hasEndDate'],
      type: HabitType.values.firstWhere((e) => e.toString() == json['type']),
      repeatType: RepeatType.values.firstWhere(
        (e) => e.toString() == json['repeatType'],
      ),
      selectedWeekdays: List<int>.from(json['selectedWeekdays']),
      selectedMonthlyDays: List<int>.from(
        json['selectedMonthlyDays'] ?? [],
      ), // ✨ THAY ĐỔI CHÍNH
      reminderEnabled: json['reminderEnabled'],
      reminderTimes: List<String>.from(json['reminderTimes']),
      streakEnabled: json['streakEnabled'],
      tags: List<Map<String, dynamic>>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum HabitType { regular, onetime }

enum RepeatType { daily, weekly, monthly, yearly }
