import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDiaryScreen extends StatefulWidget {
  final Map<String, dynamic>? initData;
  final String? docId;
  const AddDiaryScreen({super.key, this.initData, this.docId});
  @override
  DiaryScreenState createState() => DiaryScreenState();
}

class DiaryScreenState extends State<AddDiaryScreen> {
  final TextEditingController _contentController = TextEditingController();
  int _selectedMoodIndex = 0;
  String selectedColor = "Xanh lá cây";
  Color _activeColor = Colors.green;
  bool hasUnsavedChanges = false;

  // Datetime controller
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    // Fill dữ liệu nếu là sửa diary
    final d = widget.initData;
    if (d != null) {
      _contentController.text = d['content'] ?? '';
      // Xác định index mood:
      final moods = ["😊", "😍", "❤️", "😎", "😴"];
      _selectedMoodIndex = moods.indexOf(d['mood'] ?? "😊");
      selectedColor = d['color'] ?? "Xanh lá cây";
      _activeColor = _colorFromName(selectedColor);
      // Xử lý ngày/giờ
      DateTime date = DateTime.now();
      if (d['date'] != null) {
        if (d['date'] is Timestamp) {
          date = (d['date'] as Timestamp).toDate();
        } else if (d['date'] is DateTime) {
          date = d['date'];
        }
      }
      _selectedDate = date;
      _selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
    }

    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDiaryHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildDiaryEntryField(),
                      _buildMoodSelection(),
                      _buildTimeSettings(),
                      _buildColorSelection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFromName(String colorName) {
    switch (colorName) {
      case "Xanh lá cây":
        return Colors.green;
      case "Xanh da trời":
        return Colors.blue;
      case "Tím":
        return Colors.purple;
      case "Hồng":
        return Colors.pink;
      case "Vàng":
        return Colors.amber;
      case "Cam":
        return Colors.orange;
      case "Xanh ngọc":
        return Colors.teal;
      case "Xanh dương":
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  Widget _buildDiaryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconButton(
            Icons.close_rounded,
            _activeColor,
            () => _handleCloseButton(),
            tooltip: 'Đóng',
          ),
          const Expanded(
            child: Center(
              child: Text(
                "NHẬT KÝ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          _buildIconButton(
            Icons.check_rounded,
            _activeColor,
            () => _saveTodo(),
            tooltip: 'Lưu',
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryEntryField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _activeColor.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 8,
        style: const TextStyle(fontSize: 16, height: 1.5),
        decoration: InputDecoration(
          hintText: "Hôm nay bạn cảm thấy thế nào?",
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    List<Map<String, dynamic>> moods = [
      {"color": Colors.green, "icon": "😊"},
      {"color": Colors.pink, "icon": "😍"},
      {"color": Colors.red, "icon": "❤️"},
      {"color": Colors.amber, "icon": "😎"},
      {"color": Colors.blue, "icon": "😴"},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_emotions_outlined,
                    color: _activeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Cảm xúc của bạn",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 8),
          const SizedBox(height: 16),

          // Mood selectors - responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate item width based on available width
              final double totalWidth = constraints.maxWidth;
              // Allow each item to be responsive but with min/max size
              final double itemWidth =
                  totalWidth < 350
                      ? totalWidth / moods.length
                      : totalWidth < 500
                      ? 65
                      : 80;

              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics:
                      totalWidth < (itemWidth * moods.length)
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: itemWidth,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMoodIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedMoodIndex == index
                                    ? moods[index]["color"].withOpacity(0.12)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  _selectedMoodIndex == index
                                      ? moods[index]["color"]
                                      : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emoji with background
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _selectedMoodIndex == index
                                          ? moods[index]["color"].withOpacity(
                                            0.2,
                                          )
                                          : Colors.grey.withOpacity(0.08),
                                ),
                                child: Center(
                                  child: Text(
                                    moods[index]["icon"],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.calendar_today_rounded,
            text: "Thời gian",
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.calendar_month_rounded,
              text: DateFormat('dd/MM/yyyy').format(_selectedDate),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectTime(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.access_time_rounded,
              text: _formatTimeOfDay(_selectedTime),
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _activeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _activeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    final format = DateFormat.jm();
    return format.format(dt);
  }

  Widget _buildSettingRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _activeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _activeColor, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTimeSettingRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _activeColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    List<Color> colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.amber,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.palette, color: _activeColor, size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                "Màu sắc",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(colors.length, (index) {
              bool isSelected = colors[index] == _activeColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeColor = colors[index];
                    // Update color name
                    switch (index) {
                      case 0:
                        selectedColor = "Xanh lá cây";
                        break;
                      case 1:
                        selectedColor = "Xanh da trời";
                        break;
                      case 2:
                        selectedColor = "Tím";
                        break;
                      case 3:
                        selectedColor = "Hồng";
                        break;
                      case 4:
                        selectedColor = "Vàng";
                        break;
                      case 5:
                        selectedColor = "Cam";
                        break;
                      case 6:
                        selectedColor = "Xanh ngọc";
                        break;
                      case 7:
                        selectedColor = "Xanh dương";
                        break;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: colors[index].withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                            : null,
                    border:
                        isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                          : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleCloseButton() {
    if (hasUnsavedChanges || _contentController.text.isNotEmpty) {
      _showDiscardChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy thay đổi?'),
          content: const Text(
            'Bạn có thay đổi chưa lưu. Bạn có muốn hủy bỏ những thay đổi này không?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('TIẾP TỤC CHỈNH SỬA'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('HỦY BỎ'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.of(context).pop(); // Đóng màn hình nhật ký
              },
            ),
          ],
        );
      },
    );
  }

  void _saveTodo() async {
    if (_contentController.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Thiếu nội dung'),
              content: Text('Vui lòng nhập nội dung nhật ký!'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
      return;
    }

    final moodList = ["😊", "😍", "❤️", "😎", "😴"];
    final mood = moodList[_selectedMoodIndex];
    Map<String, dynamic> diaryData = {
      "content": _contentController.text,
      "mood": mood,
      "color": selectedColor,
      "created_at": FieldValue.serverTimestamp(),
      "date": DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    };

    try {
      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('diaries')
            .doc(widget.docId)
            .update(diaryData);
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Cập nhật nhật ký thành công!'),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Đóng'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        Navigator.of(context).pop(); // Đóng màn sửa
                      },
                    ),
                  ],
                ),
          );
        }
      } else {
        await FirebaseFirestore.instance.collection('diaries').add(diaryData);
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Lưu nhật ký thành công!'),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Đóng'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        Navigator.of(context).pop(); // Đóng màn thêm
                      },
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Lỗi'),
                content: Text('Không thể lưu nhật ký: $e'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      }
    }
  }
}