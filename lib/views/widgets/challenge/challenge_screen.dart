import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart'; // Thay add_challenge_screen bằng regular_habit_screen
import 'package:intl/intl.dart';
import 'add_challenge_screen.dart';

class ChallengeScreen extends StatefulWidget {
  static DateTime selectedDate = DateTime.now();
  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int selectedIndex = -1;
  DateTime today = DateTime.now();
  late DateTime currentMonth;
  List<DateTime> visibleDates = [];
  int initialScrollPosition = 100;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(today.year, today.month);
    _generateDates();

    // Đặt ngày hiện tại làm ngày được chọn mặc định
    for (int i = 0; i < visibleDates.length; i++) {
      if (visibleDates[i].year == today.year &&
          visibleDates[i].month == today.month &&
          visibleDates[i].day == today.day) {
        selectedIndex = i;
        // Cập nhật ngày đã chọn vào biến static
        ChallengeScreen.selectedDate = visibleDates[i];
        break;
      }
    }
  }

  void _generateDates() {
    visibleDates = List.generate(500, (index) {
      return today.add(Duration(days: index - initialScrollPosition));
    });
  }

  String _getMonthDisplay() {
    if (selectedIndex >= 0 && selectedIndex < visibleDates.length) {
      return DateFormat(
        'MMMM yyyy',
        'vi_VN',
      ).format(visibleDates[selectedIndex]).toUpperCase();
    }
    return DateFormat('MMMM yyyy', 'vi_VN').format(today).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _getMonthDisplay(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              // Lấy ngày đã chọn từ biến static
              DateTime selectedDate = ChallengeScreen.selectedDate;

              // Chuyển đến trang AddChallengeScreen và truyền ngày đã chọn
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddChallengeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: visibleDates.length,
              controller: ScrollController(
                initialScrollOffset: initialScrollPosition * 70.0,
              ),
              itemBuilder: (context, index) {
                DateTime date = visibleDates[index];
                bool isSelected = index == selectedIndex;
                bool isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                String dayNumber = date.day.toString();
                String dayOfWeek = _getDayOfWeek(date.weekday);
                String monthDisplay = '';

                if (date.month != today.month || date.year != today.year) {
                  monthDisplay = 'T${date.month}';
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      // Cập nhật ngày đã chọn vào biến static
                      ChallengeScreen.selectedDate = visibleDates[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF4FCA9C) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            isToday
                                ? Border.all(color: Color(0xFF4FCA9C), width: 2)
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNumber,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            dayOfWeek,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (monthDisplay.isNotEmpty)
                            Text(
                              monthDisplay,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color:
                                    isSelected ? Colors.white : Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF4FCA9C),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/challenge_screen_cat.png',
                          height: 200,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // Lấy ngày đã chọn
                      DateTime selectedDate =
                          selectedIndex >= 0 &&
                                  selectedIndex < visibleDates.length
                              ? visibleDates[selectedIndex]
                              : today;

                      // Định dạng ngày để hiển thị
                      String formattedDate = DateFormat(
                        'MMMM d, yyyy',
                        'vi_VN',
                      ).format(selectedDate);

                      // Điều hướng trực tiếp đến RegularHabitScreen và truyền ngày đã chọn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RegularHabitScreen(
                                initialStartDate: selectedDate,
                                formattedStartDate: formattedDate,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      '+ Thêm thử thách tại đây',
                      style: TextStyle(
                        color: Color(0xFF4FCA9C),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }
}
