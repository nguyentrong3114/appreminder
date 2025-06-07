import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/utils/time.dart';
import 'package:flutter_app/theme/app_colors.dart';
import 'package:flutter_app/provider/setting_provider.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    final use24Hour = context.watch<TimeFormatProvider>().use24HourFormat;

    // Dummy week data (dùng Map để có thể chứa DateTime)
    final List<Map<String, dynamic>> days = [
      {
        'label': 'T2',
        'events': [
          {
            'start': DateTime(2025, 6, 2, 7, 0),
            'end': DateTime(2025, 6, 2, 9, 0),
            'title': 'Họp nhóm'
          },
          {
            'start': DateTime(2025, 6, 2, 9, 0),
            'end': DateTime(2025, 6, 2, 10, 0),
            'title': 'Viết báo cáo'
          },
        ]
      },
      {
        'label': 'T3',
        'events': [
          {
            'allDay': true,
            'title': 'Nghỉ phép'
          }
        ]
      },
      {
        'label': 'T4',
        'events': [
          {
            'start': DateTime(2025, 6, 4, 8, 0),
            'end': DateTime(2025, 6, 4, 9, 0),
            'title': 'Học tiếng Anh'
          }
        ]
      },
      {
        'label': 'T5',
        'events': [
          {
            'start': DateTime(2025, 6, 5, 8, 0),
            'end': DateTime(2025, 6, 5, 9, 0),
            'title': 'Tập gym'
          },
          {
            'start': DateTime(2025, 6, 5, 20, 0),
            'end': DateTime(2025, 6, 5, 21, 0),
            'title': 'Xem phim'
          },
        ]
      },
      {
        'label': 'T6',
        'events': []
      },
      {
        'label': 'T7',
        'events': [
          {
            'start': DateTime(2025, 6, 7, 9, 0),
            'end': DateTime(2025, 6, 7, 11, 0),
            'title': 'Đi siêu thị'
          }
        ]
      },
      {
        'label': 'CN',
        'events': [
          {
            'allDay': true,
            'title': 'Sinh nhật mẹ'
          }
        ]
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final day = days[index];
        final List events = day['events'] ?? [];
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
                              .map<Widget>((e) {
                                if (e['allDay'] == true) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Cả ngày: ${e['title']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.text,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${formatTime(e['start'], use24HourFormat: use24Hour)} - '
                                      '${formatTime(e['end'], use24HourFormat: use24Hour)} ${e['title']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.text,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                              })
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
