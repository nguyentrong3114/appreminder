import 'package:flutter/material.dart';

class WeekSelector extends StatefulWidget {
  final List<String> weeks;
  final int selectedIndex;
  final ValueChanged<int> onWeekSelected;

  final List<String> months;

  const WeekSelector({
    Key? key,
    required this.weeks,
    required this.months,
    required this.selectedIndex,
    required this.onWeekSelected,
  }) : super(key: key);

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.weeks.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          return GestureDetector(
            onTap: () => widget.onWeekSelected(index),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.weeks[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Thg ${widget.months[index]}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
