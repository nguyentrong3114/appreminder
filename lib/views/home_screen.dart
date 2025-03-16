import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'widgets/list_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now(); // Ngày được chọn
  List<String> items = ["Tháng", "Danh Sách", "Tuần", "Ngày"];
  int selectedIndex = 0;
  int _bottomNavIndex = 0; // Mục được chọn trong Bottom Navigation Bar

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  // Hàm cập nhật tháng
  void _changeMonth(int step) {
    setState(() {
      int newMonth = selectedDate.month + step;
      int newYear = selectedDate.year;

      if (newMonth > 12) {
        newYear += (newMonth - 1) ~/ 12;
        newMonth = (newMonth - 1) % 12 + 1;
      } else if (newMonth < 1) {
        newYear += (newMonth ~/ 12) - 1;
        newMonth = 12 + (newMonth % 12);
      }

      selectedDate = DateTime(newYear, newMonth, 1);
    });
  }

  // Chuyển trang trong Bottom Navigation Bar
  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });

    // Điều hướng tới các trang khác (có thể mở rộng)
    switch (index) {
      case 0:
        // Ở lại trang Home
        break;
      case 1:
        // Điều hướng tới trang Calendar (nếu có)
        break;
      case 2:
        // Điều hướng tới trang Settings (nếu có)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.star),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _changeMonth(-1), // Chuyển tháng về trước
            ),
            SizedBox(width: 8),
            Text(
              DateFormat('MM yyyy', 'vi').format(selectedDate), // Cập nhật tháng
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () => _changeMonth(1), // Chuyển tháng về sau
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 350,
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          items[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: ListCalendar(
              selectedDate: selectedDate,
              onDateSelected: _onDateSelected,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_event');
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Quản Lí',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
