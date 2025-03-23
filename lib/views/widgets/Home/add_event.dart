import 'package:flutter/material.dart';

class AddEventWidget extends StatefulWidget {
  final DateTime initialDate;

  AddEventWidget({required this.initialDate, required DateTime selectedDate}); // ✅ Chỉ cần initialDate

  @override
  _AddEventWidgetState createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  bool allDay = false;
  bool reminder = true;
  bool alarmReminder = false;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate; // ✅ Gán giá trị từ initialDate
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm sự kiện")),
      body: SingleChildScrollView( // ✅ Tránh lỗi khi bàn phím xuất hiện
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh tiêu đề
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.green),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "EVENT",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(context); // ✅ Đóng khi nhấn "✔"
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Nhập tiêu đề
              TextField(
                decoration: InputDecoration(
                  hintText: "Tiêu đề",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Divider(),

              // Cài đặt Cả ngày
              SwitchListTile(
                title: Text(
                  "Cả ngày",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(Icons.access_time, color: Colors.green),
                value: allDay,
                onChanged: (value) => setState(() => allDay = value),
              ),

              // Chọn ngày
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.green),
                title: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                onTap: () => _selectDate(context),
              ),
              Divider(),

              // Cài đặt Nhắc nhở
              SwitchListTile(
                title: Text(
                  "Cài đặt nhắc nhở",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(Icons.notifications_active, color: Colors.green),
                value: reminder,
                onChanged: (value) => setState(() => reminder = value),
              ),

              // Nhắc nhở báo thức
              SwitchListTile(
                title: Text(
                  "Nhắc nhở báo thức",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(Icons.alarm, color: Colors.green),
                value: alarmReminder,
                onChanged: (value) => setState(() => alarmReminder = value),
              ),
              Divider(),

              // Chọn màu sắc sự kiện
              ListTile(
                leading: Icon(Icons.color_lens, color: Colors.green),
                title: Text("Màu sắc sự kiện"),
                trailing: Wrap(
                  spacing: 5,
                  children: List.generate(5, (index) {
                    return CircleAvatar(
                      radius: 10,
                      backgroundColor: [
                        Colors.green,
                        Colors.orange,
                        Colors.red,
                        Colors.blue,
                        Colors.black,
                      ][index],
                    );
                  }),
                ),
                onTap: () {},
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
