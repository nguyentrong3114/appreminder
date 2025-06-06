import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart';
import 'package:intl/intl.dart';
import 'add_challenge_screen.dart';
import '../../../models/habit.dart';
import '../../../services/habit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'statistics_screen.dart';

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
  List<Habit> habitsForSelectedDate = [];
  Map<String, bool> habitCompletionStatus = {};

  final HabitService _habitService = HabitService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        ChallengeScreen.selectedDate = visibleDates[i];
        break;
      }
    }
    _loadHabitsForSelectedDate();
  }

  void _generateDates() {
    visibleDates = List.generate(500, (index) {
      return today.add(Duration(days: index - initialScrollPosition));
    });
  }

  void _navigateToStatistics(Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatisticsScreen(habit: habit)),
    );
  }

  Future<void> _loadHabitsForSelectedDate() async {
    if (_auth.currentUser == null) {
      print('❌ User chưa đăng nhập');
      return;
    }

    DateTime selectedDate =
        selectedIndex >= 0 && selectedIndex < visibleDates.length
            ? visibleDates[selectedIndex]
            : today;

    try {
      _habitService.getAllHabits().listen((habits) {
        List<Habit> filteredHabits = [];
        Map<String, bool> completionStatus = {};

        for (Habit habit in habits) {
          if (_shouldShowHabitOnDate(habit, selectedDate)) {
            filteredHabits.add(habit);
            _checkHabitCompletion(habit.id, selectedDate).then((isCompleted) {
              setState(() {
                habitCompletionStatus[habit.id] = isCompleted;
              });
            });
          }
        }

        setState(() {
          habitsForSelectedDate = filteredHabits;
        });
      });
    } catch (e) {
      print('❌ Lỗi khi tải habits: $e');
    }
  }

  bool _shouldShowHabitOnDate(Habit habit, DateTime date) {
    if (habit.startDate.isAfter(date)) return false;

    if (habit.hasEndDate &&
        habit.endDate != null &&
        habit.endDate!.isBefore(date)) {
      return false;
    }

    if (habit.type == HabitType.onetime) {
      return habit.startDate.year == date.year &&
          habit.startDate.month == date.month &&
          habit.startDate.day == date.day;
    }

    switch (habit.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return habit.selectedWeekdays.contains(date.weekday);
      case RepeatType.monthly:
        return habit.monthlyDay == date.day;
      case RepeatType.yearly:
        return habit.startDate.month == date.month &&
            habit.startDate.day == date.day;
      default:
        return true;
    }
  }

  Future<bool> _checkHabitCompletion(String habitId, DateTime date) async {
    if (_auth.currentUser == null) return false;

    String userId = _auth.currentUser!.uid;
    String dateKey = DateFormat('yyyy-MM-dd').format(date);

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('habit_completions')
              .doc('${habitId}_$dateKey')
              .get();

      return doc.exists &&
          (doc.data() as Map<String, dynamic>)['completed'] == true;
    } catch (e) {
      print('❌ Lỗi check completion: $e');
      return false;
    }
  }

  Future<void> _handleHabitCompletion(String habitId) async {
    bool isCurrentlyCompleted = habitCompletionStatus[habitId] ?? false;

    if (!isCurrentlyCompleted) {
      // Nếu chưa hoàn thành, hiện dialog đánh giá
      _showRatingDialog(habitId);
    } else {
      // Nếu đã hoàn thành, bỏ đánh dấu hoàn thành
      await _toggleHabitCompletion(habitId, rating: null);
    }
  }

  // ✅ Widget tạo ngôi sao có viền
  Widget _buildStarWithBorder({
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        child: Stack(
          children: [
            // Viền đen cho ngôi sao: dùng Stack với Icon star_border màu đen lớn hơn
            Icon(
              Icons.star_border,
              size: 37, // Giảm kích thước viền ngoài để viền mỏng hơn
              color: Colors.black38, // Đen nhạt hơn
            ),
            // Ngôi sao bên trong
            Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 36, // Chỉ chênh lệch 1 để viền rất mỏng
              color: isFilled ? Colors.amber : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog với ngôi sao có viền đen đúng cách
  void _showRatingDialog(String habitId) {
    int selectedRating = 0; // Bắt đầu với 0 sao
    String? message;
    String? imagePath;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Nếu chưa chọn sao nào, hiện câu hỏi
                    if (selectedRating == 0) ...[
                      Text(
                        'Làm tốt lắm.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bạn cảm thấy như thế nào?',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                    ],

                    // ✅ Nếu đã chọn sao, hiện ảnh tương ứng (nhỏ hơn)
                    if (selectedRating > 0) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Image.asset(
                          imagePath!,
                          height: 70, // ✅ Giảm từ 100 xuống 70
                          width: 70, // ✅ Giảm từ 100 xuống 70
                        ),
                      ),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                    ],

                    // ✅ 5 ngôi sao với viền đen đúng cách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        int rating = index + 1;
                        bool isSelected = rating <= selectedRating;

                        return _buildStarWithBorder(
                          isFilled: isSelected,
                          onTap: () {
                            setDialogState(() {
                              selectedRating = rating;
                              switch (rating) {
                                case 1:
                                  message = 'Bad';
                                  imagePath = 'assets/images/1star.png';
                                  break;
                                case 2:
                                  message = 'Not so good';
                                  imagePath = 'assets/images/2star.png';
                                  break;
                                case 3:
                                  message = 'Normal';
                                  imagePath = 'assets/images/3star.png';
                                  break;
                                case 4:
                                  message = 'Good';
                                  imagePath = 'assets/images/4star.png';
                                  break;
                                case 5:
                                  message = 'Very good';
                                  imagePath = 'assets/images/5star.png';
                                  break;
                              }
                            });
                          },
                        );
                      }),
                    ),

                    SizedBox(height: 24),

                    // ✅ Nút Sau và Lưu
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Sau',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              int ratingToSave =
                                  selectedRating > 0 ? selectedRating : 5;
                              await _toggleHabitCompletion(
                                habitId,
                                rating: ratingToSave,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4FCA9C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Lưu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

  Future<void> _toggleHabitCompletion(String habitId, {int? rating}) async {
    if (_auth.currentUser == null) return;

    String userId = _auth.currentUser!.uid;
    DateTime selectedDate =
        selectedIndex >= 0 && selectedIndex < visibleDates.length
            ? visibleDates[selectedIndex]
            : today;
    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      bool currentStatus = habitCompletionStatus[habitId] ?? false;
      bool newStatus = rating != null ? true : !currentStatus;

      Map<String, dynamic> data = {
        'habitId': habitId,
        'date': Timestamp.fromDate(selectedDate),
        'completed': newStatus,
        'completedAt': Timestamp.now(),
        'userId': userId,
      };

      if (rating != null) {
        data['rating'] = rating;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('habit_completions')
          .doc('${habitId}_$dateKey')
          .set(data);

      setState(() {
        habitCompletionStatus[habitId] = newStatus;
      });
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái: $e');
    }
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
    if (_auth.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Vui lòng đăng nhập để xem thử thách',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

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
          // Calendar horizontal scroll
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
                      ChallengeScreen.selectedDate = visibleDates[index];
                    });
                    _loadHabitsForSelectedDate();
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

          // Danh sách habits
          Expanded(
            child:
                habitsForSelectedDate.isEmpty
                    ? Center(
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
                              DateTime selectedDate =
                                  selectedIndex >= 0 &&
                                          selectedIndex < visibleDates.length
                                      ? visibleDates[selectedIndex]
                                      : today;
                              String formattedDate = DateFormat(
                                'MMMM d, yyyy',
                                'vi_VN',
                              ).format(selectedDate);

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
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: habitsForSelectedDate.length,
                      itemBuilder: (context, index) {
                        Habit habit = habitsForSelectedDate[index];
                        bool isCompleted =
                            habitCompletionStatus[habit.id] ?? false;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
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
                              // ✅ Dấu gạch đứng tách ra 1 chút từ mép
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                width: 6,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(habit.colorValue)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              SizedBox(width: 8),

                              // ✅ Expanded để ListTile chiếm hết không gian còn lại
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(habit.colorValue)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      IconData(
                                        int.parse(habit.iconCodePoint),
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    habit.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap:
                                      () => _navigateToStatistics(
                                        habit,
                                      ), // ✅ Thêm dòng này
                                  trailing: GestureDetector(
                                    onTap:
                                        () => _handleHabitCompletion(habit.id),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color:
                                            isCompleted
                                                ? Color(
                                                  int.parse(habit.colorValue),
                                                )
                                                : Colors.transparent,
                                        border: Border.all(
                                          color: Color(
                                            int.parse(habit.colorValue),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child:
                                          isCompleted
                                              ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                              : null,
                                    ),
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
