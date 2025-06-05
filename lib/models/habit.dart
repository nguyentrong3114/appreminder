import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String title;
  final String iconCodePoint;
  final String colorValue;
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasEndDate;
  final HabitType type; // Thêm field này
  final RepeatType? repeatType; // Nullable cho onetime task
  final List<int> selectedWeekdays;
  final int monthlyDay;
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
    required this.type, // Required
    this.repeatType, // Nullable
    required this.selectedWeekdays,
    required this.monthlyDay,
    required this.reminderEnabled,
    required this.reminderTimes,
    required this.streakEnabled,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      title: map['title'] ?? '',
      iconCodePoint: map['iconCodePoint'] ?? '',
      colorValue: map['colorValue'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate:
          map['endDate'] != null
              ? (map['endDate'] as Timestamp).toDate()
              : null,
      hasEndDate: map['hasEndDate'] ?? false,
      type: HabitType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => HabitType.regular,
      ),
      repeatType:
          map['repeatType'] != null
              ? RepeatType.values.firstWhere(
                (e) => e.toString() == map['repeatType'],
                orElse: () => RepeatType.daily,
              )
              : null,
      selectedWeekdays: List<int>.from(map['selectedWeekdays'] ?? []),
      monthlyDay: map['monthlyDay'] ?? 1,
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      streakEnabled: map['streakEnabled'] ?? false,
      tags: List<Map<String, dynamic>>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'hasEndDate': hasEndDate,
      'type': type.toString(), // Lưu loại habit
      'repeatType': repeatType?.toString(), // Nullable
      'selectedWeekdays': selectedWeekdays,
      'monthlyDay': monthlyDay,
      'reminderEnabled': reminderEnabled,
      'reminderTimes': reminderTimes,
      'streakEnabled': streakEnabled,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

// Thêm enum để phân biệt loại habit
enum HabitType { regular, onetime }

enum RepeatType { daily, weekly, monthly, yearly }
