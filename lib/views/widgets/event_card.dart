import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback onEdit; // Hàm callback khi bấm nút sửa

  EventCard({required this.title, required this.time, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    String startTimeStr = time.split(" - ")[0];
    DateTime now = DateTime.now();
    DateTime eventTime = _parseTime(startTimeStr, now);

    // Tính khoảng cách thời gian
    double diffInHours = eventTime.difference(now).inMinutes / 60.0;

    // Xác định màu sắc dựa trên thời gian
    Color cardColor;
    if (diffInHours <= 1) {
      cardColor = Colors.redAccent;
    } else if (diffInHours <= 5) {
      cardColor = Colors.amberAccent;
    } else {
      cardColor = Colors.greenAccent;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: cardColor,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          time,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.black54), // Biểu tượng cây bút
          onPressed: onEdit, // Khi bấm sẽ gọi hàm `onEdit`
        ),
      ),
    );
  }

  /// Chuyển đổi chuỗi giờ (VD: "10:00 AM") thành `DateTime`
  DateTime _parseTime(String timeStr, DateTime referenceDate) {
    try {
      DateFormat format = DateFormat("hh:mm a");
      DateTime parsedTime = format.parse(timeStr);
      return DateTime(referenceDate.year, referenceDate.month, referenceDate.day,
          parsedTime.hour, parsedTime.minute);
    } catch (e) {
      print("Lỗi parse thời gian: $e");
      return referenceDate;
    }
  }
}
