import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'views/shared/login_screen.dart';
import 'views/widgets/manage/todo.dart';
import 'views/widgets/setting/setting.dart';
import 'views/widgets/home/home_screen.dart';
import 'views/widgets/manage/add_todo_screen.dart';
import 'views/widgets/manage/add_notes_screen.dart';
import 'views/widgets/manage/add_diary_screen.dart';
import 'views/widgets/home/add_something_today.dart';
import 'views/widgets/challenge/challenge_screen.dart';
import 'views/widgets/challenge/add_onetime_task.dart';
import 'views/widgets/challenge/add_challenge_screen.dart';
import 'views/widgets/challenge/add_regular_habit_screen.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => LoginScreen(),
        '/add_todo': (context) => const TodoScreen(),
        '/add_setting': (context) => const SettingsPage(),
        '/add_regular_habit': (context) => RegularHabitScreen(
              initialStartDate: ChallengeScreen.selectedDate ?? DateTime.now(),
              formattedStartDate: DateFormat('MMMM d, yyyy', 'vi_VN')
                  .format(ChallengeScreen.selectedDate ?? DateTime.now()),
            ),
        '/add_events_home': (context) => const AddSomethingToday(),
        '/add_challenge': (context) => AddChallengeScreen(),
        '/add_onetime_task': (context) => OnetimeTask(
              initialStartDate: ChallengeScreen.selectedDate ?? DateTime.now(),
              formattedStartDate: DateFormat('MMMM d, yyyy', 'vi_VN')
                  .format(ChallengeScreen.selectedDate ?? DateTime.now()),
            ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<TodoState> todoKey = GlobalKey<TodoState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    Todo(key: todoKey),
    ChallengeScreen(),
    const SettingsPage(),
    Container(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildNavItem(IconData icon, String label, int index) {
    final Color itemColor = _selectedIndex == index ? const Color(0xFF4FCA9C) : Colors.grey;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: itemColor),
            const SizedBox(height: 2),
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

  void _onFabPressed() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddSomethingToday()),
      );
    } else if (_selectedIndex == 1) {
      final todoState = todoKey.currentState;
      if (todoState != null) {
        if (todoState.selectedTab == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoScreen(initialStartDate: todoState.selectedDate),
            ),
          );
        } else if (todoState.selectedTab == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        } else if (todoState.selectedTab == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiaryScreen()),
          );
        }
      }
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddChallengeScreen()),
      );
    } else if (_selectedIndex == 3) {
      Navigator.pushNamed(context, '/add_setting');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegularHabitScreen(
            initialStartDate: ChallengeScreen.selectedDate ?? DateTime.now(),
            formattedStartDate: DateFormat('MMMM d, yyyy', 'vi_VN')
                .format(ChallengeScreen.selectedDate ?? DateTime.now()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.calendar_today, "Lịch", 0),
              buildNavItem(Icons.menu_book, "Quản lý", 1),
              const SizedBox(width: 60),
              buildNavItem(Icons.extension, "Thử thách", 2),
              buildNavItem(Icons.settings, "Cài đặt", 3),
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -5),
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: _onFabPressed,
            backgroundColor: const Color(0xFF4FCA9C),
            shape: const CircleBorder(),
            elevation: 0.0,
            child: const Icon(Icons.add, size: 48, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
