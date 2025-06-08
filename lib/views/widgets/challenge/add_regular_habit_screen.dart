import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';
import '../../../models/habit.dart';
import '../../../services/habit_service.dart';
import '../../../services/notification_service.dart';

final NotificationService notificationService = NotificationService();

class RegularHabitScreen extends StatefulWidget {
  final String? initialTitle;
  final IconData? initialIcon;
  final Color? initialColor;
  final bool? reminderEnabledByDefault;
  final DateTime? initialStartDate;
  final String? formattedStartDate;
  // ✅ THÊM CÁC PARAMETER CHO EDITING
  final Habit? existingHabit; // Habit cần edit
  final bool isEditing; // Flag để biết đang edit hay tạo mới

  const RegularHabitScreen({
    Key? key,
    this.initialTitle,
    this.initialIcon,
    this.initialColor,
    this.reminderEnabledByDefault,
    this.initialStartDate,
    this.formattedStartDate,
    this.existingHabit, // ✅ THÊM
    this.isEditing = false, // ✅ THÊM (default = false)
  }) : super(key: key);

  @override
  _RegularHabitScreenState createState() => _RegularHabitScreenState();
}

class Tag {
  String id;
  String name;
  Color color;

  Tag({required this.id, required this.name, required this.color});
}

// enum RepeatType { daily, weekly, monthly, yearly } // Removed, use from models/habit.dart
// Make sure to only use RepeatType from models/habit.dart

class _RegularHabitScreenState extends State<RegularHabitScreen> {
  late bool reminderEnabled;
  bool streakEnabled = false;
  late Color selectedColor;
  late IconData selectedIcon;
  late IconData calendarIcon;
  late TextEditingController _titleController;
  late DateTime startDate;
  late String formattedStartDate;
  List<TimeOfDay> reminders = [];
  List<Tag> tags = [];
  final HabitService _habitService = HabitService();
  bool _isSaving = false;
  // Helper methods để chuyển đổi dữ liệu
  String _iconToString(IconData icon) {
    return icon.codePoint.toString();
  }

  String _colorToString(Color color) {
    return color.value.toString();
  }

  List<String> _timeOfDayListToStringList(List<TimeOfDay> times) {
    return times
        .map(
          (time) =>
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        )
        .toList();
  }

  List<Map<String, dynamic>> _tagsToMap(List<Tag> tags) {
    return tags
        .map(
          (tag) => {
            'id': tag.id,
            'name': tag.name,
            'color': _colorToString(tag.color),
          },
        )
        .toList();
  }

  Future<void> _scheduleRegularHabitNotifications(
    String habitId,
    String title,
  ) async {
    if (!reminderEnabled || reminders.isEmpty) {
      print('❌ Không có thông báo nào để lên lịch');
      return;
    }

    // Hủy các thông báo cũ
    await notificationService.cancelHabitNotifications(
      habitId,
      reminders.length * 100,
    );

    // Lên lịch mới theo repeat type
    switch (repeatType) {
      case RepeatType.daily:
        await notificationService.scheduleRegularHabitDaily(
          habitId: habitId,
          title: title,
          reminderTimes: reminders,
          startDate: startDate,
        );
        break;
      case RepeatType.weekly:
        await notificationService.scheduleRegularHabitWeekly(
          habitId: habitId,
          title: title,
          reminderTimes: reminders,
          selectedWeekdays: selectedWeekdays,
          startDate: startDate,
        );
        break;
      case RepeatType.monthly:
        await notificationService.scheduleRegularHabitMonthly(
          habitId: habitId,
          title: title,
          reminderTimes: reminders,
          selectedMonthlyDays: selectedMonthlyDays,
          startDate: startDate,
        );
        break;
      case RepeatType.yearly:
        await notificationService.scheduleRegularHabitYearly(
          habitId: habitId,
          title: title,
          reminderTimes: reminders,
          startDate: startDate,
        );
        break;
    }

    print('✅ Đã lên lịch tất cả notifications cho habit: $title');
    await notificationService.debugNotificationStatus();
  }

