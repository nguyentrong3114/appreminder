import 'package:flutter/material.dart';
import 'package:flutter_app/views/widgets/home/bottom_selected_time.dart';

class AddEventWidget extends StatefulWidget {
  final DateTime selectedDate;

  AddEventWidget({required this.selectedDate});

  @override
  _AddEventWidgetState createState() => _AddEventWidgetState();
}

class _AddEventWidgetState extends State<AddEventWidget> {
  bool allDay = false;
  bool reminder = false;
  bool alarmReminder = false;
  late DateTime selectedDate;
  List<String> selectedTime = ["Đúng giờ", "15 phút trước"];
  final List<String> options = [
    "Đúng giờ",
    "15 phút trước",
    "30 phút trước",
    "1 giờ trước",
    "2 giờ trước",
    "6 giờ trước",
    "12 giờ trước",
    "1 ngày trước",
    "2 ngày trước",
    "1 tuần trước",
  ];
  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm sự kiện")),
      body: SingleChildScrollView(
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
                    "Tạo Sự Kiện Mới",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Nhập tiêu đề
              TextField(
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 62, 63, 62),
                      width: 2.0,
                    ),
                  ),
                  hintText: "Tiêu đề",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 62, 63, 62),
                      width: 2.0,
                    ),
                  ),
                  hintText: "Nội dung",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
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
                secondary: Icon(
                  Icons.notifications_active,
                  color: Colors.green,
                ),
                value: reminder,
                onChanged: (value) => setState(() => reminder = value),
              ),
              if (reminder)
                Column(
                  children: [
                    ...selectedTime.map(
                      (time) => ListTile(
                        leading: Icon(Icons.access_time, color: Colors.green),
                        title: Text(time, style: TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedTime.remove(time);
                            });
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.add, color: Colors.green),
                      title: Text("Thêm thời gian nhắc nhở"),
                      onTap: () async {
                        final List<String> remainingOptions =
                            options
                                .where(
                                  (option) => !selectedTime.contains(option),
                                )
                                .toList();

                        if (remainingOptions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Không còn thời gian nào để chọn!"),
                            ),
                          );
                          return;
                        }

                        final String? pickedTime =
                            await showModalBottomSheet<String>(
                              isScrollControlled: true,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomPopup(
                                  listToSelected: remainingOptions,
                                );
                              },
                            );

                        if (pickedTime != null) {
                          setState(() {
                            selectedTime.add(pickedTime);
                          });
                        }
                      },
                    ),
                  ],
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
                      backgroundColor:
                          [
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
