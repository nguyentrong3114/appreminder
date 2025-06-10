import 'chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticalPage extends StatelessWidget {
  final bool showChartOnly;
  const StatisticalPage({super.key, this.showChartOnly = false});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(showChartOnly ? 'Biểu đồ sự kiện' : 'Thống kê hoạt động'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không có dữ liệu thống kê.'));
          }
          final stats = snapshot.data!;
          // Trang thống kê KHÔNG có biểu đồ
          if (!showChartOnly) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Tổng số sự kiện đã hoàn thành: ${stats['completedEvents']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tổng số sự kiện sắp tới: ${stats['upcomingEvents']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tổng số sự kiện đã tạo: ${stats['totalEvents']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Danh sách sự kiện sắp tới:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<Widget>.from(stats['upcomingList'] ?? []),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Danh sách sự kiện đã hoàn thành:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<Widget>.from(stats['completedList'] ?? []),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Danh sách Todo:', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchTodos(userId),
                  builder: (context, todoSnapshot) {
                    if (todoSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!todoSnapshot.hasData || todoSnapshot.data!.isEmpty) {
                      return const Text('Không có Todo nào.');
                    }
                    return Column(
                      children: todoSnapshot.data!.map((todo) {
                        String start = '';
                        String end = '';
                        try {
                          final startDT = todo['startDateTime'] is Timestamp
                              ? (todo['startDateTime'] as Timestamp).toDate()
                              : DateTime.tryParse(todo['startDateTime'].toString());
                          final endDT = todo['endDateTime'] is Timestamp
                              ? (todo['endDateTime'] as Timestamp).toDate()
                              : DateTime.tryParse(todo['endDateTime'].toString());
                          if (startDT != null) {
                            start = '${startDT.day.toString().padLeft(2, '0')}/${startDT.month.toString().padLeft(2, '0')}/${startDT.year} ${startDT.hour.toString().padLeft(2, '0')}:${startDT.minute.toString().padLeft(2, '0')}';
                          }
                          if (endDT != null) {
                            end = '${endDT.day.toString().padLeft(2, '0')}/${endDT.month.toString().padLeft(2, '0')}/${endDT.year} ${endDT.hour.toString().padLeft(2, '0')}:${endDT.minute.toString().padLeft(2, '0')}';
                          }
                        } catch (_) {}
                        return ListTile(
                          title: Text(todo['title'] ?? ''),
                          subtitle: Text('Từ: $start - Đến: $end'),
                          trailing: todo['isDone'] == true ? Icon(Icons.check, color: Colors.green) : null,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text('Danh sách Thử thách:', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchHabits(userId),
                  builder: (context, habitSnapshot) {
                    if (habitSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!habitSnapshot.hasData || habitSnapshot.data!.isEmpty) {
                      return const Text('Không có thử thách nào.');
                    }
                    return Column(
                      children: habitSnapshot.data!.map((habit) {
                        String start = '';
                        try {
                          final startDT = habit['startDate'] is Timestamp
                              ? (habit['startDate'] as Timestamp).toDate()
                              : DateTime.tryParse(habit['startDate'].toString());
                          if (startDT != null) {
                            start = '${startDT.day.toString().padLeft(2, '0')}/${startDT.month.toString().padLeft(2, '0')}/${startDT.year}';
                          }
                        } catch (_) {}
                        return ListTile(
                          title: Text(habit['title'] ?? ''),
                          subtitle: Text('Bắt đầu: $start'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          } else {
            // Lấy thêm số liệu todo và habit để truyền vào StatisticsChart
            return FutureBuilder<List<List<Map<String, dynamic>>>>(
              future: Future.wait([
                _fetchTodos(userId),
                _fetchHabits(userId),
              ]),
              builder: (context, extraSnapshot) {
                if (extraSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = extraSnapshot.data?[0] ?? [];
                final habits = extraSnapshot.data?[1] ?? [];
                final completedTodos = todos.where((t) => t['isDone'] == true).length;
                final totalTodos = todos.length;
                final completedHabits = habits.where((h) => h['isActive'] != false && (h['completionCount'] ?? 0) > 0).length;
                final totalHabits = habits.where((h) => h['isActive'] != false).length;
                return StatisticsChart(
                  completedEvents: stats['completedEvents'],
                  upcomingEvents: stats['upcomingEvents'],
                  totalEvents: stats['totalEvents'],
                  completedHabits: completedHabits,
                  totalHabits: totalHabits,
                  completedTodos: completedTodos,
                  totalTodos: totalTodos,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchStatistics(String userId) async {
    final now = DateTime.now();
    // Lấy dữ liệu từ Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();
    final allEvents = snapshot.docs.map((doc) {
      final data = doc.data();
      return CalendarEvent(
        id: data['id'] ?? '',
        userId: data['userId'] ?? '',
        title: data['title'] ?? '',
        detail: data['detail'] ?? '',
        location: data['location'] ?? '',
        description: data['description'] ?? '',
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
        allDay: data['allDay'] ?? false,
        reminder: data['reminder'] ?? false,
        alarmReminder: data['alarmReminder'] ?? false,
      );
    }).toList();

    final completed = allEvents.whereType<CalendarEvent>().where((e) => e.endTime.isBefore(now)).toList();
    final upcoming = allEvents.whereType<CalendarEvent>().where((e) => e.startTime.isAfter(now)).toList();
    return {
      'completedEvents': completed.length,
      'upcomingEvents': upcoming.length,
      'totalEvents': allEvents.length,
      'upcomingList': upcoming.map((e) => ListTile(
        title: Text(e.title),
        subtitle: Text('Bắt đầu: ${e.startTime}'),
      )).toList(),
      'completedList': completed.map((e) => ListTile(
        title: Text(e.title),
        subtitle: Text('Kết thúc: ${e.endTime}'),
      )).toList(),
    };
  }

  // Thêm các hàm lấy todo và habit
  Future<List<Map<String, dynamic>>> _fetchTodos(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('todos')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchHabits(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('habits')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
