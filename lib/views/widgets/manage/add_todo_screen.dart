import 'package:flutter/material.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/todo.dart';
import 'package:flutter_app/services/notification_service.dart';
import 'package:provider/provider.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? existingTodo;
  final DateTime? initialStartDate;
  const AddTodoScreen({super.key, this.existingTodo, this.initialStartDate});

  @override
  State<AddTodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  Color _activeColor = Colors.green;
  String selectedColor = "Xanh lá cây";
  bool _reminderEnabled = false;
  String? _reminderTime;
  bool hasUnsavedChanges = false;

  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isDone = false;
  List<Map<String, dynamic>> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _detailsController.addListener(_onTextChanged);

    if (widget.existingTodo != null) {
      final todo = widget.existingTodo!;
      _titleController.text = todo.title;
      _detailsController.text = todo.details ?? '';
      _startDate = todo.startDateTime;
      _endDate = todo.endDateTime;
      _startTime = TimeOfDay(
        hour: todo.startDateTime.hour,
        minute: todo.startDateTime.minute,
      );
      _endTime = TimeOfDay(
        hour: todo.endDateTime.hour,
        minute: todo.endDateTime.minute,
      );
      selectedColor = todo.colorValue;
      _reminderEnabled = todo.reminderEnabled;
      _reminderTime = todo.reminderTime;
      _isDone = todo.isDone;
      _tags = todo.tags;
      _updateActiveColor();
    } else {
      _startDate = widget.initialStartDate ?? DateTime.now();
      _startTime = TimeOfDay.now();
      _endDate = _startDate;
      _endTime = _startTime.add(hour: 1);
    }
  }

  void _updateActiveColor() {
    switch (selectedColor) {
      case "Xanh lá cây":
        _activeColor = Colors.green;
        break;
      case "Xanh da trời":
        _activeColor = Colors.blue;
        break;
      case "Tím":
        _activeColor = Colors.purple;
        break;
      case "Hồng":
        _activeColor = Colors.pink;
        break;
      case "Vàng":
        _activeColor = Colors.amber;
        break;
      case "Cam":
        _activeColor = Colors.orange;
        break;
      case "Xanh ngọc":
        _activeColor = Colors.teal;
        break;
      case "Xanh dương đậm":
        _activeColor = Colors.indigo;
        break;
    }
  }

  int _getMinutesFromOption(String? option) {
    switch (option) {
      case "Tại thời điểm bắt đầu":
        return 0;
      case "5 phút trước":
        return 5;
      case "10 phút trước":
        return 10;
      case "15 phút trước":
        return 15;
      case "30 phút trước":
        return 30;
      case "1 giờ trước":
        return 60;
      case "1 ngày trước":
        return 1440;
      default:
        return 0;
    }
  }

  Future<void> _scheduleTodoNotification(Todo todo) async {
    if (!todo.reminderEnabled || todo.reminderTime == null) return;
    int minutesBefore = _getMinutesFromOption(todo.reminderTime);
    DateTime notificationTime = todo.startDateTime.subtract(
      Duration(minutes: minutesBefore),
    );
    if (notificationTime.isBefore(DateTime.now())) return;
    int notificationId = todo.id.hashCode;
    await NotificationService().scheduleOnetimeTaskNotification(
      id: notificationId,
      title:
          todo.title.isNotEmpty
              ? todo.title
              : 'Bạn có một nhiệm vụ sắp bắt đầu',
      scheduledDate: notificationTime,
      scheduledTime: TimeOfDay(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
      ),
    );
  }

  Future<void> _cancelOldNotification(Todo oldTodo) async {
    int notificationId = oldTodo.id.hashCode;
    await NotificationService().cancelNotification(notificationId);
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.isEmpty) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Lỗi'),
              content: const Text('Vui lòng nhập tiêu đề'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để lưu công việc');
    }

    DateTime startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    DateTime endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final todo = Todo(
      id: widget.existingTodo?.id ?? UniqueKey().toString(),
      title: _titleController.text,
      details: _detailsController.text,
      colorValue: selectedColor,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled ? _reminderTime : null,
      isDone: _isDone,
      tags: _tags,
      createdAt: widget.existingTodo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Nếu là chỉnh sửa, huỷ notification cũ trước khi lên lịch lại
    if (widget.existingTodo != null) {
      await _cancelOldNotification(widget.existingTodo!);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('todos')
        .doc(todo.id)
        .set(todo.toJson());

    // Lên lịch notification mới nếu cần
    if (todo.reminderEnabled && todo.reminderTime != null) {
      await _scheduleTodoNotification(todo);
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Đã lưu công việc thành công!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    if (!mounted) return;
    Navigator.of(context).pop('edited');
  }

  void _onTextChanged() {
    if (!hasUnsavedChanges) {
      setState(() {
        hasUnsavedChanges = true;
      });
    }
  }

  void _showReminderOptions(BuildContext context) async {
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
                    "10 phút trước",
                    "15 phút trước",
                    "30 phút trước",
                    "1 giờ trước",
                    "1 ngày trước",
                  ]
                  .map(
                    (option) => ListTile(
                      title: Text(option),
                      onTap: () {
                        setState(() {
                          _reminderTime = option;
                          _reminderEnabled = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(BuildContext context, TimeOfDay time) {
    final is24Hour = context.watch<SettingProvider>().use24HourFormat;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return is24Hour
        ? DateFormat('HH:mm').format(dt)
        : DateFormat('hh:mm a').format(dt);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
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
      final is24Hour = context.read<SettingProvider>().use24HourFormat;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(alwaysUse24HourFormat: is24Hour),
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
            () => Navigator.of(context).pop(),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final dateFormat = context.watch<SettingProvider>().dateFormat;
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
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: _activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Thời gian",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () => _selectStartDate(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.arrow_forward_rounded,
              text: DateFormat(
                dateFormat,
              ).format(_startDate), // Sử dụng định dạng động
              trailing: _formatTimeOfDay(context, _startTime),
              showArrow: true,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectEndDate(context),
            borderRadius: BorderRadius.circular(8),
            child: _buildTimeSettingRow(
              icon: Icons.arrow_back_rounded,
              text: DateFormat(dateFormat).format(_startDate),
              trailing: _formatTimeOfDay(context, _startTime),
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
                if (!value) _reminderTime = null;
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
                  if (_reminderTime != null)
                    InkWell(
                      onTap: () => _showReminderOptions(context),
                      borderRadius: BorderRadius.circular(8),
                      child: _buildTimeSettingRow(
                        icon: Icons.access_time_rounded,
                        text: _reminderTime!,
                        showClose: true,
                        onClose: () {
                          setState(() {
                            _reminderTime = null;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _showReminderOptions(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _activeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: _activeColor,
                              size: 20,
                            ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
}

// Extension để cộng giờ cho TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    int totalMinutes = (this.hour * 60 + this.minute) + (hour * 60 + minute);
    totalMinutes = totalMinutes % (24 * 60);
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }
}
