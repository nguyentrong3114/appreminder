import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện định dạng ngày tháng

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: AddEventScreen()),
  );
}

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _repeatIndex = 0;
  List<String> options = [
    "Chỉ hôm nay",
    "3 Ngày liên tục",
    "Lặp lại hằng tuần",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm sự kiện")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Tên sự kiện"),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("Giờ bắt đầu: ${_selectedTime.format(context)}"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
            ),
            Column(
              children: List.generate(options.length, (index) {
                return RadioListTile(
                  title: Text(options[index]),
                  value: index,
                  groupValue: _repeatIndex,
                  onChanged: (int? value) {
                    setState(() {
                      _repeatIndex = value!;
                    });
                  },
                );
              }),
            ),
            ListTile(
              title: Text(
                "Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}", // Định dạng ngày
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }
}
