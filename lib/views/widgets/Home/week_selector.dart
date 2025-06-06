import 'package:flutter/material.dart';

class WeekSelector extends StatelessWidget {
  final List<String> weeks;
  final int selectedIndex;
  final ValueChanged<int> onWeekSelected;

  const WeekSelector({
    required this.weeks,
    required this.selectedIndex,
    required this.onWeekSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(weeks.length, (index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onWeekSelected(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              weeks[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}

List<String> generateWeeks(int year) {
  final int lastWeek = isoWeekNumber(DateTime(year, 12, 28));
  List<String> weeks = [];
  for (int i = 1; i <= lastWeek; i++) {
    weeks.add("Tuần $i $year");
  }
  return weeks;
}

int isoWeekNumber(DateTime date) {
  final DateTime thursday = date.add(Duration(days: (4 - date.weekday)));
  final DateTime firstThursday = DateTime(
    thursday.year,
    1,
    1,
  ).add(Duration(days: (4 - DateTime(thursday.year, 1, 1).weekday)));
  return 1 + ((thursday.difference(firstThursday).inDays) / 7).floor();
}
