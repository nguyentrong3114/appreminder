import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TodoScreen extends StatefulWidget {
  final DateTime? initialStartDate;
  final DocumentSnapshot? todoDoc;
  const TodoScreen({super.key, this.initialStartDate, this.todoDoc});

  @override
  State<TodoScreen> createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _isAllDayEnabled = false;
  bool _reminderEnabled = false;
  Color _activeColor = Colors.green;
  String selectedColor = "Xanh lá cây";
  bool hasUnsavedChanges = false;

  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  String _reminderTime = "";

  // Notification plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _detailsController.addListener(_onTextChanged);
    _initNotifications();
    _requestNotificationPermission();

    if (widget.todoDoc != null) {
      final data = widget.todoDoc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _detailsController.text = data['details'] ?? '';
      _startDate = DateTime.parse(data['startDateTime']);
      _endDate = DateTime.parse(data['endDateTime']);
      _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
      _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      selectedColor = data['color'] ?? "Xanh lá cây";
      _reminderEnabled = data['reminderEnabled'] ?? false;
      _reminderTime = data['reminderTime'] ?? "";
      _updateActiveColor();
    } else {
      _startDate = widget.initialStartDate ?? DateTime.now();
      _startTime = TimeOfDay.now();
      _endDate = _startDate;
      _endTime = _startTime.add(hour: 1);
    }
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
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
      case "Xanh dương":
        _activeColor = Colors.indigo;
        break;
    }
  }

  void _initNotifications() async {
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   // Handle notification received on iOS
      //   print('Received notification: $title - $body');
      // },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
    
    print('Notifications initialized: $initialized');
    
    // Tạo notification channel cho Android
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'todo_reminder_channel',
          'Nhắc nhở nhiệm vụ',
          description: 'Thông báo nhắc nhở nhiệm vụ sắp đến hạn',
          importance: Importance.max,
          // priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  } catch (e) {
    print('Error initializing notifications: $e');
  }
}

  Future<bool> _checkAndRequestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      bool shouldRequest = await _showPermissionDialog();
      if (!shouldRequest) return false;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      } else {
        status = await Permission.notification.request();
        return status.isGranted;
      }
    }

    return false;
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cần quyền thông báo'),
              content: const Text(
                'Ứng dụng cần quyền thông báo để có thể nhắc nhở bạn về các nhiệm vụ. '
                'Vui lòng cấp quyền trong cài đặt.',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  child: const Text('HỦY'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('CÀI ĐẶT'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _scheduleNotificationForOption(String option) async {
    // Kiểm tra quyền thông báo trước
    bool hasPermission = await _checkAndRequestNotificationPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cần cấp quyền thông báo để sử dụng tính năng nhắc nhở',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int minutesBefore = _getMinutesFromOption(option);

    DateTime startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime notificationTime = startDateTime.subtract(
      Duration(minutes: minutesBefore),
    );

    // Debug: In ra thời gian thông báo
    print('Notification time: $notificationTime');
    print('Current time: ${DateTime.now()}');
    print('Is after now: ${notificationTime.isAfter(DateTime.now())}');

    if (notificationTime.isAfter(DateTime.now())) {
      // Tạo ID duy nhất dựa trên thời gian và title
      int notificationId =
          '${_titleController.text}${startDateTime.millisecondsSinceEpoch}'
              .hashCode;

      await _scheduleNotification(
        id: notificationId,
        title: 'Nhắc nhở nhiệm vụ',
        body:
            _titleController.text.isNotEmpty
                ? _titleController.text
                : 'Bạn có một nhiệm vụ sắp bắt đầu',
        scheduledTime: notificationTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lên lịch nhắc nhở $option lúc ${DateFormat('HH:mm dd/MM/yyyy').format(notificationTime)}',
          ),
          backgroundColor: _activeColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian nhắc nhở phải sau thời điểm hiện tại'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveNotificationId(int notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId.toString())
            .set({
              'notificationId': notificationId,
              'todoTitle': _titleController.text,
              'scheduledTime': DateTime.now().toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        print('Error saving notification ID: $e');
      }
    }
  }

  int _getMinutesFromOption(String option) {
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

  Future<void> _scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  try {
    // Cancel notification cũ nếu có
    await flutterLocalNotificationsPlugin.cancel(id);
    
    // Tạo TZDateTime từ scheduledTime
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    print('Scheduling notification:');
    print('ID: $id');
    print('Title: $title');
    print('Body: $body');
    print('Scheduled time: $scheduledTZTime');
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminder_channel',
          'Nhắc nhở nhiệm vụ',
          channelDescription: 'Thông báo nhắc nhở nhiệm vụ sắp đến hạn',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          // Thêm các thuộc tính này để đảm bảo thông báo hiển thị
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    
    print('Notification scheduled successfully');
  } catch (e) {
    print('Error scheduling notification: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lên lịch thông báo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _scheduleTestNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(seconds: 5));
      final tzTestTime = tz.TZDateTime.from(testTime, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        999999, // ID test khác biệt
        'Test Notification',
        'Đây là thông báo test sau 5 giây',
        tzTestTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_reminder_channel',
            'Nhắc nhở nhiệm vụ',
            channelDescription: 'Thông báo nhắc nhở nhiệm vụ sắp đến hạn',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Test notification scheduled for: $tzTestTime');
    } catch (e) {
      print('Error scheduling test notification: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> saveTodoToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để lưu công việc');
    }
    String title = _titleController.text;
    String details = _detailsController.text;
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

    if (widget.todoDoc != null) {
      await widget.todoDoc!.reference.update({
        'title': title,
        'details': details,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
        'reminderEnabled': _reminderEnabled,
        'reminderTime': _reminderEnabled ? _reminderTime : "",
        'color': selectedColor,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add({
            'title': title,
            'details': details,
            'startDateTime': startDateTime.toIso8601String(),
            'endDateTime': endDateTime.toIso8601String(),
            'reminderEnabled': _reminderEnabled,
            'reminderTime': _reminderEnabled ? _reminderTime : "",
            'color': selectedColor,
            'createdAt': DateTime.now().toIso8601String(),
            'isDone': false,
          });
    }
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
                if (!value) _reminderTime = "";
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
                  if (_reminderTime.isNotEmpty)
                    InkWell(
                      onTap: () => _showReminderOptions(context),
                      borderRadius: BorderRadius.circular(8),
                      child: _buildTimeSettingRow(
                        icon: Icons.access_time_rounded,
                        text: _reminderTime,
                        showClose: true,
                        onClose: () {
                          setState(() {
                            _reminderTime = "";
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

  void _showReminderOptions(BuildContext context) async {
    // Kiểm tra quyền trước khi hiển thị options
    bool hasPermission = await _checkAndRequestNotificationPermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cần cấp quyền thông báo để sử dụng tính năng nhắc nhở',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'CÀI ĐẶT',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    }

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
                        _scheduleNotificationForOption(option);
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveTodo() async {
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

    await saveTodoToFirestore();

    if (_reminderEnabled && _reminderTime.isNotEmpty) {
      bool hasPermission = await _checkAndRequestNotificationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cần cấp quyền thông báo để sử dụng tính năng nhắc nhở',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'CÀI ĐẶT',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      } else {
        _scheduleNotificationForOption(_reminderTime);
      }
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
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add({int hour = 0, int minute = 0}) {
    int totalMinutes = (this.hour * 60 + this.minute) + (hour * 60 + minute);

    // Đảm bảo không vượt quá 24 giờ
    totalMinutes = totalMinutes % (24 * 60);
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }

    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }
}
