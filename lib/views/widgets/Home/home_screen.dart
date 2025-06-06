import 'add_event.dart';
import 'package:intl/intl.dart';
import 'week_view_calendar.dart';
import 'list_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/views/shared/login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  int selectedTab = 0;
  int selectedDayIndex = 0;
  int selectedWeekIndex = 0;
  final AuthService _authService = AuthService();

  final List<String> tabTitles = ["Tháng", "Danh Sách", "Tuần", "Ngày"];

  // Dummy data, replace with your real data source
  final Map<String, List<Map<String, String>>> allEvents = {
    "1": [
      {
        "title": "Cuộc họp nhóm phát triển ứng dụng Flutter siêu dài...",
        "description": "Thảo luận dự án Flutter, phân chia công việc, cập nhật tiến độ...",
        "weekDay": "T2",
        "time": "8:00 - 9:00",
      },
      {
        "title": "Tập Gym",
        "description": "Luyện tập thể lực tại phòng gym trung tâm",
        "weekDay": "T2",
        "time": "10:00 - 12:00",
      },
    ],
    "2": [
      {
        "title": "Đi siêu thị",
        "description": "Mua đồ dùng gia đình, thực phẩm, vật dụng cá nhân...",
        "weekDay": "T3",
        "time": "20:00 - 21:00",
      },
      {
        "title": "Học tiếng Anh",
        "description": "Ôn luyện từ vựng và ngữ pháp",
        "weekDay": "T3",
        "time": "18:00 - 19:00",
      },
    ],
    "5": [
      {
        "title": "Xem phim",
        "description": "Thư giãn cuối tuần cùng bạn bè tại rạp",
        "weekDay": "T6",
        "time": "20:00 - 21:00",
      },
    ],
    "10": [
      {
        "title": "Sinh nhật mẹ",
        "description": "Chuẩn bị quà và tổ chức tiệc sinh nhật",
        "weekDay": "CN",
        "time": "Cả ngày",
      },
    ],
  };

  Future<void> _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void _changeMonth(int step) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + step, 1);
    });
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventWidget(selectedDate: selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined, color: AppColors.primary),
          onPressed: () => _logout(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              DateFormat('MM yyyy', 'vi').format(selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.secondary),
            tooltip: "Thêm sự kiện",
            onPressed: _showAddEventDialog,
          ),
          IconButton(icon: const Icon(Icons.menu, color: AppColors.secondary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: AppColors.secondary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
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
      floatingActionButton: selectedTab == 1
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showAddEventDialog,
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: "Thêm sự kiện",
            )
          : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabTitles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedTab == index;
          return ChoiceChip(
            label: Text(
              tabTitles[index],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.background,
            onSelected: (_) => setState(() => selectedTab = index),
          );
        },
      ),
    );
  }

  Widget _buildMonthView() {
    return ListCalendar(
      selectedDate: selectedDate,
      onDateSelected: (date) => setState(() => selectedDate = date),
    );
  }

  Widget _buildListView() {
    final eventDays = allEvents.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final currentIndex = (selectedDayIndex >= 0 && selectedDayIndex < eventDays.length) ? selectedDayIndex : 0;
    final events = allEvents[eventDays[currentIndex]] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildDaySelector(eventDays, currentIndex),
        const SizedBox(height: 10),
        Expanded(
          child: events.isNotEmpty
              ? ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final event = events[idx];
                    return ListTile(
                      leading: const Icon(Icons.event, color: AppColors.primary),
                      title: Text(
                        _shorten(event["title"] ?? ""),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        _shorten(event["description"] ?? ""),
                        style: const TextStyle(color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event["weekDay"] ?? "", style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                          Text(event["time"] ?? "", style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "Không có sự kiện nào trong ngày này",
                    style: TextStyle(fontSize: 16, color: AppColors.text),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(List<String> eventDays, int currentIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(eventDays.length, (index) {
          final isSelected = currentIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                  width: 1,
                ),
              ),
              child: Text(
                "Ngày ${eventDays[index]}",
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekView() {
    return const WeekView();
  }

  Widget _buildDayView() {
    return const Center(
      child: Text(
        "Lịch Ngày",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
      ),
    );
  }

  String _shorten(String text, {int max = 28}) {
    if (text.length <= max) return text;
    return text.substring(0, max - 3) + '...';
  }
}
