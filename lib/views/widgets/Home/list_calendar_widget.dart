import 'quick_view_event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/provider/setting_provider.dart';

class ListCalendar extends StatefulWidget {
  final Map<String, List<Map<String, String>>> allEvents;
  final void Function(DateTime)? onDateSelected;
  final void Function(DateTime)? onAddEvent;
  final DateTime selectedDate;

  const ListCalendar({
    super.key,
    required this.allEvents,
    this.onDateSelected,
    this.onAddEvent,
    required this.selectedDate,
  });

  @override
  State<ListCalendar> createState() => _ListCalendarState();
}

class _ListCalendarState extends State<ListCalendar> {
  late DateTime _selectedDate;
  late List<DateTime> _daysInView;
  late int _startWeekOn;
  late List<String> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _startWeekOn = context.read<SettingProvider>().startWeekOn;
    _weekDays = List<String>.from(_rotateWeekDays(_startWeekOn));
    _daysInView = _generateDaysForMonth(_selectedDate);
  }

  @override
  void didUpdateWidget(covariant ListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameMonth(oldWidget.selectedDate, widget.selectedDate)) {
      _selectedDate = widget.selectedDate;
      _daysInView = _generateDaysForMonth(_selectedDate);
    }
    // Nếu setting startWeekOn thay đổi, cập nhật lại
    final newStartWeekOn = context.read<SettingProvider>().startWeekOn;
    if (newStartWeekOn != _startWeekOn) {
      setState(() {
        _startWeekOn = newStartWeekOn;
        _weekDays = List<String>.from(_rotateWeekDays(_startWeekOn));
        _daysInView = _generateDaysForMonth(_selectedDate);
      });
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  List<String> _rotateWeekDays(int startWeekOn) {
    // startWeekOn: 0=Monday, 6=Sunday
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    // Nếu startWeekOn == 6 (Chủ nhật), đưa 'CN' lên đầu
    if (startWeekOn == 6) {
      return ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    }
    if (startWeekOn == 0) {
      return days;
    }
    // Các trường hợp khác: xoay mảng bắt đầu từ vị trí startWeekOn
    return List.generate(7, (i) => days[(i + startWeekOn) % 7]);
  }

  List<DateTime> _generateDaysForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final totalDays = DateUtils.getDaysInMonth(date.year, date.month);
    int weekStartParam = _startWeekOn == 6 ? 7 : _startWeekOn + 1;
    final weekStart = getWeekStartDate(firstDay, weekStartParam);
    final leadingEmpty = firstDay.difference(weekStart).inDays;
    final totalCells = ((leadingEmpty + totalDays) / 7).ceil() * 7;
    return List<DateTime>.generate(
      totalCells,
      (i) => i < leadingEmpty
          ? weekStart.add(Duration(days: i))
          : (i - leadingEmpty) < totalDays
              ? DateTime(date.year, date.month, i - leadingEmpty + 1)
              : DateTime(0), 
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header thứ/ngày
        Row(
          children: List.generate(7, (index) {
            final isSunday = _weekDays[index] == 'CN';
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSunday ? AppColors.error.withOpacity(0.08) : AppColors.background,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Text(
                  _weekDays[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSunday ? AppColors.error : AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Lưới ngày
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 0.6,
            ),
            itemCount: _daysInView.length,
            itemBuilder: (context, index) {
              final date = _daysInView[index];
              if (date.year == 0) return const SizedBox.shrink(); // ô trống
              final day = date.day;
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, DateTime.now());
              final events = widget.allEvents[DateFormat('yyyy-MM-dd').format(date)] ?? [];

              return _DayCell(
                day: day,
                date: date,
                events: events,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected?.call(date);
                },
                onAddEvent: widget.onAddEvent,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatefulWidget {
  final int day;
  final DateTime date;
  final List<Map<String, String>> events;
  final bool isSelected;
  final bool isToday;
  final void Function()? onTap;
  final void Function(DateTime)? onAddEvent;

  const _DayCell({
    required this.day,
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    this.onTap,
    this.onAddEvent,
    Key? key,
  }) : super(key: key);

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  @override
  Widget build(BuildContext context) {
    final hasEvents = widget.events.isNotEmpty;

    Color getEventColor(DateTime start, DateTime end) {
      final now = DateTime.now();
      if (end.isBefore(now)) {
        return Colors.red; 
      } else if (start.isAfter(now) && start.isBefore(now.add(const Duration(hours: 2)))) {
        return Colors.amber; 
      } else if (start.isAfter(now)) {
        return Colors.green; 
      } else {
        return Colors.amber; 
      }
    }

    return GestureDetector(
      onTap: () {
        widget.onTap?.call(); // Luôn cập nhật selected day
        if (hasEvents) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => QuickViewEventScreen(
              events: widget.events,
              date: widget.date,
              onAddEvent: widget.onAddEvent,
            ),
          );
        }
        // Nếu không có sự kiện, chỉ cập nhật selected day và hiện dấu cộng (đã xử lý ở dưới)
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.green.withOpacity(0.13) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected ? Colors.green : Colors.grey.shade300,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Số ngày luôn ở góc trên trái
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                '${widget.day}',
                style: TextStyle(
                  color: widget.isToday
                      ? Colors.orange
                      : widget.isSelected
                          ? Colors.green
                          : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Hiển thị sự kiện (tối đa 2 dòng) dưới số ngày
            Positioned(
              top: 24,
              left: 2,
              right: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.events.take(2).map((e) {
                        DateTime? start;
                        DateTime? end;
                        try {
                          start = DateFormat('HH:mm').parse(e['startTime'] ?? '', true);
                          end = DateFormat('HH:mm').parse(e['endTime'] ?? '', true);
                          start = DateTime(widget.date.year, widget.date.month, widget.date.day, start.hour, start.minute);
                          end = DateTime(widget.date.year, widget.date.month, widget.date.day, end.hour, end.minute);
                        } catch (_) {
                          start = null;
                          end = null;
                        }
                        final color = (start != null && end != null)
                            ? getEventColor(start, end)
                            : Colors.blueGrey;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            e['title'] ?? '',
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }),
                  if (widget.events.length > 2)
                    const Text('...', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                ],
              ),
            ),
            // Chỉ hiện dấu cộng khi selected và không có sự kiện
            if (!hasEvents && widget.isSelected)
              Center(
                child: GestureDetector(
                  onTap: () => widget.onAddEvent?.call(widget.date),
                  child: Icon(Icons.add_circle, color: Colors.green, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

