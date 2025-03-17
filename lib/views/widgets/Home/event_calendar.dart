import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventCalendar extends StatelessWidget {
  final DateTime date;
  final List<Map<String, String>> events;

  const EventCalendar({
    required this.date,
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String weekDay = DateFormat('EEEE', 'vi').format(date);
    String day = DateFormat('dd', 'vi').format(date);

    return Container(
      width: 100,
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: events.isNotEmpty ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            weekDay,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          if (events.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: events.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        children: [
                          Text(
                            event['title'] ?? 'Sự kiện',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            event['time'] ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
