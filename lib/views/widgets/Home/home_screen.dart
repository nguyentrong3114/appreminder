import 'add_event.dart';
import 'package:intl/intl.dart';
import 'week_view_calendar.dart';
import 'list_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/models/calendar.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/calendar_service.dart';
import 'package:flutter_app/views/shared/login_screen.dart';
import 'package:flutter_app/provider/setting_provider.dart';
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

  List<CalendarEvent> allEvents = [];

  final AuthService _authService = AuthService();
  final List<String> tabTitles = ["Tháng", "Danh Sách", "Tuần", "Ngày"];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await CalendarService().fetchUserEvents();
    setState(() {
      allEvents = events.cast<CalendarEvent>();
    });
  }

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

  void _showAddEventDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AddEventWidget(
        selectedDate: date,
        onAdd: (event) async {
          await _loadEvents();
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
    final use24Hour = context.watch<SettingProvider>().use24HourFormat;

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
            onPressed: () => _showAddEventDialog(selectedDate),
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
              onPressed: () => _showAddEventDialog(selectedDate),
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
    final use24Hour = context.watch<SettingProvider>().use24HourFormat;
    Map<String, List<Map<String, String>>> eventsMap = {};
    for (var event in allEvents) {
      String dateKey = DateFormat('yyyy-MM-dd').format(event.startTime);
      eventsMap.putIfAbsent(dateKey, () => []);
      eventsMap[dateKey]!.add({
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'startTime': formatTime(event.startTime, use24HourFormat: use24Hour),
        'endTime': formatTime(event.endTime, use24HourFormat: use24Hour),
      });
    }

    return ListCalendar(
      selectedDate: selectedDate,
      onDateSelected: (date) => setState(() => selectedDate = date),
      allEvents: eventsMap,
      onAddEvent: (date) => _showAddEventDialog(date),
    );
  }

  Widget _buildListView() {
    final use24Hour = context.watch<SettingProvider>().use24HourFormat;
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Sửa",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddEventWidget(
                                  selectedDate: event.startTime,
                                  event: event,
                                  onAdd: (updatedEvent) async {
                                    await _loadEvents();
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Xóa",
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text('Bạn có chắc muốn xóa sự kiện này không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await CalendarService().deleteEvent(event.id);
                                await _loadEvents();
                              }
                            },
                          ),
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
    final startWeekOn = context.watch<SettingProvider>().startWeekOn;
    final now = DateTime.now();
    return WeekListView(
      allEvents: allEvents,
      startWeekOn: startWeekOn,
      selectedYear: DateTime(now.year),
    );
  }
Widget _buildDayView() {
  // Luôn lấy ngày đang chọn, không phải today
  final day = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  final eventsOfDay = allEvents.where((e) {
    if (e.allDay) {
      return e.startTime.year == day.year &&
          e.startTime.month == day.month &&
          e.startTime.day == day.day;
    }
    final start = e.startTime;
    final end = e.endTime;
    final dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
    return (start.isBefore(dayEnd) && end.isAfter(dayStart)) ||
        (start.isAtSameMomentAs(dayStart) || start.isAtSameMomentAs(dayEnd)) ||
        (end.isAtSameMomentAs(dayStart) || end.isAtSameMomentAs(dayEnd));
  }).toList();

  return WeekDayCalendar(
    selectedDate: day,
    events: eventsOfDay,
  );
}

  String _shorten(String text, {int max = 28}) {
    if (text.length <= max) return text;
    return text.substring(0, max - 3) + '...';
  }
}
