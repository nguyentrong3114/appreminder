import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnetimeTask extends StatefulWidget {
  final DateTime? initialStartDate;
  final String? formattedStartDate;

  const OnetimeTask({Key? key, this.initialStartDate, this.formattedStartDate})
    : super(key: key);

  @override
  _OnetimeTask createState() => _OnetimeTask();
}

class _OnetimeTask extends State<OnetimeTask> {
  bool reminderEnabled = false;
  bool streakEnabled = false;
  Color selectedColor = Colors.red;
  IconData selectedIcon = Icons.bedtime;
  late DateTime startDate;
  late String formattedStartDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate ?? DateTime.now();
    formattedStartDate =
        widget.formattedStartDate ??
        DateFormat('MMMM d, yyyy', 'vi_VN').format(startDate);
  }

  // Danh sách các biểu tượng để lựa chọn
  final List<IconData> iconOptions = [
    Icons.flag,
    Icons.fitness_center,
    Icons.local_drink,
    Icons.book,
    Icons.accessibility,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.bedtime,
    Icons.music_note,
    Icons.laptop,
    Icons.local_dining,
    Icons.smoke_free,
  ];

  // Danh sách các màu sắc để lựa chọn
  final List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
  ];

  void _showIconSelector() {
    // Giữ nguyên code hiện tại
  }

  void _showColorSelector() {
    // Giữ nguyên code hiện tại
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        formattedStartDate = DateFormat(
          'MMMM d, yyyy',
          'vi_VN',
        ).format(startDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: selectedColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'THỬ THÁCH MỚI',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: selectedColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit name input
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today, color: selectedColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tên',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Icon and color selectors
            Row(
              children: [
                // Icon selector
                Expanded(
                  child: GestureDetector(
                    onTap: _showIconSelector,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(selectedIcon, color: selectedColor, size: 40),
                          SizedBox(height: 8),
                          Text('Biểu tượng', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Color selector
                Expanded(
                  child: GestureDetector(
                    onTap: _showColorSelector,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Màu sắc', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Settings container
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Start date
                  GestureDetector(
                    onTap: _selectStartDate,
                    child: SettingItem(
                      icon: Icons.flag,
                      iconColor: selectedColor,
                      title: 'Ngày bắt đầu',
                      trailing: Row(
                        children: [
                          Text(
                            formattedStartDate,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(height: 24),

                  // Daily frequency
                  SettingItem(
                    icon: Icons.repeat,
                    iconColor: selectedColor,
                    title: 'Không lặp lại',
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),

                  // End time
                  Divider(height: 24),

                  // Reminder
                  SettingItem(
                    icon: Icons.notifications,
                    iconColor: selectedColor,
                    title: 'Nhắc nhở',
                    trailing: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),

                        Switch(
                          value: reminderEnabled,
                          onChanged: (value) {
                            setState(() {
                              reminderEnabled = value;
                            });
                          },
                          activeColor: selectedColor,
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 24),

                  // Streak
                  SettingItem(
                    icon: Icons.local_fire_department,
                    iconColor: selectedColor,
                    title: 'Thẻ',
                    trailing: Switch(
                      value: streakEnabled,
                      onChanged: (value) {
                        setState(() {
                          streakEnabled = value;
                        });
                      },
                      activeColor: selectedColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Precise positioning of the button with flexible space
            Spacer(flex: 3),
            // Save button with adjusted width
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Space below the button
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 16),
        Text(title, style: TextStyle(fontSize: 16)),
        Spacer(),
        trailing,
      ],
    );
  }
}
