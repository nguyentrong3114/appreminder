import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'views/widgets/setting/setting.dart';
import 'views/widgets/home/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/widgets/challenge/challenge_screen.dart';
import 'views/widgets/challenge/add_onetime_task.dart';
import 'views/widgets/challenge/add_challenge_screen.dart';
import 'package:flutter_app/views/shared/login_screen.dart';
import 'package:flutter_app/views/widgets/manage/todo.dart';
import 'views/widgets/challenge/add_regular_habit_screen.dart';
import 'package:flutter_app/views/widgets/manage/add_todo_screen.dart';
import 'package:flutter_app/views/widgets/manage/add_diary_screen.dart';
import 'package:flutter_app/views/widgets/manage/add_notes_screen.dart';
import 'package:flutter_app/views/widgets/home/add_something_today.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/main': (context) => MainScreen(), // Thêm route cho MainScreen
        '/login': (context) => LoginScreen(), // Thêm route cho LoginScreen
        '/add_todo': (context) => TodoScreen(),
        '/add_setting': (context) => SettingsPage(),
        '/add_regular_habit':
            (context) => RegularHabitScreen(
              initialStartDate: ChallengeScreen.selectedDate ?? DateTime.now(),
              formattedStartDate: DateFormat(
                'MMMM d, yyyy',
                'vi_VN',
              ).format(ChallengeScreen.selectedDate ?? DateTime.now()),
            ),
        '/add_events_home': (context) => AddSomethingToday(),
        '/add_challenge': (context) => AddChallengeScreen(),
        '/add_onetime_task':
            (context) => OnetimeTask(
              initialStartDate: ChallengeScreen.selectedDate ?? DateTime.now(),
              formattedStartDate: DateFormat(
                'MMMM d, yyyy',
                'vi_VN',
              ).format(ChallengeScreen.selectedDate ?? DateTime.now()),
            ),
      },
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() {
    print("Tạo MainScreenState");
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<TodoState> todoKey = GlobalKey<TodoState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print("MainScreen initState");
    _screens = [
      HomeScreen(),
      Todo(key: todoKey),
      ChallengeScreen(),
      SettingsPage(),
      Container(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    print("MainScreen build");
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
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
            onPressed: () {
              if (_selectedIndex == 0) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            AddSomethingToday(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              } else if (_selectedIndex == 1) {
                final todoState = todoKey.currentState;
                if (todoState != null) {
                  if (todoState.selectedTab == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TodoScreen(
                              initialStartDate: todoState.selectedDate,
                            ),
                      ),
                    );
                  } else if (todoState.selectedTab == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddNoteScreen(),
                      ),
                    );
                  } else if (todoState.selectedTab == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddDiaryScreen(),
                      ),
                    );
                  }
                }
              } else if (_selectedIndex == 2) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            AddChallengeScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              } else if (_selectedIndex == 3) {
                Navigator.pushNamed(context, '/add_setting');
              } else {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            RegularHabitScreen(
                              initialStartDate:
                                  ChallengeScreen.selectedDate ??
                                  DateTime.now(),
                              formattedStartDate: DateFormat(
                                'MMMM d, yyyy',
                                'vi_VN',
                              ).format(
                                ChallengeScreen.selectedDate ?? DateTime.now(),
                              ),
                            ),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              }
            },
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
