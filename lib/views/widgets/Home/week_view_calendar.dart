import 'package:flutter/material.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy week data
    final List<Map<String, dynamic>> days = [
      {'label': 'T2', 'events': ['7 p.m - 9 p.m', '9 p.m - 10 p.m']},
      {'label': 'T3', 'events': ['All day']},
      {'label': 'T4', 'events': ['8 p.m - 9 p.m']},
      {'label': 'T5', 'events': ['8 p.m - 9 p.m']},
    ];

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final List<String> events = List<String>.from(day['events'] ?? []);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(day['label'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: events
                  .map((e) => Text(e, style: const TextStyle(fontSize: 13)))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}
