import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/home_screen.dart';
import 'views/add_event_screen.dart';
import 'views/challenge_screen.dart';
import 'views/add_challenge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  runApp(
    MaterialApp(
      home: MainScreen(),
      routes: {
        '/add_event': (context) => AddEventScreen(),
        '/add_challenge': (context) => AddChallengeScreen(),
      },
    ),
  );
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    Container(), // Placeholder cho trang "Quản lý"
    ChallengeScreen(),
    Container(), // Placeholder cho trang "Cài đặt"
  ];

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
            child: Container(
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
        offset: Offset(0, -10),
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: () {
              if (_selectedIndex == 2) {
                // Nếu đang ở ChallengeScreen
                Navigator.pushNamed(context, '/add_challenge');
              } else {
                Navigator.pushNamed(context, '/add_event');
              }
            },
            child: Icon(Icons.add, size: 38, color: Colors.white),
            backgroundColor: Color(0xFF4FCA9C),
            shape: CircleBorder(),
            elevation: 0.0,
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
            Icon(icon, size: 28, color: itemColor),
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
