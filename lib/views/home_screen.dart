import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'widgets/list_calendar_widget.dart';
import 'package:flutter_app/views/widgets/Home/event_calendar.dart';
import 'package:flutter_app/views/widgets/renctangle_calender.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> items = ["Tháng", "Danh Sách", "Tuần", "Ngày"];
  int selectedIndex = 0;
  int selectedDayIndex = 0;
  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _onDaySelected(int index) {
    setState(() {
      selectedDayIndex = index;
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

  Widget _buildTabBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap:
                () => setState(
                  () => selectedIndex = index,
                ), // Cập nhật UI khi chọn tab
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.star),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              DateFormat('MM yyyy', 'vi').format(selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildMonthView(),
                _buildListView(),
                _buildWeekView(),
                _buildDayView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_event');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //UI

  Widget _buildMonthView() {
    return ListCalendar(
      selectedDate: selectedDate,
      onDateSelected: _onDateSelected,
    );
  }

  Widget _buildListView() {
    List<String> days = ["1", "2", "3", "4", "5", "6", "7"];
    List<String> weekDays = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];

    // Danh sách sự kiện theo ngày
    Map<String, List<Map<String, String>>> allEvents = {
      "1": [
        {'title': 'Cuộc họp nhóm', 'time': '10:00 - 11:30'},
        {'title': 'Tập Gym', 'time': '18:00 - 19:00'},
      ],
      "2": [
        {'title': 'Đi siêu thị', 'time': '15:00 - 16:00'},
      ],
      "5": [
        {'title': 'Xem phim', 'time': '20:00 - 22:00'},
      ],
    };

    // Lấy danh sách sự kiện theo ngày được chọn
    List<Map<String, String>> events = allEvents[days[selectedDayIndex]] ?? [];

    return Column(
      children: [
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DaySelector(
            days: days,
            weekDays: weekDays,
            selectedIndex: selectedDayIndex,
            onSelected: _onDaySelected,
          ),
        ),
        const SizedBox(height: 10), 
        if (events.isNotEmpty)
          SizedBox(
            height: 140, 
            child: EventCalendar(date: selectedDate, events: events),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Không có sự kiện nào trong ngày này",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildWeekView() {
    return Center(
      child: Text(
        "Lịch Tuần",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayView() {
    return Center(
      child: Text(
        "Lịch Ngày",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
