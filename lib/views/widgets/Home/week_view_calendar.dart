import 'package:flutter/material.dart';
import 'package:flutter_app/theme/app_colors.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy week data
    final List<Map<String, dynamic>> days = [
      {'label': 'T2', 'events': ['7:00 - 9:00 Họp nhóm', '9:00 - 10:00 Viết báo cáo']},
      {'label': 'T3', 'events': ['Cả ngày: Nghỉ phép']},
      {'label': 'T4', 'events': ['8:00 - 9:00 Học tiếng Anh']},
      {'label': 'T5', 'events': ['8:00 - 9:00 Tập gym', '20:00 - 21:00 Xem phim']},
      {'label': 'T6', 'events': []},
      {'label': 'T7', 'events': ['9:00 - 11:00 Đi siêu thị']},
      {'label': 'CN', 'events': ['Cả ngày: Sinh nhật mẹ']},
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final day = days[index];
        final List<String> events = List<String>.from(day['events'] ?? []);
        final bool hasEvents = events.isNotEmpty;

        return Card(
          color: hasEvents ? AppColors.primary.withOpacity(0.07) : Colors.white,
          elevation: hasEvents ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: hasEvents ? AppColors.primary : Colors.grey.shade300,
                  child: Text(
                    day['label'] ?? '',
                    style: TextStyle(
                      color: hasEvents ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: hasEvents
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: events
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.text,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                        )
                      : const Text(
                          'Không có sự kiện',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
