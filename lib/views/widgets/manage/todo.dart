import 'package:flutter/material.dart';
import 'package:flutter_app/views/widgets/manage/diary.dart';
import 'package:intl/intl.dart';
import 'notes.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_detail_screen.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  TodoState createState() => TodoState();
}

class TodoState extends State<Todo> {
  int selectedTab = 0;
  int selectedFilter = 1;
  DateTime selectedDate = DateTime.now();
  late List<DateTime> allDays;
  late List<List<DateTime>> allWeeks;
  late List<DateTime> allMonths;
  late ScrollController dayScrollController;
  late ScrollController weekScrollController;
  late ScrollController monthScrollController;
  int currentDayIndex = 0;
  int currentWeekIndex = 0;
  int currentMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeDates();

    // Cuộn đến ngày hiện tại
    dayScrollController = ScrollController(
      initialScrollOffset: math.max(0, (currentDayIndex - 3) * 49.0),
    );

    weekScrollController = ScrollController(
      initialScrollOffset: math.max(0, (currentWeekIndex - 1) * 120.0),
    );

    monthScrollController = ScrollController(
      initialScrollOffset: math.max(0, (currentMonthIndex - 2) * 80.0),
    );
  }

  void _initializeDates() {
    DateTime now = DateTime.now();

    // tạo ra ds ngày trong 2 năm gần nhất với năm hiện tại
    DateTime startDay = now.subtract(Duration(days: 365));
    allDays = List.generate(
      365 * 2, // 2 years of days
      (index) => startDay.add(Duration(days: index)),
    );

    // Tìm kiếm ngày hiện tại đang nằm vị trí nào trong 730 ngày
    currentDayIndex = allDays.indexWhere(
      (date) =>
          date.day == now.day &&
          date.month == now.month &&
          date.year == now.year,
    );

    // Generate a large number of weeks
    DateTime startWeek = now.subtract(
      Duration(days: now.weekday - 1 + (52 * 7)),
    ); // Start 52 weeks before today
    allWeeks = List.generate(
      104, // 2 years of weeks
      (index) => _getWeekRange(startWeek.add(Duration(days: 7 * index))),
    );

    // Find index of current week
    currentWeekIndex = allWeeks.indexWhere((week) => _isSameWeek(week[0], now));

    // Generate a large number of months (48 months = 4 years)
    DateTime startMonth = DateTime(now.year - 2, 1, 1); // Start 2 years before
    allMonths = List.generate(
      48, // 4 years of months
      (index) {
        int monthsToAdd = index;
        return DateTime(
          startMonth.year + (startMonth.month + monthsToAdd - 1) ~/ 12,
          (startMonth.month + monthsToAdd - 1) % 12 + 1,
          1,
        );
      },
    );

    // Find index of current month
    currentMonthIndex = allMonths.indexWhere(
      (month) => month.month == now.month && month.year == now.year,
    );

    // Set selected date based on filter
    _updateSelectedDateBasedOnFilter();
  }

  void _updateSelectedDateBasedOnFilter() {
    DateTime now = DateTime.now();

    if (selectedFilter == 1) {
      // Day
      selectedDate = now;
    } else if (selectedFilter == 2) {
      // Week
      // Set to first day of current week
      selectedDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (selectedFilter == 3) {
      // Month
      // Set to first day of current month
      selectedDate = DateTime(now.year, now.month, 1);
    }
  }

  List<DateTime> _getWeekRange(DateTime startDate) {
    return List.generate(7, (index) => startDate.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        //tắt mũi tên back
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        title: _buildTabBar(),
      ),
      body: Column(
        children: [
          if (selectedTab == 0) _buildFilterOptions(),
          if (selectedTab == 0) _buildDateSelection(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabItem("Todo", 0),
          _buildTabItem("Notes", 1),
          _buildTabItem("Diary", 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF4CD6A8) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    List<String> filterLabels = ["Đã hết hạn", "Ngày", "Tuần", "Tháng"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: List.generate(filterLabels.length, (index) {
          return _buildFilterButton(filterLabels[index], index);
        }),
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    bool isSelected = selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = index;
            // Update selected date based on new filter
            _updateSelectedDateBasedOnFilter();

            // Scroll to current day/week/month when filter changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (index == 1) {
                // Day
                dayScrollController.animateTo(
                  math.max(0, (currentDayIndex - 3) * 49.0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else if (index == 2) {
                // Week
                weekScrollController.animateTo(
                  math.max(0, (currentWeekIndex - 1) * 120.0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else if (index == 3) {
                // Month
                monthScrollController.animateTo(
                  math.max(0, (currentMonthIndex - 2) * 80.0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFC06E) : Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    // Different date selection based on filter type
    if (selectedFilter == 1) {
      // Day view
      return _buildDaySelection();
    } else if (selectedFilter == 2) {
      // Week view
      return _buildWeekSelection();
    } else if (selectedFilter == 3) {
      // Month view
      return _buildMonthSelection();
    } else {
      // Expired view
      return SizedBox(height: 10); // Empty space for expired view
    }
  }

  Widget _buildDaySelection() {
    return Container(
      height: 80, // Set a fixed height for the container
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allDays.length,
        controller: dayScrollController,
        itemBuilder: (context, index) {
          DateTime day = allDays[index];
          bool isSelected =
              day.day == selectedDate.day &&
              day.month == selectedDate.month &&
              day.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = day;
              });
            },
            child: Container(
              width: 45,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4CD6A8) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${day.day}/${day.month}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _getWeekdayName(day),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekSelection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allWeeks.length,
        controller: weekScrollController,
        itemBuilder: (context, index) {
          List<DateTime> weekRange = allWeeks[index];
          bool isSelected = _isSameWeek(weekRange[0], selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = weekRange[0];
              });
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4CD6A8) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${weekRange[0].day} - ${weekRange[6].day}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "thg ${weekRange[0].month}/${weekRange[0].year.toString().substring(2)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allMonths.length,
        controller: monthScrollController,
        itemBuilder: (context, index) {
          DateTime month = allMonths[index];
          bool isSelected =
              month.month == selectedDate.month &&
              month.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = month;
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4CD6A8) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "thg ${month.month}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "${month.year}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekdayName(DateTime date) {
    List<String> weekdays = [
      "CN",
      "Thứ 2",
      "Thứ 3",
      "Thứ 4",
      "Thứ 5",
      "Thứ 6",
      "Thứ 7",
    ];
    return weekdays[date.weekday % 7]; // % 7 to make Sunday index 0
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    // Check if two dates are in the same week
    DateTime startOfWeek1 = date1.subtract(Duration(days: date1.weekday - 1));
    DateTime startOfWeek2 = date2.subtract(Duration(days: date2.weekday - 1));

    return startOfWeek1.year == startOfWeek2.year &&
        startOfWeek1.month == startOfWeek2.month &&
        startOfWeek1.day == startOfWeek2.day;
  }

  // This widget decides what content to show based on the selected tab
  Widget _buildContent() {
    if (selectedTab == 0) {
      return _buildTaskSummary();
    } else if (selectedTab == 1) {
      return _buildNotesContent();
    } else {
      return _buildDiaryContent();
    }
  }

  Widget _buildTaskSummary() {
    DateTime start, end;
    if (selectedFilter == 1) {
      start = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        0,
        0,
        0,
      );
      end = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
        59,
      );
    } else if (selectedFilter == 2) {
      start = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      end = start.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    } else if (selectedFilter == 3) {
      start = DateTime(selectedDate.year, selectedDate.month, 1);
      end = DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);
    } else {
      start = DateTime(2000);
      end = DateTime.now().subtract(const Duration(seconds: 1));
    }

    String title = "";
    String subtitle = "";

    if (selectedFilter == 1) {
      title = "Hôm nay";
      subtitle = DateFormat('dd/MM/yyyy').format(selectedDate);
    } else if (selectedFilter == 2) {
      title = "Tuần này";
      subtitle =
          "${DateFormat('dd/MM').format(selectedDate)} - ${DateFormat('dd/MM').format(selectedDate.add(Duration(days: 6)))}";
    } else if (selectedFilter == 3) {
      title = "Tháng này";
      subtitle = "Tháng ${selectedDate.month}/${selectedDate.year}";
    } else {
      title = "Đã hết hạn";
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('todos')
              .where(
                'startDateTime',
                isGreaterThanOrEqualTo: start.toIso8601String(),
              )
              .where(
                'startDateTime',
                isLessThanOrEqualTo: end.toIso8601String(),
              )
              .snapshots(),
      builder: (context, snapshot) {
        final todos = snapshot.hasData ? snapshot.data!.docs : [];
        final todoCount = todos.length;

        // Tách nhiệm vụ hoàn thành và chưa hoàn thành, sau đó nối lại (chưa hoàn thành lên đầu)
        final unDone =
            todos
                .where(
                  (doc) =>
                      (doc.data() as Map<String, dynamic>)['isDone'] != true,
                )
                .toList();
        final done =
            todos
                .where(
                  (doc) =>
                      (doc.data() as Map<String, dynamic>)['isDone'] == true,
                )
                .toList();
        final sortedTodos = [...unDone, ...done];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header thống kê
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF4CD6A8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        SizedBox(height: 5),
                        Text(
                          "$todoCount nhiệm vụ",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/holidays.png', 
                    height: 100,
                  ),
                ],
              ),
            ),
            if (todoCount > 0)
              ...sortedTodos.map((doc) {
                final todo = doc.data() as Map<String, dynamic>;
                final isDone = todo['isDone'] == true;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    onTap: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TodoDetailScreen(todo: doc),
                        ),
                      );
                      if (result == 'deleted' || result == 'edited') {
                        setState(() {});
                      }
                    },
                    leading: Checkbox(
                      value: isDone,
                      activeColor: Color(0xFF4CD6A8),
                      onChanged: (value) async {
                        // Update trạng thái hoàn thành trên Firestore
                        await doc.reference.update({'isDone': value});
                        setState(() {});
                      },
                    ),
                    title: Text(
                      todo['title'] ?? '',
                      style: TextStyle(
                        decoration:
                            isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color: isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      todo['details'] ?? '',
                      style: TextStyle(
                        decoration:
                            isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        color: isDone ? Colors.grey : Colors.black54,
                      ),
                    ),
                    trailing:
                        todo['reminderEnabled'] == true
                            ? const Icon(
                              Icons.notifications_active,
                              color: Colors.red,
                            )
                            : null,
                  ),
                );
              }).toList(),
            if (todoCount == 0)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Không có nhiệm vụ nào",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Widget for Notes tab content
  Widget _buildNotesContent() {
    return NotesScreen();
  }

  Widget _buildDiaryContent() {
    return DiaryScreen();
  }
}

Widget buildNavItem(IconData icon, String label, bool isSelected) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: isSelected ? Color(0xFF4CD6A8) : Colors.grey, size: 24),
      Text(
        label,
        style: TextStyle(
          color: isSelected ? Color(0xFF4CD6A8) : Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  );
}
