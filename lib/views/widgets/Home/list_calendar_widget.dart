import 'package:flutter/material.dart';
import 'package:flutter_app/views/widgets/home/add_event.dart';

class ListCalendar extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  const ListCalendar({
    required this.onDateSelected,
    required this.selectedDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + firstDayOfMonth.weekday - 1,
      itemBuilder: (context, index) {
        if (index < firstDayOfMonth.weekday - 1) {
          return const SizedBox.shrink();
        }
        final day = index - firstDayOfMonth.weekday + 2;
        final date = DateTime(selectedDate.year, selectedDate.month, day);
        final isSelected = DateUtils.isSameDay(date, selectedDate);

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
