import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  DiaryScreenState createState() => DiaryScreenState();
}

class DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedMoodIndex = 0;
  bool _timeEnabled = true;
  bool _reminderEnabled = false;
  String selectedColor = "Xanh lá cây";
  Color _activeColor = Colors.green;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  
  // Biến để theo dõi nếu có thay đổi chưa lưu
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Thêm listeners để theo dõi thay đổi
    _titleController.addListener(_onTextChanged);
    _detailsController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    // Hủy controllers khi widget bị hủy
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
  
  // Theo dõi khi có thay đổi trong form
  void _onTextChanged() {
    if (!hasUnsavedChanges) {
      setState(() {
        hasUnsavedChanges = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    body: Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDiaryHeader(),
          Expanded(child: _buildDiaryEntryField()),
          _buildMoodSelection(),
          _buildTimeSettings(),
          _buildColorSelection(),
         
        ],
      ),
    )
    );
  }

  Widget _buildDiaryHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _handleCloseButton();
            },
            child: Icon(Icons.close, color: Colors.green),
          ),
          Expanded(
            child: Center(
              child: Text(
                "DIARY",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
             _saveTodo();
            },
            child: Icon(Icons.check, color: Colors.green),
          ),
        ],
      ),
    );
  }

  void _handleCloseButton() {
    // Kiểm tra nếu có thay đổi chưa lưu
    if (hasUnsavedChanges || 
        _titleController.text.isNotEmpty || 
        _detailsController.text.isNotEmpty) {
      _showDiscardChangesDialog();
    } else {
      // Không có thay đổi, thoát trực tiếp
      Navigator.of(context).pop();
    }
  }
  
  // Hiển thị hộp thoại xác nhận khi có thay đổi chưa lưu
  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy thay đổi?'),
          content: const Text('Bạn có thay đổi chưa lưu. Bạn có muốn hủy bỏ những thay đổi này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('TIẾP TỤC CHỈNH SỬA'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('HỦY BỎ'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
            ),
          ],
        );
      },
    );
  }
  
  // Lưu todo
  void _saveTodo() {
    // Kiểm tra xem có dữ liệu để lưu không
    if (_titleController.text.isEmpty) {
      // Hiển thị thông báo nếu tiêu đề trống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Thực hiện lưu dữ liệu (có thể thêm logic lưu vào cơ sở dữ liệu ở đây)
    
    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu công việc'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Quay lại màn hình trước
    Navigator.of(context).pop();
  }

  Widget _buildDiaryEntryField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _controller,
        maxLines: null,
        decoration: InputDecoration(
          hintText: "Bạn có khỏe không?",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    List<Map<String, dynamic>> moods = [
      {"color": Colors.green, "icon": "😊", "outfit": "green stripe"},
      {"color": Colors.pink, "icon": "😍", "outfit": "pink stripe"},
      {"color": Colors.red, "icon": "❤️", "outfit": "red stripe"},
      {"color": Colors.amber, "icon": "😎", "outfit": "yellow stripe"},
      {"color": Colors.blue, "icon": "😴", "outfit": "blue stripe"},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chọn biểu tượng cảm xúc",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(moods.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMoodIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _selectedMoodIndex == index
                            ? Colors.green.withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Text(
                        moods[index]["icon"],
                        style: TextStyle(fontSize: 24),
                      ),
                      Container(
                        width: 40,
                        height: 30,
                        child: CustomPaint(
                          painter: CatIconPainter(color: moods[index]["color"]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettings() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.calendar_today,
            text: "Thời gian",
            hasSwitch: true,
            switchValue: _timeEnabled,
            onSwitchChanged: (value) {
              setState(() {
                _timeEnabled = value;
              });
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingRow(
                  icon: Icons.calendar_month,
                  text: "21/03/2025",
                  hasSwitch: false,
                ),
                _buildSettingRow(
                  icon: Icons.access_time,
                  text: "11:20 CH",
                  hasSwitch: false,
                ),
              ],
            ),
          ),
          _buildSettingRow(
            icon: Icons.push_pin,
            text: "Ghim",
            hasSwitch: true,
            switchValue: _reminderEnabled,
            onSwitchChanged: (value) {
              setState(() {
                _reminderEnabled = value;
              });
            },
          ),
          Divider(),
          _buildColorSelectionRow(),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String text,
    required bool hasSwitch,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 16),
          Text(text, style: TextStyle(fontSize: 16)),
          Spacer(),
          if (hasSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withOpacity(0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildColorSelectionRow() {
    return InkWell(
      onTap: () {
        // Open color picker
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.palette, color: Colors.green, size: 20),
            SizedBox(width: 16),
            Text(selectedColor, style: TextStyle(fontSize: 16)),
            Spacer(),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelection() {
    List<Color> colors = [
      Colors.green,
      Colors.amber,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.black,
      Colors.teal,
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(colors.length, (index) {
          bool isSelected = colors[index] == _activeColor;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeColor = colors[index];
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border:
                    isSelected
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
              ),
              child:
                  index == colors.length - 1
                      ? Icon(Icons.palette, color: Colors.white, size: 16)
                      : null,
            ),
          );
        }),
      ),
    );
  }

}

class CatIconPainter extends CustomPainter {
  final Color color;

  CatIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw a simple cat shape
    final catHeadPath =
        Path()..addOval(
          Rect.fromLTWH(
            size.width * 0.3,
            size.height * 0.1,
            size.width * 0.4,
            size.height * 0.4,
          ),
        );

    final catBodyPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.2,
              size.height * 0.4,
              size.width * 0.6,
              size.height * 0.5,
            ),
            Radius.circular(10),
          ),
        );

    canvas.drawPath(catHeadPath, paint);
    canvas.drawPath(catBodyPath, paint);

    // Draw stripes
    final stripePaint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.25,
            size.height * (0.5 + i * 0.1),
            size.width * 0.5,
            size.height * 0.05,
          ),
          Radius.circular(2),
        ),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
