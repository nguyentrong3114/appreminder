import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';

/// Lịch dạng lưới cuộn ngang, tự quản lý trạng thái ngày được chọn.
class ListCalendar extends StatefulWidget {
  /// Map<dayString, List<event>>
  final Map<String, List<Map<String, String>>> allEvents;

  /// Gọi khi người dùng chọn ngày mới (tùy chọn).
  final void Function(DateTime)? onDateSelected;

  /// Gọi khi double-tap vào ô ngày (tùy chọn) – thường để thêm sự kiện.
  final void Function(DateTime)? onAddEvent;

  /// Ngày được chọn ban đầu, mặc định là hôm nay.
  final DateTime initialDate;

  ListCalendar({
    super.key,
    required this.allEvents,
    this.onDateSelected,
    this.onAddEvent,
    DateTime? initialDate, required DateTime selectedDate,
  }) : initialDate = initialDate ?? DateTime.now();

  @override
  State<ListCalendar> createState() => _ListCalendarState();
}

class _ListCalendarState extends State<ListCalendar> {
  static const List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  late DateTime _selectedDate;

  /// Danh sách tất cả ô (bao gồm ô trống) trong tháng hiện tại.
  late List<DateTime> _daysInView;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _daysInView = _generateDaysForMonth(_selectedDate);
  }

  @override
  void didUpdateWidget(covariant ListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu cha gửi xuống tháng khác, cập nhật lại.
    if (!_isSameMonth(oldWidget.initialDate, widget.initialDate)) {
      _selectedDate = widget.initialDate;
      _daysInView = _generateDaysForMonth(_selectedDate);
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  /// Tạo list DateTime chứa cả các ô rỗng đầu tháng.
  List<DateTime> _generateDaysForMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final totalDays = DateUtils.getDaysInMonth(date.year, date.month);
    final leadingEmpty = firstDay.weekday - 1; // số ô trống đầu tuần
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
        // Hàng tiêu đề thứ/ngày
        Row(
          children: List.generate(7, (index) {
            final isSunday = index == 6;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
        const SizedBox(height: 4),
        // Lưới ngày
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: _daysInView.length,
            itemBuilder: (context, index) {
              final date = _daysInView[index];
              if (date.year == 0) return const SizedBox.shrink(); // ô trống

              final day = date.day;
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final isToday = DateUtils.isSameDay(date, today);
              final events = widget.allEvents[day.toString()] ?? [];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                  widget.onDateSelected?.call(date);
                },
                onDoubleTap: () => widget.onAddEvent?.call(date),
                child: _DayCell(
                  day: day,
                  date: date,
                  events: events,
                  isSelected: isSelected,
                  isToday: isToday,
                  onAddEvent: widget.onAddEvent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Widget ô ngày riêng để tránh build toàn lưới.
class _DayCell extends StatefulWidget {
  final int day;
  final DateTime date;
  final List<Map<String, String>> events;
  final bool isSelected;
  final bool isToday;
  final void Function(DateTime)? onAddEvent;

  const _DayCell({
    required this.day,
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    this.onAddEvent,
    Key? key,
  }) : super(key: key);

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.primary.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : Colors.grey.shade300,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  '${widget.day}',
                  style: TextStyle(
                    color: widget.isToday
                        ? AppColors.secondary
                        : widget.isSelected
                            ? AppColors.primary
                            : AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // ...hiển thị sự kiện nếu muốn...
              ],
            ),
            if (_isHovering)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => widget.onAddEvent?.call(widget.date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

