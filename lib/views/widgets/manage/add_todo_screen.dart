import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _isAllDayEnabled = false;
  bool _reminderEnabled = false;
  bool _isPinnedEnabled = false;
  bool _isRepeatEnabled = false;
  Color _activeColor = Colors.green;
  String selectedColor = "Xanh lá cây";
  bool hasUnsavedChanges = false;
  
  // Datetime controllers
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
  DateTime.now().add(const Duration(hours: 1)),
);

  
  String _reminderTime = "15 phút trước";

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _detailsController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
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
              _buildTodoHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTodoEntryFields(),
                      _buildDateTimeSection(),
                      _buildReminderSection(),
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

  Widget _buildTodoHeader() {
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
                "TO DO",
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
    VoidCallback onTap, 
    {String? tooltip}
  ) {
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

  Widget _buildTodoEntryFields() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _activeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Tiêu đề",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Thêm chi tiết",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today_rounded, color: _activeColor, size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                "Thời gian",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () => _selectStartDate(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.arrow_forward_rounded,
              text: DateFormat('dd/MM/yyyy').format(_startDate),
              trailing: _formatTimeOfDay(_startTime),
              showArrow: true,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectEndDate(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.arrow_back_rounded,
              text: DateFormat('dd/MM/yyyy').format(_endDate),
              trailing: _formatTimeOfDay(_endTime),
              showArrow: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
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
            icon: Icons.notifications_none_rounded,
            text: "Cài đặt nhắc nhở",
            hasSwitch: true,
            switchValue: _reminderEnabled,
            onSwitchChanged: (value) {
              setState(() {
                _reminderEnabled = value;
              });
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _reminderEnabled ? null : 0,
            child: AnimatedOpacity(
              opacity: _reminderEnabled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  const Divider(height: 24),
                  InkWell(
                    onTap: () => _showReminderOptions(context),
                    borderRadius: BorderRadius.circular(8),
                    child: _buildTimeSettingRow(
                      icon: Icons.access_time_rounded,
                      text: _reminderTime,
                      showClose: true,
                      onClose: () {
                        setState(() {
                          _reminderEnabled = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _showReminderOptions(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _activeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add, color: _activeColor, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Thêm nhắc nhở",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _activeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              Text(
                selectedColor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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
                    switch(index) {
                      case 0: selectedColor = "Xanh lá cây"; break;
                      case 1: selectedColor = "Xanh da trời"; break;
                      case 2: selectedColor = "Tím"; break;
                      case 3: selectedColor = "Hồng"; break;
                      case 4: selectedColor = "Vàng"; break;
                      case 5: selectedColor = "Cam"; break;
                      case 6: selectedColor = "Xanh ngọc"; break;
                      case 7: selectedColor = "Xanh dương"; break;
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
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors[index].withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            }),
          ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (hasSwitch)
          Switch(
            value: switchValue,
            onChanged: onSwitchChanged,
            activeColor: _activeColor,
            activeTrackColor: _activeColor.withOpacity(0.4),
          ),
      ],
    );
  }

  Widget _buildTimeSettingRow({
    required IconData icon,
    required String text,
    String? trailing,
    bool showArrow = false,
    bool showClose = false,
    VoidCallback? onClose,
  }) {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (showArrow)
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          if (showClose)
            IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.grey[400]),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
    
    if (!_isAllDayEnabled) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime,
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
      if (pickedTime != null && pickedTime != _startTime) {
        setState(() {
          _startTime = pickedTime;
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
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
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
    
    if (!_isAllDayEnabled) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime,
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
      if (pickedTime != null && pickedTime != _endTime) {
        setState(() {
          _endTime = pickedTime;
        });
      }
    }
  }

  void _showReminderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Nhắc nhở",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...[
                "Tại thời điểm bắt đầu",
                "5 phút trước",
                "15 phút trước",
                "30 phút trước",
                "1 giờ trước",
                "1 ngày trước",
              ].map((option) => ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    _reminderTime = option;
                    _reminderEnabled = true;
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showRepeatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Lặp lại",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...[
                "Không lặp lại",
                "Hàng ngày",
                "Hàng tuần",
                "Hàng tháng",
                "Hàng năm",
              ].map((option) => ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    _isRepeatEnabled = option != "Không lặp lại";
                  });
                  Navigator.pop(context);
                },
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _handleCloseButton() {
    if (hasUnsavedChanges || 
        _titleController.text.isNotEmpty || 
        _detailsController.text.isNotEmpty) {
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
          content: const Text('Bạn có thay đổi chưa lưu. Bạn có muốn hủy bỏ những thay đổi này không?'),
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
                Navigator.of(context).pop(); // Đóng màn hình to do
              },
            ),
          ],
        );
      },
    );
  }
  
  void _saveTodo() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tiêu đề'),
          backgroundColor: _activeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }
    
    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu công việc thành công'),
        backgroundColor: _activeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
    
    Navigator.of(context).pop();
  }
}

// Extension for adding hours to TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    return replacing(
      hour: this.hour + hour,
      minute: this.minute + minute,
    );
  }
}