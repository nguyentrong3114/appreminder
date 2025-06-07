import 'package:flutter/material.dart';

class QuickViewEventScreen extends StatelessWidget {
  final List<Map<String, String>> events;
  final DateTime date;
  final void Function(DateTime)? onAddEvent;

  const QuickViewEventScreen({
    super.key,
    required this.events,
    required this.date,
    this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sự kiện ngày ${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () {
                      // Không đóng BottomSheet nữa
                      onAddEvent?.call(date);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final e = events[idx];
                    return ListTile(
                      title: Text(e['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e['description'] ?? ''),
                      trailing: Text('${e['startTime'] ?? ''} - ${e['endTime'] ?? ''}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}