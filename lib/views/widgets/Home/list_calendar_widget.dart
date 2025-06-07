import 'quick_view_event.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';

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
  static const List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  late DateTime _selectedDate;
  late List<DateTime> _daysInView;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _daysInView = _generateDaysForMonth(_selectedDate);
  }

  @override
  void didUpdateWidget(covariant ListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameMonth(oldWidget.selectedDate, widget.selectedDate)) {
      _selectedDate = widget.selectedDate;
      _daysInView = _generateDaysForMonth(_selectedDate);
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  List<DateTime> _generateDaysForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final totalDays = DateUtils.getDaysInMonth(date.year, date.month);
    final leadingEmpty = firstDay.weekday == 7 ? 0 : firstDay.weekday - 1;
    return List<DateTime>.generate(
      leadingEmpty + totalDays,
      (i) => i < leadingEmpty ? DateTime(0) : DateTime(date.year, date.month, i - leadingEmpty + 1),
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Column(
      children: [
        // Header thứ/ngày
        Row(
          children: List.generate(7, (index) {
            final isSunday = index == 6;
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

    return GestureDetector(
      onTap: () {
        if (hasEvents) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => QuickViewEventScreen(
              events: widget.events,
              date: widget.date,
              onAddEvent: widget.onAddEvent, // truyền callback add event
            ),
          );
        } else {
          widget.onTap?.call();
        }
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
                  ...widget.events.take(2).map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          e['title'] ?? '',
                          style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )),
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

