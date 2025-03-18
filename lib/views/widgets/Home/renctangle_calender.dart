import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final Map<String, List<Map<String, String>>> allEvents;
  final int selectedIndex;
  final Function(int) onSelected;

  DaySelector({
    required this.allEvents,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<String> daysWithEvents = allEvents.keys.toList();
    List<String> weekDaysWithEvents = daysWithEvents.map((day) {
      return allEvents[day]!.first['weekDay'] ?? '';
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(daysWithEvents.length, (index) {
        bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            width: 60,
            height: 90,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.green.shade600 : Colors.grey.shade400,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 18),
                Text(
                  daysWithEvents[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isSelected ? Colors.black : Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  weekDaysWithEvents[index], 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected ? Colors.black : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
