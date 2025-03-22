import 'package:flutter/material.dart';

class RegularHabitScreen extends StatefulWidget {
  final String? initialTitle;
  final IconData? initialIcon;
  final Color? initialColor;
  final bool?
  reminderEnabledByDefault; // Thêm tham số này để xác định có bật nhắc nhở mặc định hay không

  const RegularHabitScreen({
    Key? key,
    this.initialTitle,
    this.initialIcon,
    this.initialColor,
    this.reminderEnabledByDefault,
  }) : super(key: key);

  @override
  _RegularHabitScreenState createState() => _RegularHabitScreenState();
}

class _RegularHabitScreenState extends State<RegularHabitScreen> {
  late bool reminderEnabled;
  bool streakEnabled = false;
  late Color selectedColor;
  late IconData selectedIcon; // Vẫn giữ cho phần biểu tượng
  late IconData calendarIcon; // Thêm biến mới cho icon calendar
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor ?? Colors.blue;
    selectedIcon = Icons.flag; // Giá trị mặc định cho icon thói quen
    calendarIcon =
        widget.initialIcon ??
        Icons.calendar_today; // Icon từ card hoặc mặc định là calendar
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    reminderEnabled = widget.reminderEnabledByDefault ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn biểu tượng'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: iconOptions.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIcon = iconOptions[index];
                      calendarIcon =
                          iconOptions[index]; // Cập nhật cả calendarIcon
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconOptions[index],
                      color: selectedColor,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showColorSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn màu sắc'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: colorOptions.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = colorOptions[index];
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorOptions[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
            // Habit name input với giá trị khởi tạo từ HealthyEatingScreen
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
                  // Trong RegularHabitScreen, thay đổi phần Container hiển thị icon calendar
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      calendarIcon,
                      color: selectedColor,
                    ), // Sử dụng calendarIcon thay vì Icons.calendar_today
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller:
                          _titleController, // Sử dụng controller với giá trị ban đầu
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
                // Icon selector với icon được truyền từ HealthyEatingScreen
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

                // Color selector với màu được truyền từ HealthyEatingScreen
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
                  SettingItem(
                    icon: Icons.flag,
                    iconColor: selectedColor,
                    title: 'Ngày bắt đầu',
                    trailing: Row(
                      children: [
                        Text(
                          'Tháng 3 16, 2025',
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

                  Divider(height: 24),

                  // Daily frequency
                  SettingItem(
                    icon: Icons.repeat,
                    iconColor: selectedColor,
                    title: 'Hằng ngày',
                    trailing: Icon(Icons.close, color: Colors.grey),
                  ),

                  Divider(height: 24),

                  // End time
                  SettingItem(
                    icon: Icons.access_time,
                    iconColor: selectedColor,
                    title: 'Chọn thời gian kết thúc',
                    trailing: Icon(Icons.close, color: Colors.grey),
                  ),

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
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '+ Thêm',
                            style: TextStyle(color: selectedColor),
                          ),
                        ),
                        SizedBox(width: 16),
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
