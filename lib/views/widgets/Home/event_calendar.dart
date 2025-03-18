import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class EventCalendar extends StatelessWidget {
  final DateTime date; // Ngày được truyền vào từ bên ngoài
  final List<Map<String, String>> events;

  const EventCalendar({
    required this.date,
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String weekDay = DateFormat('EEEE', 'vi').format(date);
    String day = DateFormat('dd/MM/yyyy', 'vi').format(date);

    events.sort((a, b) => (a['time'] ?? '').compareTo(b['time'] ?? ''));

    return Container(
      width: 220,
      height: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: events.isNotEmpty ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$weekDay, $day",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          if (events.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.event, color: Colors.blue.shade400, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Sự kiện',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                event['time'] ?? '',
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            const Center(
              child: Text(
                "Không có sự kiện nào",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
