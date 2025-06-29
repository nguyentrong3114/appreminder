import 'package:intl/intl.dart';
import '../../../models/habit.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/views/widgets/challenge/add_onetime_task.dart';
import 'package:flutter_app/views/widgets/challenge/add_regular_habit_screen.dart';

class StatisticsScreen extends StatefulWidget {
  final Habit habit;

  const StatisticsScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, bool> completedDates = {};
  Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  DateTime currentMonth = DateTime.now();

  //THÊM BIẾN ĐỂ LƯU HABIT HIỆN TẠI
  late Habit currentHabit;

  @override
  void initState() {
    super.initState();
    currentHabit = widget.habit; //Khởi tạo habit hiện tại
    _loadHabitCompletions();
  }

  // Tải lại thông tin habit từ database
  Future<void> _reloadHabitInfo() async {
    if (_auth.currentUser == null) return;

    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot habitDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('habits')
              .doc(widget.habit.id)
              .get();

      if (habitDoc.exists) {
        Map<String, dynamic> data = habitDoc.data() as Map<String, dynamic>;

        //TẠO HABIT MỚI THEO ĐÚNG MODEL
        Habit updatedHabit = Habit(
          id: habitDoc.id,
          title: data['title'] ?? '',
          iconCodePoint: data['iconCodePoint'] ?? '0',
          colorValue: data['colorValue'] ?? '0',
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate:
              data['endDate'] != null
                  ? (data['endDate'] as Timestamp).toDate()
                  : null,
          hasEndDate: data['hasEndDate'] ?? false,
          type: _parseHabitType(data['type']),
          repeatType: _parseRepeatType(data['repeatType']),
          selectedWeekdays: List<int>.from(data['selectedWeekdays'] ?? []),
          selectedMonthlyDays: List<int>.from(
            data['selectedMonthlyDays'] ?? [],
          ),

          //CÁC FIELD BỊ THIẾU TRONG CODE CŨ
          reminderEnabled: data['reminderEnabled'] ?? false,
          reminderTimes: List<String>.from(data['reminderTimes'] ?? []),
          streakEnabled: data['streakEnabled'] ?? false,
          tags: List<Map<String, dynamic>>.from(data['tags'] ?? []),
          createdAt:
              data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.now(),
        );

        setState(() {
          currentHabit = updatedHabit;
        });
      }
    } catch (e) {
      print('Lỗi khi tải lại habit info: $e');
    }
  }

  //THÊM HÀM HELPER CHO HabitType
  HabitType _parseHabitType(String? type) {
    switch (type) {
      case 'HabitType.regular':
        return HabitType.regular;
      case 'HabitType.onetime':
        return HabitType.onetime;
      case 'regular':
        return HabitType.regular;
      case 'onetime':
        return HabitType.onetime;
      default:
        return HabitType.regular;
    }
  }

  //Hàm helper để parse RepeatType
  RepeatType _parseRepeatType(String? type) {
    switch (type) {
      case 'RepeatType.daily':
      case 'daily':
        return RepeatType.daily;
      case 'RepeatType.weekly':
      case 'weekly':
        return RepeatType.weekly;
      case 'RepeatType.monthly':
      case 'monthly':
        return RepeatType.monthly;
      case 'RepeatType.yearly':
      case 'yearly':
        return RepeatType.yearly;
      default:
        return RepeatType.daily;
    }
  }

  ///Kiểm tra xem ngày có thuộc thử thách không (sử dụng currentHabit)
  bool _isHabitActiveOnDate(DateTime date) {
    // Chuyển về định dạng chỉ có ngày (bỏ giờ phút giây)
    DateTime dateOnly = DateTime(date.year, date.month, date.day);
    DateTime startDateOnly = DateTime(
      currentHabit.startDate.year,
      currentHabit.startDate.month,
      currentHabit.startDate.day,
    );

    // KIỂM TRA CHÍNH: ngày phải >= ngày bắt đầu
    if (dateOnly.isBefore(startDateOnly)) {
      return false; // Ngày 11/6 < 12/6 → return false
    }

    // Kiểm tra ngày kết thúc (nếu có)
    if (currentHabit.hasEndDate && currentHabit.endDate != null) {
      DateTime endDateOnly = DateTime(
        currentHabit.endDate!.year,
        currentHabit.endDate!.month,
        currentHabit.endDate!.day,
      );
      if (dateOnly.isAfter(endDateOnly)) {
        return false;
      }
    }

    // Xử lý theo loại habit
    if (currentHabit.type == HabitType.onetime) {
      // Chỉ active đúng ngày bắt đầu
      return dateOnly.isAtSameMomentAs(startDateOnly);
    }

    // Với các habit lặp lại, kiểm tra pattern
    switch (currentHabit.repeatType) {
      case RepeatType.daily:
        return true; // Từ ngày bắt đầu trở đi, mỗi ngày đều active

      case RepeatType.weekly:
        int weekday = date.weekday == 7 ? 0 : date.weekday;
        return currentHabit.selectedWeekdays.contains(weekday);

      case RepeatType.monthly:
        return currentHabit.selectedMonthlyDays.contains(date.day);

      case RepeatType.yearly:
        return date.day == currentHabit.startDate.day &&
            date.month == currentHabit.startDate.month;
    }
  }

  ///Hàm xác định text hiển thị theo loại habit (sử dụng currentHabit)
  String _getHabitFrequencyText() {
    if (currentHabit.type == HabitType.onetime) {
      return 'Một lần';
    }

    switch (currentHabit.repeatType) {
      case RepeatType.daily:
        return 'Hàng ngày';
      case RepeatType.weekly:
        return 'Hàng tuần';
      case RepeatType.monthly:
        return 'Hàng tháng';
      case RepeatType.yearly:
        return 'Hàng năm';
    }
  }

  void _editHabit() async {
    Widget targetScreen;

    if (currentHabit.type == HabitType.onetime) {
      targetScreen = OnetimeTask(existingHabit: currentHabit, isEditing: true);
    } else {
      targetScreen = RegularHabitScreen(
        existingHabit: currentHabit,
        isEditing: true,
      );
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );

    //Chỉ reload khi có kết quả trả về
    if (result != null) {
      print('Debug: Có result từ edit, bắt đầu reload...');

      // RELOAD THEO THỨ TỰ ĐÚNG
      await _reloadHabitInfo(); // Load habit info trước
      await _loadHabitCompletions(); // Load completions sau

      print(
        'Debug: Đã reload xong, currentHabit.title = ${currentHabit.title}',
      );
    } else {
      print('ℹDebug: Không có result, có thể user đã cancel');
    }
  }

  ///Hàm xóa habit với dialog phù hợp
  Future<void> _deleteHabit() async {
    if (currentHabit.type == HabitType.onetime) {
      _showDeleteOneTimeHabitDialog();
    } else {
      _showDeleteOneTimeHabitDialog();
    }
  }

  /// Dialog xóa thử thách một lần
  Future<void> _showDeleteOneTimeHabitDialog() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Bạn có chắc chắn muốn xóa thử thách này không?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Xóa thử thách',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Hủy bỏ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmDelete == true) {
      await _performDeleteAllHabit();
    }
  }

  /// Xóa hoàn toàn thử thách
  Future<void> _performDeleteAllHabit() async {
    try {
      if (_auth.currentUser != null) {
        String userId = _auth.currentUser!.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('habits')
            .doc(currentHabit.id)
            .delete();

        QuerySnapshot completions =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('habit_completions')
                .where('habitId', isEqualTo: currentHabit.id)
                .get();

        for (var doc in completions.docs) {
          await doc.reference.delete();
        }

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Lỗi khi xóa habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi xóa thử thách'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadHabitCompletions() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;

    try {
      print('Debug: Đang reload habit completions...');

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('habit_completions')
              .where('habitId', isEqualTo: currentHabit.id)
              .get();

      Map<String, bool> dates = {};
      Map<int, int> ratings = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      print('Debug: Tìm thấy ${snapshot.docs.length} completion records');

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['completed'] == true) {
          DateTime date = (data['date'] as Timestamp).toDate();
          String dateKey = DateFormat('yyyy-MM-dd').format(date);
          dates[dateKey] = true;

          print('Debug: Completion tồn tại cho ngày: $dateKey');

          int rating = data['rating'] ?? 5;
          ratings[rating] = (ratings[rating] ?? 0) + 1;
        }
      }

      setState(() {
        completedDates = dates;
        ratingCounts = ratings;
      });

      print(
        'Debug: Đã cập nhật completedDates: ${completedDates.keys.toList()}',
      );
    } catch (e) {
      print('Lỗi khi tải thống kê: $e');
    }
  }

  List<Color> _getRatingColors() {
    return [
      Colors.black,
      Colors.grey,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];
  }

  Widget _buildCalendarGrid() {
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    int startWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    List<Widget> calendarDays = [];
    Color habitColor = Color(int.parse(currentHabit.colorValue));

    // Thêm ngày trống cho tuần đầu tiên
    for (int i = 0; i < startWeekday; i++) {
      int prevMonthDay =
          DateTime(currentMonth.year, currentMonth.month, 0).day -
          startWeekday +
          i +
          1;
      calendarDays.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            '$prevMonthDay',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ),
      );
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(currentMonth.year, currentMonth.month, day);
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      bool isCompleted = completedDates[dateKey] ?? false;
      bool isHabitActive = _isHabitActiveOnDate(date);

      DateTime today = DateTime.now();
      bool isToday =
          date.day == today.day &&
          date.month == today.month &&
          date.year == today.year;

      calendarDays.add(
        Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isHabitActive && !isCompleted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: habitColor.withOpacity(0.5),
                      width: 2,
                    ),
                    color: Colors.transparent,
                  ),
                ),

              if (isCompleted)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 20),
                ),

              // Text ngày (chỉ hiện khi chưa hoàn thành)
              if (!isCompleted)
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    color: isToday ? Colors.red : Colors.black87,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Thêm ngày của tháng sau nếu cần
    int remainingCells = 42 - calendarDays.length;
    for (int i = 1; i <= remainingCells && calendarDays.length < 42; i++) {
      calendarDays.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            '$i',
            style: TextStyle(color: Colors.grey[300], fontSize: 16),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: calendarDays,
    );
  }

  Widget _buildMoodChart() {
    int totalRatings = ratingCounts.values.fold(0, (sum, count) => sum + count);

    if (totalRatings == 0) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            'Chưa có đánh giá nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = _getRatingColors();

    for (int rating = 1; rating <= 5; rating++) {
      int count = ratingCounts[rating] ?? 0;
      if (count > 0) {
        double percentage = (count / totalRatings) * 100;
        sections.add(
          PieChartSectionData(
            value: percentage,
            color: colors[rating - 1],
            title: '${percentage.toStringAsFixed(1)}%',
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            radius: 60,
          ),
        );
      }
    }

    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildRatingIcons() {
    List<Color> colors = _getRatingColors();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        int rating = index + 1;
        int count = ratingCounts[rating] ?? 0;

        return Stack(
          children: [
            Container(
              width: 60,
              height: 80,
              child: Image.asset(
                'assets/images/${rating}star.png',
                fit: BoxFit.contain,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors[rating - 1],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(int.parse(currentHabit.colorValue)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'THỐNG KÊ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Color(int.parse(currentHabit.colorValue)),
            ),
            onPressed: _deleteHabit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Habit info card (sử dụng currentHabit)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(currentHabit.colorValue)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(currentHabit.colorValue)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(
                        int.parse(currentHabit.iconCodePoint),
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentHabit.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getHabitFrequencyText(),
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey),
                    onPressed: _editHabit,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Calendar section (sử dụng currentHabit)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Color(int.parse(currentHabit.colorValue)),
                        ),
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month - 1,
                            );
                          });
                          _loadHabitCompletions();
                        },
                      ),
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                          'vi_VN',
                        ).format(currentMonth).toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(int.parse(currentHabit.colorValue)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Color(int.parse(currentHabit.colorValue)),
                        ),
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                            );
                          });
                          _loadHabitCompletions();
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Week headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                            .map(
                              (day) => Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                    int.parse(currentHabit.colorValue),
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  SizedBox(height: 8),

                  // Calendar grid
                  _buildCalendarGrid(),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Mood statistics
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Đếm tâm trạng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16),

                  // Pie chart
                  _buildMoodChart(),

                  SizedBox(height: 24),

                  // Rating icons
                  _buildRatingIcons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
