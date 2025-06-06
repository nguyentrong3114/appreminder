import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../models/habit.dart';
import 'package:fl_chart/fl_chart.dart';

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

  @override
  void initState() {
    super.initState();
    _loadHabitCompletions();
  }

  Future<void> _loadHabitCompletions() async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('habit_completions')
              .where('habitId', isEqualTo: widget.habit.id)
              .get();

      Map<String, bool> dates = {};
      Map<int, int> ratings = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['completed'] == true) {
          DateTime date = (data['date'] as Timestamp).toDate();
          String dateKey = DateFormat('yyyy-MM-dd').format(date);
          dates[dateKey] = true;

          // Đếm rating
          int rating = data['rating'] ?? 5;
          ratings[rating] = (ratings[rating] ?? 0) + 1;
        }
      }

      setState(() {
        completedDates = dates;
        ratingCounts = ratings;
      });
    } catch (e) {
      print('❌ Lỗi khi tải thống kê: $e');
    }
  }

  List<Color> _getRatingColors() {
    return [
      Colors.black, // 1 sao
      Colors.grey, // 2 sao
      Colors.yellow, // 3 sao
      Colors.orange, // 4 sao
      Colors.red, // 5 sao
    ];
  }

  Widget _buildCalendarGrid() {
    DateTime firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    int startWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    List<Widget> calendarDays = [];

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

      // ✅ Sửa logic kiểm tra ngày hiện tại
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
              // ✅ Nếu ngày đã hoàn thành, hiện hình tròn xanh với dấu tích trắng
              if (isCompleted)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                )
              // ✅ Nếu không hoàn thành, hiện số ngày
              else
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    // ✅ Ngày hiện tại có màu đỏ và in đậm
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
          icon: Icon(Icons.arrow_back, color: Colors.orange),
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
            icon: Icon(Icons.edit_outlined, color: Colors.orange),
            onPressed: () {
              // TODO: Chỉnh sửa habit
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Habit info card
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
                      color: Color(int.parse(widget.habit.colorValue)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(widget.habit.colorValue)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(
                        int.parse(widget.habit.iconCodePoint),
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
                          widget.habit.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Hàng ngày',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Calendar section
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
                        icon: Icon(Icons.chevron_left, color: Colors.orange),
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
                          color: Colors.orange,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: Colors.orange),
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
                                  color: Colors.orange,
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
