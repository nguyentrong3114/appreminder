import 'package:flutter/material.dart';

class WeekView extends StatelessWidget {
  const WeekView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = [
      {
        'day': 'Th 2 23',
        'events': ['Đêm Giáng...', 'Đêm Giáng...'],
        'time': ['7 p.m - 9 p.m', '9 p.m - 10 p.m'],
      },
      {
        'day': 'Th 3 24',
        'events': ['Giáng sinh...'],
        'time': ['All day'],
      },
      {
        'day': 'Th 4 25',
        'events': ['Tập Gym'],
        'time': ['8 p.m - 9 p.m'],
      },
      {
        'day': 'Th 5 26',
        'events': ['Tập Gym'],
        'time': ['8 p.m - 9 p.m'],
      },
      {
        'day': 'Th 6 27',
        'events': ['Tập Gym'],
        'time': ['8 p.m - 9 p.m'],
      },
      {
        'day': 'Th 7 28',
        'events': ['Tập Gym'],
        'time': ['8 p.m - 9 p.m'],
      },
      {
        'day': 'CN 29',
        'events': ['Tập Gym'],
        'time': ['8 p.m - 9 p.m'],
      },
    ];

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dayData = days[index];
        final dayName = dayData['day'] as String;
        final events = dayData['events'] as List<String>;

        final times =
            (dayData['time'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        final validEvents = events.where((e) => e.trim().isNotEmpty).toList();

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề ngày
                Text(
                  dayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),

                if (validEvents.isNotEmpty)
                  Column(
                    children: List.generate(validEvents.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.event,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    validEvents[i],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (i <
                                      times
                                          .length) // Kiểm tra nếu có thời gian tương ứng
                                    Text(
                                      times[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  )
                else
                  const Text(
                    '(Trống)',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
