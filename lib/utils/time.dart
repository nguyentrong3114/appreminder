import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String formatTime(DateTime time, {required bool use24HourFormat}) {
  final format = use24HourFormat ? DateFormat.Hm() : DateFormat.jm();
  return format.format(time);
}

/// startWeekOn: 1 = Thứ 2, ..., 7 = Chủ nhật (theo chuẩn Dart DateTime.weekday)
DateTime getWeekStartDate(DateTime date, int startWeekOn) {
  // Nếu startWeekOn = 0 (Chủ nhật), chuyển thành 7 cho đúng chuẩn Dart
  int normalizedStart = startWeekOn == 0 ? 7 : startWeekOn;
  int diff = (date.weekday - normalizedStart) < 0
      ? (date.weekday - normalizedStart + 7)
      : (date.weekday - normalizedStart);
  return date.subtract(Duration(days: diff));
}

Color getEventStatusColor(DateTime start, DateTime end) {
  final now = DateTime.now();
  if (end.isBefore(now)) {
    return Colors.red; // Past
  } else if (start.isAfter(now) && start.isBefore(now.add(const Duration(hours: 24)))) {
    return Colors.amber; // Near/upcoming (within 24h)
  } else if (start.isAfter(now)) {
    return Colors.green; // Future
  } else {
    return Colors.amber; // Ongoing event (started but not ended)
  }
}
