import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final Map<String, List<Map<String, String>>> allEvents;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DaySelector({
    required this.allEvents,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> daysWithEvents = allEvents.keys.toList();
    return Row(
      children: List.generate(daysWithEvents.length, (index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Ngày ${daysWithEvents[index]}",
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
