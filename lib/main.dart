import 'package:flutter_app/views/widgets/manage/add_diary_screen.dart';
import 'package:flutter_app/views/widgets/manage/add_notes_screen.dart';
import 'package:flutter_app/views/widgets/manage/add_todo_screen.dart';
import 'package:flutter_app/views/widgets/manage/todo.dart';

import 'views/home_screen.dart';
import 'views/widgets/challenge/add_regular_habit_screen.dart'; // Thay đổi import
import 'views/widgets/challenge/challenge_screen.dart';
import 'package:flutter/material.dart';
import 'views/widgets/challenge/add_challenge_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'views/widgets/challenge/add_onetime_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
      routes: {
        '/add_regular_habit':
            (context) => RegularHabitScreen(
              initialStartDate: ChallengeScreen.selectedDate,
              formattedStartDate: DateFormat(
                'MMMM d, yyyy',
                'vi_VN',
              ).format(ChallengeScreen.selectedDate),
            ),
        '/add_challenge': (context) => AddChallengeScreen(),
        '/add_onetime_task':
            (context) => OnetimeTask(
              initialStartDate: ChallengeScreen.selectedDate,
              formattedStartDate: DateFormat(
                'MMMM d, yyyy',
                'vi_VN',
              ).format(ChallengeScreen.selectedDate),
            ),
      },
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<TodoState> todoKey = GlobalKey<TodoState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      Todo(key: todoKey),
      ChallengeScreen(),
      Container(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomAppBar(
            notchMargin: 8.0,
            shape: CircularNotchedRectangle(),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildNavItem(Icons.calendar_today, "Lịch", 0),
                  buildNavItem(Icons.menu_book, "Quản lý", 1),
                  SizedBox(width: 60),
                  buildNavItem(Icons.extension, "Thử thách", 2),
                  buildNavItem(Icons.settings, "Cài đặt", 3),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -5),
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: () {
              if (_selectedIndex == 1) {
                // Xử lý cho tab Quản lý (giữ nguyên code hiện tại)
              } else if (_selectedIndex == 2) {
                // Đang ở tab Thử thách
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddChallengeScreen()),
                );
              } else {
                // Các tab khác
                Navigator.pushNamed(context, '/add_regular_habit');
              }
            },
            backgroundColor: Color(0xFF4FCA9C),
            shape: CircleBorder(),
            elevation: 0.0,
            child: Icon(Icons.add, size: 48, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildNavItem(IconData icon, String label, int index) {
    final Color itemColor =
        _selectedIndex == index ? Color(0xFF4FCA9C) : Colors.grey;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: itemColor),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
