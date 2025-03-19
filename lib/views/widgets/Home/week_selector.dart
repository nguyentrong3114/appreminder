import 'package:flutter/material.dart';

class WeekSelector extends StatefulWidget {
  final List<String> weeks;
  final int selectedIndex;
  final ValueChanged<int> onWeekSelected;

  const WeekSelector({
    Key? key,
    required this.weeks,
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
      height: 70, // Tăng chiều cao tổng thể
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
                color: isSelected ? Colors.green.shade600 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                widget.weeks[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
