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
  List<Color> colors = [
    const Color(0xFF4CD080), // Green
    const Color(0xFFFFBE55), // Yellow/Orange
    const Color(0xFFFF6B81), // Pink
    const Color(0xFF8F9BFF), // Purple/Blue
    const Color(0xFFFF8A65), // Orange
    Colors.black,
  ];
  Color selectedColor = const Color(0xFF4CD080); // Màu mặc định
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
                    icon: Icon(Icons.close, color: selectedColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Tạo Sự Kiện Mới",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: selectedColor),
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
                    borderSide: BorderSide(color: selectedColor, width: 2.0),
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
                    borderSide: BorderSide(color: selectedColor, width: 2.0),
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
                secondary: Icon(Icons.access_time, color: selectedColor),
                value: allDay,
                onChanged: (value) => setState(() => allDay = value),
              ),

              // Chọn ngày
              ListTile(
                leading: Icon(Icons.calendar_today, color: selectedColor),
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
                  color: selectedColor,
                ),
                value: reminder,
                onChanged: (value) => setState(() => reminder = value),
              ),
              if (reminder)
                Column(
                  children: [
                    ...selectedTime.map(
                      (time) => ListTile(
                        leading: Icon(Icons.access_time, color: selectedColor),
                        title: Text(time, style: TextStyle(fontSize: 16)),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: selectedColor),
                          onPressed: () {
                            setState(() {
                              selectedTime.remove(time);
                            });
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.add, color: selectedColor),
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
                secondary: Icon(Icons.alarm, color: selectedColor),
                value: alarmReminder,
                onChanged: (value) => setState(() => alarmReminder = value),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.color_lens, color: selectedColor),
                title: Text("Màu sắc sự kiện"),
                trailing: Wrap(
                  spacing: 5,
                  children: List.generate(colors.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = colors[index];
                        });
                      },
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: colors[index],
                        child:
                            selectedColor == colors[index]
                                ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                                : null,
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
