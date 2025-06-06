import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/Calendar.dart';
import 'add_event.dart'; // Import màn hình thêm sự kiện nếu có
// import 'add_note.dart'; // Nếu có màn hình thêm ghi chú

class AddSomethingToday extends StatelessWidget {
  const AddSomethingToday({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    String todayFormat = DateFormat('dd/MM/yyyy').format(today);
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm gì hôm nay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hôm nay: $todayFormat', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildOption(
              context,
              Icons.event,
              "Thêm sự kiện",
              Colors.blue,
              () {
                showDialog(
                  context: context,
                  builder: (context) => AddEventWidget(selectedDate: today, onAdd: (CalendarEvent event) {  },),
                );
              },
            ),
            _buildOption(
              context,
              Icons.note,
              "Thêm ghi chú",
              Colors.green,
              () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteWidget(selectedDate: today)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(180, 48),
        ),
        onPressed: onPressed,
      ),
    );
  }
}