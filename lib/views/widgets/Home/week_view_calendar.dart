import 'package:flutter/material.dart';

class WeekView extends StatelessWidget {
  const WeekView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = [
      {'day': 'Th 2 23', 'events': ['Đêm Giáng...', 'Đêm Giáng...']},
      {'day': 'Th 3 24', 'events': ['Giáng sinh/...']},
      {'day': 'Th 4 25', 'events': ['']},
      {'day': 'Th 5 26', 'events': ['']},
      {'day': 'Th 6 27', 'events': ['']},
      {'day': 'Th 7 28', 'events': ['']},
      {'day': 'CN 29', 'events': ['']},
    ];

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final dayData = days[index];
        final dayName = dayData['day'] as String;
        final events = dayData['events'] as List<String>;
        // Lọc bỏ các event rỗng để hiển thị
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
                // Hiển thị danh sách sự kiện nếu có, ngược lại hiện "(Trống)"
                if (validEvents.isNotEmpty)
                  ...validEvents.map((event) => Padding(
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
                              child: Text(
                                event,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
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
