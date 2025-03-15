import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final VoidCallback onEdit; // Hàm callback khi bấm nút sửa

  EventCard({required this.title, required this.time, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có dấu " - " trong `time` không
    String? startTimeStr;
    if (time.contains(" - ")) {
      startTimeStr = time.split(" - ")[0];
    } else {
      startTimeStr = time; // Nếu không có dấu "-", lấy toàn bộ
    }

    DateTime now = DateTime.now();
    DateTime eventTime = _parseTime(startTimeStr, now);

    // Tính khoảng cách thời gian (âm nếu sự kiện đã qua)
    double diffInHours = eventTime.difference(now).inMinutes / 60.0;

    // Xác định màu sắc dựa trên thời gian
    Color cardColor;
    if (diffInHours < 0) {
      cardColor = Colors.grey; // Sự kiện đã qua
    } else if (diffInHours <= 1) {
      cardColor = Colors.redAccent; // Cận kề (dưới 1 giờ)
    } else if (diffInHours <= 5) {
      cardColor = Colors.amberAccent; // Sắp diễn ra (1-5 giờ)
    } else {
      cardColor = Colors.greenAccent; // Còn xa
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
          icon: Icon(Icons.edit, color: Colors.black54), // Biểu tượng chỉnh sửa
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
      return referenceDate; // Trả về ngày hiện tại nếu lỗi
    }
  }
}
