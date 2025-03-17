import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final List<String> days;
  final List<String> weekDays;
  final int selectedIndex;
  final Function(int) onSelected;

  DaySelector({
    required this.days,
    required this.weekDays,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(days.length, (index) {
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
                  days[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isSelected ? Colors.black : Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  weekDays[index],
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
