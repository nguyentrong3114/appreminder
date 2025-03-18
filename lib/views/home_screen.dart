import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'widgets/list_calendar_widget.dart';
import 'package:flutter_app/views/widgets/Home/week_selector.dart';
import 'package:flutter_app/views/widgets/Home/event_calendar.dart';
import 'package:flutter_app/views/widgets/Home/week_view_calendar.dart';
import 'package:flutter_app/views/widgets/Home/renctangle_calender.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> items = ["Tháng", "Danh Sách", "Tuần", "Ngày"];
  int selectedIndex = 0;
  int selectedDayIndex = 0;
  int selectedWeekIndex = 3; 
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
    Map<String, List<Map<String, String>>> allEvents = {
      "1": [
        {
          "title": "Cuộc họp nhóm",
          "description": "Thảo luận dự án Flutter",
          "weekDay": "T2",
          "time": "8 a.m - 9 a.m",
        },
        {
          "title": "Tập Gym",
          "description": "Luyện tập thể lực",
          "weekDay": "T2",
          "time": "10 a.m - 12 p.m",
        },
      ],
      "2": [
        {
          "title": "Đi siêu thị",
          "description": "Mua đồ dùng gia đình",
          "weekDay": "T3",
          "time": "8 a.m - 9 p.m",
        },
      ],
      "5": [
        {
          "title": "Xem phim",
          "description": "Thư giãn cuối tuần",
          "weekDay": "T6",
          "time": "8 a.m - 9 p.m",
        },
      ],
    };

    List<String> eventDays =
        allEvents.keys.toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    int currentIndex =
        (selectedDayIndex >= 0 && selectedDayIndex < eventDays.length)
            ? selectedDayIndex
            : 0;

    List<Map<String, String>> events = allEvents[eventDays[currentIndex]] ?? [];

    int dayNumber = int.parse(eventDays[currentIndex]);
    DateTime selectedEventDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      dayNumber,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DaySelector(
            allEvents: allEvents,
            selectedIndex: currentIndex,
            onSelected: (index) {
              setState(() {
                selectedDayIndex = index;
              });
            },
          ),
        ),

        const SizedBox(height: 10),

        if (events.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Sự Kiện Hôm Nay",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: EventCalendar(date: selectedEventDate, events: events),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Text(
              "Không có sự kiện nào trong ngày này",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildWeekView() {
    return StatefulBuilder(
      builder: (context, setState) {
        List<String> weeks = [
          "02 - 08 thg 12",
          "09 - 15 thg 12",
          "16 - 22 thg 12",
          "23 - 29 thg 12",
          "30 - 05 thg 01",
        ];

        void onWeekSelected(int index) {
          setState(() {
            selectedWeekIndex = index; 
          });
          print("Tuần được chọn: ${weeks[index]}");
        }

        return Column(
          children: [
            WeekSelector(
              weeks: weeks,
              selectedIndex: selectedWeekIndex,
              onWeekSelected: onWeekSelected,
            ),
            const Expanded(child: WeekView()), 
          ],
        );
      },
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
