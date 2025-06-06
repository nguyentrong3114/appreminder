import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventCalendar extends StatelessWidget {
  final DateTime date;
  final List<Map<String, String>> events;

  const EventCalendar({
    required this.date,
    required this.events,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String weekDay = DateFormat('EEEE', 'vi').format(date);
    String day = DateFormat('dd/MM/yyyy', 'vi').format(date);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$weekDay, $day', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...events.map((event) => ListTile(
                  title: Text(event['title'] ?? ''),
                  subtitle: Text(event['description'] ?? ''),
                  trailing: Text(event['time'] ?? ''),
                )),
          ],
        ),
      ),
    );
  }
}
