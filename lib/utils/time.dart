import 'package:intl/intl.dart';

String formatTime(DateTime time, {required bool use24HourFormat}) {
  final format = use24HourFormat ? DateFormat.Hm() : DateFormat.jm();
  return format.format(time);
}