  // Cập nhật hàm lưu trong nút "Lưu"
  Future<void> _saveHabit() async {
    // Validation trước khi lưu
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tên thử thách'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra ngày bắt đầu không được trong quá khứ
    if (startDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ngày bắt đầu không được trong quá khứ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation cho weekly repeat
    if (repeatType == RepeatType.weekly && selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất một ngày trong tuần'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation cho endDate
    if (hasEndDate && endDate != null && endDate!.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ngày kết thúc phải sau ngày bắt đầu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();

      final habit = Habit(
        id:
            widget.isEditing
                ? widget.existingHabit!.id
                : '', // ✅ Giữ ID khi edit
        title: _titleController.text.trim(),
        iconCodePoint: _iconToString(selectedIcon),
        colorValue: _colorToString(selectedColor),
        startDate: startDate,
        endDate: hasEndDate ? endDate : null,
        hasEndDate: hasEndDate,
        type: HabitType.regular,
        repeatType: repeatType,
        selectedWeekdays: selectedWeekdays,
        selectedMonthlyDays: selectedMonthlyDays,
        reminderEnabled: reminderEnabled,
        reminderTimes: _timeOfDayListToStringList(reminders),
        streakEnabled: streakEnabled,
        tags: _tagsToMap(tags),
        createdAt: widget.isEditing ? widget.existingHabit!.createdAt : now,
        updatedAt: now,
      );

      // ✅ CHỌN METHOD PHÙ HỢP
      String habitId;
      if (widget.isEditing) {
        await _habitService.updateHabit(habit); // Update existing
        habitId = habit.id;
      } else {
        habitId = await _habitService.saveHabit(habit); // Create new
      }
      await _scheduleRegularHabitNotifications(habitId, habit.title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Đã cập nhật thử thách thành công!'
                : 'Đã lưu thử thách thành công!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, habitId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu thử thách: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  RepeatType repeatType = RepeatType.daily;
  DateTime? endDate;
  bool hasEndDate = false;
  List<int> selectedWeekdays = [];
  List<int> selectedMonthlyDays = [];

  // Getter cho text hiển thị với thông tin chi tiết
  String get repeatTypeText {
    switch (repeatType) {
      case RepeatType.daily:
        return 'Hằng ngày';
      case RepeatType.weekly:
        return 'Hằng tuần';
      case RepeatType.monthly:
        return 'Hằng tháng';
      case RepeatType.yearly:
        return 'Hằng năm';
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ NẾU ĐANG EDIT, LOAD DỮ LIỆU TỪ EXISTING HABIT
    if (widget.isEditing && widget.existingHabit != null) {
      _loadExistingHabitData();
    } else {
      _initializeNewHabit();
    }
  }

  // ✅ PHƯƠNG THỨC LOAD DỮ LIỆU KHI EDIT
  void _loadExistingHabitData() {
    final habit = widget.existingHabit!;

    // Load basic data
    _titleController = TextEditingController(text: habit.title);
    selectedColor = Color(int.parse(habit.colorValue));
    selectedIcon = IconData(
      int.parse(habit.iconCodePoint),
      fontFamily: 'MaterialIcons',
    );
    calendarIcon = selectedIcon;

    // Load dates
    startDate = habit.startDate;
    endDate = habit.endDate;
    hasEndDate = habit.hasEndDate;
    formattedStartDate = DateFormat('MMMM d, yyyy', 'vi_VN').format(startDate);

    // Load repeat settings
    repeatType = habit.repeatType;
    selectedWeekdays = List<int>.from(habit.selectedWeekdays);
    selectedMonthlyDays = List<int>.from(habit.selectedMonthlyDays);

    // Load reminder settings
    reminderEnabled = habit.reminderEnabled;
    reminders =
        habit.reminderTimes.map((timeString) {
          List<String> parts = timeString.split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();

    // Load tags
    streakEnabled = habit.streakEnabled;
    tags =
        habit.tags
            .map(
              (tagMap) => Tag(
                id: tagMap['id'],
                name: tagMap['name'],
                color: Color(int.parse(tagMap['color'])),
              ),
            )
            .toList();
  }

  // ✅ PHƯƠNG THỨC KHỞI TẠO KHI TẠO MỚI
  void _initializeNewHabit() {
    final List<Color> availableColors = [
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

    final random = Random();
    selectedColor =
        widget.initialColor ??
        availableColors[random.nextInt(availableColors.length)];
    selectedIcon = iconOptions[random.nextInt(iconOptions.length)];
    calendarIcon = selectedIcon;

    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    reminderEnabled = widget.reminderEnabledByDefault ?? false;

    DateTime now = DateTime.now();
    DateTime providedStartDate = widget.initialStartDate ?? now;
    startDate = providedStartDate.isBefore(now) ? now : providedStartDate;

    selectedWeekdays = [startDate.weekday];
    selectedMonthlyDays = [startDate.day];

    formattedStartDate =
        widget.formattedStartDate ??
        DateFormat('MMMM d, yyyy', 'vi_VN').format(startDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

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

  final List<Color> colorOptions = [
    Colors.black,
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFF81C784),
    Colors.transparent,
  ];

  void _showRepeatTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Chọn loại lặp lại',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 24),

                    ...RepeatType.values
                        .map(
                          (type) =>
                              _buildRepeatTypeOption(type, setDialogState),
                        )
                        .toList(),

                    SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showRepeatDetailsDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepeatTypeOption(RepeatType type, StateSetter setDialogState) {
    bool isSelected = repeatType == type;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setDialogState(() {
            repeatType = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected ? selectedColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? selectedColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? selectedColor : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRepeatTypeText(type),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? selectedColor : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getRepeatTypeDescription(type),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? selectedColor : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return 'Hằng ngày';
      case RepeatType.weekly:
        return 'Hằng tuần';
      case RepeatType.monthly:
        return 'Hằng tháng';
      case RepeatType.yearly:
        return 'Hằng năm';
    }
  }

  String _getRepeatTypeDescription(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return 'Lặp lại mỗi ngày';
      case RepeatType.weekly:
        return 'Lặp lại theo tuần';
      case RepeatType.monthly:
        return 'Lặp lại theo tháng';
      case RepeatType.yearly:
        return 'Lặp lại theo năm';
    }
  }

  void _showRepeatDetailsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getRepeatTypeIcon(repeatType),
                              color: selectedColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cài đặt ${_getRepeatTypeText(repeatType)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 32, color: Colors.grey[300]),

                      if (repeatType == RepeatType.daily)
                        _buildDailyOptions(setDialogState),
                      if (repeatType == RepeatType.weekly)
                        _buildWeeklyOptions(setDialogState),
                      if (repeatType == RepeatType.monthly)
                        _buildMonthlyOptions(setDialogState),
                      if (repeatType == RepeatType.yearly)
                        _buildYearlyOptions(setDialogState),

                      SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Validation cho weekly
                                if (repeatType == RepeatType.weekly &&
                                    selectedWeekdays.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vui lòng chọn ít nhất một ngày trong tuần',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                // Thêm validation cho monthly
                                if (repeatType == RepeatType.monthly &&
                                    selectedMonthlyDays.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vui lòng chọn ít nhất một ngày trong tháng',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Lưu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getRepeatTypeIcon(RepeatType type) {
    switch (type) {
      case RepeatType.daily:
        return Icons.today;
      case RepeatType.weekly:
        return Icons.view_week;
      case RepeatType.monthly:
        return Icons.calendar_month;
      case RepeatType.yearly:
        return Icons.event;
    }
  }

  Widget _buildDailyOptions(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: hasEndDate,
                onChanged: (value) {
                  setDialogState(() {
                    hasEndDate = value!;
                    if (!hasEndDate) {
                      endDate = null;
                    }
                  });
                },
                activeColor: selectedColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Có thời gian kết thúc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        if (hasEndDate) ...[
          SizedBox(height: 16),
          Text(
            'Ngày kết thúc:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _selectEndDate(setDialogState),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: selectedColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: selectedColor),
                  SizedBox(width: 12),
                  Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Chọn ngày kết thúc',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: selectedColor),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyOptions(StateSetter setDialogState) {
    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lặp lại vào các ngày:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              int weekdayValue = index + 1;
              bool isSelected = selectedWeekdays.contains(weekdayValue);

              return InkWell(
                onTap: () {
                  setDialogState(() {
                    if (isSelected) {
                      selectedWeekdays.remove(weekdayValue);
                    } else {
                      selectedWeekdays.add(weekdayValue);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? selectedColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: hasEndDate,
                onChanged: (value) {
                  setDialogState(() {
                    hasEndDate = value!;
                    if (!hasEndDate) {
                      endDate = null;
                    }
                  });
                },
                activeColor: selectedColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Có thời gian kết thúc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        if (hasEndDate) ...[
          SizedBox(height: 16),
          Text(
            'Ngày kết thúc:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _selectEndDate(setDialogState),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: selectedColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: selectedColor),
                  SizedBox(width: 12),
                  Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Chọn ngày kết thúc',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: selectedColor),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonthlyOptions(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lặp lại vào các ngày:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),

        // Grid để chọn múltiple ngày
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Hiển thị grid 31 ngày
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  int day = index + 1;
                  bool isSelected = selectedMonthlyDays.contains(day);

                  return InkWell(
                    onTap: () {
                      setDialogState(() {
                        if (isSelected) {
                          selectedMonthlyDays.remove(day);
                        } else {
                          selectedMonthlyDays.add(day);
                        }
                        selectedMonthlyDays.sort(); // Sắp xếp theo thứ tự
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? selectedColor : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12),

              // Hiển thị các ngày đã chọn
              if (selectedMonthlyDays.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selectedColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã chọn:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            selectedMonthlyDays.map((day) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Ngày $day',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Checkbox cho end date (giữ nguyên)
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: hasEndDate,
                onChanged: (value) {
                  setDialogState(() {
                    hasEndDate = value!;
                    if (!hasEndDate) {
                      endDate = null;
                    }
                  });
                },
                activeColor: selectedColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Có thời gian kết thúc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // End date picker (giữ nguyên phần này)
        if (hasEndDate) ...[
          SizedBox(height: 16),
          Text(
            'Ngày kết thúc:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _selectEndDate(setDialogState),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: selectedColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: selectedColor.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: selectedColor),
                  SizedBox(width: 12),
                  Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Chọn ngày kết thúc',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: selectedColor),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildYearlyOptions(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lặp lại vào:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selectedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selectedColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.event_repeat, color: selectedColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ngày ${startDate.day} tháng ${startDate.month} hằng năm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: hasEndDate,
                onChanged: (value) {
                  setDialogState(() {
                    hasEndDate = value!;
                    if (!hasEndDate) {
                      endDate = null;
                    }
                  });
                },
                activeColor: selectedColor,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Có thời gian kết thúc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        if (hasEndDate) ...[
          SizedBox(height: 16),
          Text(
            'Ngày kết thúc:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () => _selectEndDate(setDialogState),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: selectedColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: selectedColor),
                  SizedBox(width: 12),
                  Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Chọn ngày kết thúc',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          endDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: selectedColor),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _selectEndDate(StateSetter setDialogState) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate.add(Duration(days: 30)),
      firstDate: startDate.add(Duration(days: 1)),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setDialogState(() {
        endDate = pickedDate;
      });
    }
  }

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          startDate.isBefore(DateTime.now()) ? DateTime.now() : startDate,
      firstDate: DateTime.now(), // Chỉ cho phép chọn từ ngày hiện tại trở đi
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
        formattedStartDate = DateFormat(
          'MMMM d, yyyy',
          'vi_VN',
        ).format(startDate);

        // Cập nhật lại selectedWeekdays và monthlyDay dựa trên ngày mới
        selectedWeekdays = [startDate.weekday];
        selectedMonthlyDays = [startDate.day];

        // Nếu endDate đã được chọn và nhỏ hơn startDate mới, reset endDate
        if (endDate != null && endDate!.isBefore(startDate)) {
          endDate = null;
          hasEndDate = false;
        }
      });
    }
  }

  void _showEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate.add(Duration(days: 1)),
      firstDate: startDate.add(
        Duration(days: 1),
      ), // Phải sau ngày bắt đầu ít nhất 1 ngày
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        endDate = pickedDate;
        hasEndDate = true;
      });
    }
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        reminders.add(picked);
      });
    }
  }

  void _removeReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });
  }

  void _showCustomColorPicker(
    StateSetter setDialogState,
    Function(Color) onColorSelected,
  ) {
    Color pickerColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn màu tùy chỉnh'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                onColorSelected(pickerColor);
                Navigator.of(context).pop();
              },
              child: Text('Chọn'),
            ),
          ],
        );
      },
    );
  }

  void _showTagOptions(
    Tag tag,
    StateSetter setDialogState,
    Offset tapPosition,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx - 100,
        tapPosition.dy - 10,
        tapPosition.dx + 100,
        tapPosition.dy + 100,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditTagDialog(tag, setDialogState);
      } else if (value == 'delete') {
        setState(() {
          tags.removeWhere((t) => t.id == tag.id);
        });
        setDialogState(() {});
      }
    });
  }

  void _showEditTagDialog(Tag tag, StateSetter parentSetState) {
    String tagName = tag.name;
    Color tagColor = tag.color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Chỉnh sửa thẻ'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: tagName),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên vào đây',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        tagName = value;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Màu sắc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            colorOptions.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  if (color == Colors.transparent) {
                                    _showCustomColorPicker(setDialogState, (
                                      selectedCustomColor,
                                    ) {
                                      setDialogState(() {
                                        tagColor = selectedCustomColor;
                                      });
                                    });
                                  } else {
                                    setDialogState(() {
                                      tagColor = color;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color:
                                        color == Colors.transparent
                                            ? null
                                            : color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          tagColor == color
                                              ? Colors.blue
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                    gradient:
                                        color == Colors.transparent
                                            ? LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.orange,
                                                Colors.yellow,
                                                Colors.green,
                                                Colors.blue,
                                                Colors.purple,
                                              ],
                                            )
                                            : null,
                                  ),
                                  child:
                                      color == Colors.transparent
                                          ? Icon(
                                            Icons.palette,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                          : null,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (tagName.isNotEmpty) {
                            setState(() {
                              tag.name = tagName;
                              tag.color = tagColor;
                            });
                            parentSetState(() {});
                            Navigator.of(context).pop();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTagDialog() {
    String tagName = '';
    Color tagColor = colorOptions[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Center(
                child: Text(
                  'Thêm thẻ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(maxHeight: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tên vào đây',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          tagName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Màu sắc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            colorOptions.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  if (color == Colors.transparent) {
                                    _showCustomColorPicker(setDialogState, (
                                      selectedCustomColor,
                                    ) {
                                      setDialogState(() {
                                        tagColor = selectedCustomColor;
                                      });
                                    });
                                  } else {
                                    setDialogState(() {
                                      tagColor = color;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color:
                                        color == Colors.transparent
                                            ? null
                                            : color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          tagColor == color
                                              ? Colors.blue
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                    gradient:
                                        color == Colors.transparent
                                            ? LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.orange,
                                                Colors.yellow,
                                                Colors.green,
                                                Colors.blue,
                                                Colors.purple,
                                              ],
                                            )
                                            : null,
                                  ),
                                  child:
                                      color == Colors.transparent
                                          ? Icon(
                                            Icons.palette,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                          : null,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (tags.isNotEmpty) ...[
                      Text(
                        'Thẻ đã có',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 150,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tags.length,
                          itemBuilder: (context, index) {
                            Tag tag = tags[index];

                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: tag.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      tag.name,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTapDown: (TapDownDetails details) {
                                      _showTagOptions(
                                        tag,
                                        setDialogState,
                                        details.globalPosition,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.more_horiz,
                                        color: tag.color,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white60,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          if (tagName.isNotEmpty) {
                            setState(() {
                              tags.add(
                                Tag(
                                  id:
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  name: tagName,
                                  color: tagColor,
                                ),
                              );
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF4FCA9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Lưu',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTag(Tag tag) {
    setState(() {
      tags.removeWhere((t) => t.id == tag.id);
    });
  }

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
                      calendarIcon = iconOptions[index];
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
              itemCount: iconOptions.length,
              itemBuilder: (context, index) {
                final colors = [
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
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = colors[index];
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index],
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
          widget.isEditing
              ? 'SỬA THỬ THÁCH'
              : 'THỬ THÁCH MỚI', // ✅ Dynamic title
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: selectedColor),
            onPressed: _saveHabit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      child: Icon(calendarIcon, color: selectedColor),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _titleController,
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

              Row(
                children: [
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
                    GestureDetector(
                      onTap: _showDatePicker,
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

                    // Cập nhật phần Repeat với hiển thị chi tiết
                    GestureDetector(
                      onTap: _showRepeatTypeDialog,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 0,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.repeat, color: selectedColor),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getMainRepeatText(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_getDetailRepeatText().isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      _getDetailRepeatText(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                  if (hasEndDate && endDate != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Đến ${DateFormat('dd/MM/yyyy').format(endDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: selectedColor.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
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

                    GestureDetector(
                      onTap: _showEndDatePicker,
                      child: SettingItem(
                        icon: Icons.access_time,
                        iconColor: selectedColor,
                        title: 'Chọn thời gian kết thúc',
                        trailing: Row(
                          children: [
                            if (hasEndDate && endDate != null)
                              Text(
                                DateFormat('dd/MM/yyyy').format(endDate!),
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              Icon(Icons.close, color: Colors.grey),
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

                    Column(
                      children: [
                        SettingItem(
                          icon: Icons.notifications,
                          iconColor: selectedColor,
                          title: 'Nhắc nhở',
                          trailing: Row(
                            children: [
                              if (reminderEnabled)
                                Container(
                                  margin: EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: _showTimePicker,
                                    child: Container(
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
                                  ),
                                ),
                              Switch(
                                value: reminderEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    reminderEnabled = value;
                                    if (!value) {
                                      reminders.clear();
                                    }
                                  });
                                },
                                activeColor: selectedColor,
                              ),
                            ],
                          ),
                        ),
                        ...reminders.asMap().entries.map((entry) {
                          int index = entry.key;
                          TimeOfDay time = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(left: 40, top: 8),
                            child: Row(
                              children: [
                                Text(
                                  '${time.format(context)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () => _removeReminder(index),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                    Divider(height: 24),

                    Column(
                      children: [
                        SettingItem(
                          icon: Icons.local_fire_department,
                          iconColor: selectedColor,
                          title: 'Thẻ',
                          trailing: Row(
                            children: [
                              if (streakEnabled)
                                Container(
                                  margin: EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: _showAddTagDialog,
                                    child: Container(
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
                                  ),
                                ),
                              Switch(
                                value: streakEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    streakEnabled = value;
                                    if (!value) {
                                      tags.clear();
                                    }
                                  });
                                },
                                activeColor: selectedColor,
                              ),
                            ],
                          ),
                        ),

                        if (streakEnabled && tags.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 40, top: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  tags.map((tag) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: tag.color,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            tag.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _deleteTag(tag),
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child:
                        _isSaving
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
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

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Phương thức helper để lấy text chính
  String _getMainRepeatText() {
    switch (repeatType) {
      case RepeatType.daily:
        return 'Hằng ngày';
      case RepeatType.weekly:
        return 'Hằng tuần';
      case RepeatType.monthly:
        return 'Hằng tháng';
      case RepeatType.yearly:
        return 'Hằng năm';
    }
  }

  // Phương thức helper để lấy text chi tiết
  String _getDetailRepeatText() {
    switch (repeatType) {
      case RepeatType.daily:
        return '';

      case RepeatType.weekly:
        if (selectedWeekdays.isEmpty) return '';

        final weekdayNames = {
          1: 'Thứ 2',
          2: 'Thứ 3',
          3: 'Thứ 4',
          4: 'Thứ 5',
          5: 'Thứ 6',
          6: 'Thứ 7',
          7: 'Chủ nhật',
        };

        List<String> selectedDays =
            selectedWeekdays.map((day) => weekdayNames[day]!).toList();
        selectedDays.sort((a, b) {
          final order = [
            'Thứ 2',
            'Thứ 3',
            'Thứ 4',
            'Thứ 5',
            'Thứ 6',
            'Thứ 7',
            'Chủ nhật',
          ];
          return order.indexOf(a).compareTo(order.indexOf(b));
        });

        return 'Lặp vào ${selectedDays.join(', ')}';

      case RepeatType.monthly:
        if (selectedMonthlyDays.isEmpty) return '';

        if (selectedMonthlyDays.length == 1) {
          return 'Lặp vào ngày ${selectedMonthlyDays.first} hằng tháng';
        } else {
          String daysList = selectedMonthlyDays
              .map((day) => 'ngày $day')
              .join(', ');
          return 'Lặp vào $daysList hằng tháng';
        }

      case RepeatType.yearly:
        return 'Lặp vào ngày ${startDate.day} tháng ${startDate.month} hằng năm';
    }
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget trailing;

  const SettingItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
