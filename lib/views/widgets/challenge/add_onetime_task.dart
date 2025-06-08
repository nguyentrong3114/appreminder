import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';
import '../../../models/habit.dart';
import '../../../services/habit_service.dart';

class OnetimeTask extends StatefulWidget {
  final DateTime? initialStartDate;
  final String? formattedStartDate;
  final String? initialTitle;
  final IconData? initialIcon;
  final Color? initialColor;
  final bool? reminderEnabledByDefault;

  // ✨ THÊM CÁC PARAMETER CHO EDITING
  final Habit? existingHabit; // Habit cần edit
  final bool isEditing; // Flag để biết đang edit hay tạo mới

  const OnetimeTask({
    Key? key,
    this.initialStartDate,
    this.formattedStartDate,
    this.initialTitle,
    this.initialIcon,
    this.initialColor,
    this.reminderEnabledByDefault,
    this.existingHabit, // ✨ THÊM
    this.isEditing = false, // ✨ THÊM (default = false)
  }) : super(key: key);

  @override
  _OnetimeTask createState() => _OnetimeTask();
}

class Tag {
  String id;
  String name;
  Color color;

  Tag({required this.id, required this.name, required this.color});
}

class _OnetimeTask extends State<OnetimeTask> {
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

  // Services
  final HabitService _habitService = HabitService();
  bool _isSaving = false;

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

    // Load date
    startDate = habit.startDate;
    formattedStartDate = DateFormat('MMMM d, yyyy', 'vi_VN').format(startDate);

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
    // Random màu sắc từ danh sách màu có sẵn
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

    // Random cả màu sắc và biểu tượng
    selectedColor =
        widget.initialColor ??
        availableColors[random.nextInt(availableColors.length)];
    selectedIcon =
        widget.initialIcon ?? iconOptions[random.nextInt(iconOptions.length)];
    calendarIcon = selectedIcon;

    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    reminderEnabled = widget.reminderEnabledByDefault ?? false;
    startDate = widget.initialStartDate ?? DateTime.now();

    if (widget.formattedStartDate != null) {
      formattedStartDate = widget.formattedStartDate!;
    } else {
      formattedStartDate = DateFormat(
        'MMMM d, yyyy',
        'vi_VN',
      ).format(startDate);
    }
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

  // 5 màu sắc cho thẻ
  final List<Color> colorOptions = [
    Colors.black,
    Color(0xFFE57373), // Red
    Color(0xFFFFB74D), // Orange/Yellow
    Color(0xFF81C784), // Green
    Colors.transparent, // Custom color picker
  ];

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(), // Chỉ cho phép từ hôm nay trở đi
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
        formattedStartDate = DateFormat(
          'MMMM d, yyyy',
          'vi_VN',
        ).format(startDate);
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

  // ✅ CẬP NHẬT HÀM SAVE CHO CẢ CREATE VÀ EDIT
  Future<void> _saveOnetimeTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tên nhiệm vụ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation ngày bắt đầu (chỉ cho create mới)
    if (!widget.isEditing &&
        startDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ngày bắt đầu không được trong quá khứ'),
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
        endDate: null,
        hasEndDate: false,
        type: HabitType.onetime, // Đánh dấu là onetime task
        repeatType: RepeatType.daily, // ✨ Default value cho onetime
        selectedWeekdays: [],
        selectedMonthlyDays: [],
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Đã cập nhật nhiệm vụ thành công!'
                : 'Đã lưu nhiệm vụ thành công!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, habitId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu nhiệm vụ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _deleteTag(Tag tag) {
    setState(() {
      tags.removeWhere((t) => t.id == tag.id);
    });
  }

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
          // ✨ DYNAMIC TITLE DỰA VÀO TRẠNG THÁI EDIT
          widget.isEditing ? 'SỬA NHIỆM VỤ' : 'NHIỆM VỤ MỚI',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: selectedColor),
            onPressed: _saveOnetimeTask,
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

                    SettingItem(
                      icon: Icons.repeat,
                      iconColor: selectedColor,
                      title: 'Không lặp lại',
                      trailing: SizedBox.shrink(),
                    ),

                    Divider(height: 24),

                    // Reminder section với thời gian giống RegularHabitScreen
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
                        if (reminderEnabled && reminders.isNotEmpty)
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

                    // Tags section giống y hệt RegularHabitScreen
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
                    onPressed: _isSaving ? null : _saveOnetimeTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
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
