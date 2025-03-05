import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7, // Hiển thị 7 ngày trong tuần
        itemBuilder: (context, index) {
          DateTime day = today.add(Duration(days: index - today.weekday + 1)); // Bắt đầu từ thứ 2
          String weekDay = DateFormat.E('vi').format(day); // Lấy tên thứ (vi = Tiếng Việt)
          String dayNumber = DateFormat.d().format(day); // Lấy số ngày

          return GestureDetector(
            onTap: () {
              print("Bạn đã chọn: $weekDay, ngày $dayNumber");
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weekDay, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // Thứ
                  Text(dayNumber, style: TextStyle(color: Colors.white, fontSize: 16)), // Ngày
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
