import 'add_event.dart';
import 'package:intl/intl.dart';
import 'week_view_calendar.dart';
import 'list_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/views/shared/login_screen.dart';
import 'package:flutter_app/views/widgets/Home/week_day_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  int selectedTab = 0;
  int selectedDayIndex = 0;

  List<CalendarEvent> allEvents = [
    CalendarEvent(
      title: "Cuộc họp nhóm phát triển ứng dụng Flutter siêu dài...",
      startTime: DateTime(2025, 6, 1, 8, 0),
      endTime: DateTime(2025, 6, 1, 9, 0),
      description: "Thảo luận dự án Flutter, phân chia công việc, cập nhật tiến độ...",
      location: "Phòng họp A",
    ),
    CalendarEvent(
      title: "Tập Gym",
      startTime: DateTime(2025, 6, 1, 10, 0),
      endTime: DateTime(2025, 6, 1, 12, 0),
      description: "Luyện tập thể lực tại phòng gym trung tâm",
      location: "California Fitness",
    ),
    CalendarEvent(
      title: "Đi siêu thị",
      startTime: DateTime(2025, 6, 2, 20, 0),
      endTime: DateTime(2025, 6, 2, 21, 0),
      description: "Mua đồ dùng gia đình, thực phẩm, vật dụng cá nhân...",
      location: "Vinmart",
    ),
  ];

  final AuthService _authService = AuthService();
  final List<String> tabTitles = ["Tháng", "Danh Sách", "Tuần", "Ngày"];

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
      builder: (context) => AddEventWidget(
        selectedDate: selectedDate,
        onAdd: (event) {
          setState(() => allEvents.add(event as CalendarEvent));
        },
      ),
    );
  }

  List<CalendarEvent> eventsOfDay(DateTime date) {
    return allEvents.where((e) =>
      e.startTime.year == date.year &&
      e.startTime.month == date.month &&
      e.startTime.day == date.day
    ).toList();
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
            Builder(
              builder: (context) {
                final is2025 = selectedDate.year == 2025;
                final monthStr = 'Tháng ${selectedDate.month}';
                final title = is2025 ? monthStr : '$monthStr/${selectedDate.year}';
                return Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                );
              },
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
    // Convert List<CalendarEvent> to Map<String, List<Map<String, String>>>
    Map<String, List<Map<String, String>>> eventsMap = {};
    for (var event in allEvents) {
      String dateKey = DateFormat('yyyy-MM-dd').format(event.startTime);
      eventsMap.putIfAbsent(dateKey, () => []);
      eventsMap[dateKey]!.add({
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'startTime': DateFormat('HH:mm').format(event.startTime),
        'endTime': DateFormat('HH:mm').format(event.endTime),
      });
    }

    return ListCalendar(
      selectedDate: selectedDate,
      onDateSelected: (date) => setState(() => selectedDate = date),
      allEvents: eventsMap,
    );
  }

  Widget _buildListView() {
    // Lấy danh sách các ngày có sự kiện (dạng DateTime, không chỉ lấy day để tránh trùng ngày khác tháng/năm)
    final eventDays = allEvents
        .map((e) => DateTime(e.startTime.year, e.startTime.month, e.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    final currentIndex = (selectedDayIndex >= 0 && selectedDayIndex < eventDays.length)
        ? selectedDayIndex
        : 0;

    final currentDay = eventDays.isNotEmpty ? eventDays[currentIndex] : null;

    final events = currentDay != null
        ? allEvents.where((e) =>
            e.startTime.year == currentDay.year &&
            e.startTime.month == currentDay.month &&
            e.startTime.day == currentDay.day)
        .toList()
        : [];

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
                        _shorten(event.title),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        _shorten(event.description),
                        style: const TextStyle(color: AppColors.text),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(DateFormat('dd/MM/yyyy').format(event.startTime)),
                          Text("${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}"),
                          if (event.location.isNotEmpty)
                            Text(event.location, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
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

  Widget _buildDaySelector(List<DateTime> eventDays, int currentIndex) {
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
                DateFormat("dd/MM").format(eventDays[index]),
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
    final events = eventsOfDay(selectedDate);
    return WeekDayCalendar(
      selectedDate: selectedDate,
      events: events,
    );
  }

  String _shorten(String text, {int max = 28}) {
    if (text.length <= max) return text;
    return text.substring(0, max - 3) + '...';
  }
}
