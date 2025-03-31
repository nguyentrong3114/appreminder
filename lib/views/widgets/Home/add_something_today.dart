import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AddSomethingToday extends StatelessWidget {
  const AddSomethingToday({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    String todayFormat = DateFormat(
      'EEEE, dd MMMM yyyy, HH:mm',
      'vi',
    ).format(today);
    return Scaffold(
      appBar: AppBar(
        title: Text('HÔM NAY', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                todayFormat,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bạn có kế hoạch gì không?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOption(Icons.event, 'Event', Colors.green),
                _buildOption(Icons.check_circle, 'To do', Colors.red),
                _buildOption(Icons.note, 'Note', Colors.orange),
                _buildOption(Icons.edit, 'Diary', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildOption(IconData icon, String label, Color color) {
  return GestureDetector(
    onTap: () => {
    },
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 25,
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    ),
  );
}
