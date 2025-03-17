import 'package:flutter/material.dart';


class ListCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  ListCalendar({required this.onDateSelected, required this.selectedDate});

  @override
  _ListCalendarState createState() => _ListCalendarState();
}

class _ListCalendarState extends State<ListCalendar> {
  DateTime? selectedDay;
  late DateTime firstDayOfMonth;
  late DateTime lastDayOfMonth;
  late DateTime firstDayInView;
  late DateTime lastDayInView;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.selectedDate;
    _initializeDates(currentMonth);
  }

  @override
  void didUpdateWidget(covariant ListCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate.month != oldWidget.selectedDate.month ||
        widget.selectedDate.year != oldWidget.selectedDate.year) {
      setState(() {
        currentMonth = widget.selectedDate;
        _initializeDates(currentMonth);
      });
    }
  }

  void _initializeDates(DateTime date) {
    firstDayOfMonth = DateTime(date.year, date.month, 1);
    lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    firstDayInView = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7 + 5),
    );
    lastDayInView = lastDayOfMonth.add(
      Duration(days: 6 - lastDayOfMonth.weekday % 7),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    int totalDays = lastDayInView.difference(firstDayInView).inDays + 1;
    int totalCells = 7 + totalDays; 

    return Column(
      children: [
        SizedBox(height: 40),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            physics: ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 cột (T2 -> CN)
              childAspectRatio: 1, // Tỉ lệ vuông
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < 7) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    weekdays[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                );
              }

              // Ô hiển thị ngày trong tháng
              DateTime day = firstDayInView.add(Duration(days: index - 7));
              bool isSelected =
                  selectedDay != null && _isSameDay(day, selectedDay!);
              bool isCurrentMonth = (day.month == currentMonth.month);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                  });
                  widget.onDateSelected(day);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green[100] : Colors.transparent,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          color:
                              _isSameDay(day, DateTime.now())
                                  ? Colors.green
                                  : isCurrentMonth
                                  ? Colors.black
                                  : Colors.grey,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (day.day == 14 && day.month == DateTime.now().month)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Sinh nhật',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
