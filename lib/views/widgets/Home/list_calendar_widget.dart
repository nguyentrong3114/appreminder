import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';

class ListCalendar extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;
  final Map<String, List<Map<String, String>>> allEvents;

  const ListCalendar({
    required this.onDateSelected,
    required this.selectedDate,
    required this.allEvents,
    super.key,
  });

  static const List<String> weekDays = [
    'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'
  ];

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final today = DateTime.now();

    final double gridWidth = MediaQuery.of(context).size.width * 1.5;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: gridWidth,
          child: Column(
            children: [
              // Dòng tiêu đề thứ/ngày trong tuần
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
                        weekDays[index],
                        style: TextStyle(
                          color: isSunday ? AppColors.error : AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: daysInMonth + firstDayOfMonth.weekday - 1,
                  itemBuilder: (context, index) {
                    if (index < firstDayOfMonth.weekday - 1) {
                      return const SizedBox.shrink();
                    }
                    final day = index - firstDayOfMonth.weekday + 2;
                    final date = DateTime(selectedDate.year, selectedDate.month, day);
                    final isSelected = DateUtils.isSameDay(date, selectedDate);
                    final isToday = DateUtils.isSameDay(date, today);

                    String dayKey = day.toString();
                    final events = allEvents[dayKey] ?? [];

                    return GestureDetector(
                      onTap: () => onDateSelected(date),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '$day',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? AppColors.secondary // Ngày hiện tại sẽ có màu nổi bật
                                        : AppColors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (events.isNotEmpty)
                              ..._buildEventTitles(events, isSelected),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventTitles(List<Map<String, String>> events, bool isSelected) {
    List<Widget> widgets = [];
    int maxShow = 2;
    for (int i = 0; i < events.length && i < maxShow; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            _shorten(events[i]['title'] ?? ''),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (events.length > maxShow) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '+${events.length - maxShow} sự kiện',
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return widgets;
  }

  String _shorten(String text, {int max = 14}) {
    if (text.length <= max) return text;
    return text.substring(0, max - 3) + '...';
  }
}
