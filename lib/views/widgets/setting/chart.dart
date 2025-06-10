import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsChart extends StatelessWidget {
  final int completedEvents;
  final int upcomingEvents;
  final int totalEvents;
  final int completedHabits;
  final int totalHabits;
  final int completedTodos;
  final int totalTodos;

  const StatisticsChart({
    super.key,
    required this.completedEvents,
    required this.upcomingEvents,
    required this.totalEvents,
    required this.completedHabits,
    required this.totalHabits,
    required this.completedTodos,
    required this.totalTodos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPieSection(
            title: 'Biểu đồ Sự kiện (Event)',
            completed: completedEvents,
            upcoming: upcomingEvents,
            total: totalEvents,
            completedLabel: 'Hoàn thành',
            upcomingLabel: 'Sắp tới',
          ),
          const SizedBox(height: 24),
          _buildPieSection(
            title: 'Biểu đồ Todo',
            completed: completedTodos,
            upcoming: 0,
            total: totalTodos,
            completedLabel: 'Đã xong',
            upcomingLabel: 'Chưa xong',
          ),
          const SizedBox(height: 24),
          _buildPieSection(
            title: 'Biểu đồ Thử thách/Habit',
            completed: completedHabits,
            upcoming: 0,
            total: totalHabits,
            completedLabel: 'Đã hoàn thành',
            upcomingLabel: 'Chưa hoàn thành',
          ),
        ],
      ),
    );
  }

  Widget _buildPieSection({
    required String title,
    required int completed,
    required int upcoming,
    required int total,
    required String completedLabel,
    required String upcomingLabel,
  }) {
    final int notCompleted = total - completed - upcoming;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: completed > 0 ? completed.toDouble() : 0,
                      color: Colors.green,
                      title: completedLabel,
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    if (upcoming > 0)
                      PieChartSectionData(
                        value: upcoming.toDouble(),
                        color: Colors.blue,
                        title: upcomingLabel,
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    if (upcoming == 0 && notCompleted > 0)
                      PieChartSectionData(
                        value: notCompleted.toDouble(),
                        color: Colors.red,
                        title: upcomingLabel,
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              children: [
                _buildLegend(completedLabel, Colors.green),
                if (upcoming > 0) _buildLegend(upcomingLabel, Colors.blue),
                if (upcoming == 0 && notCompleted > 0) _buildLegend(upcomingLabel, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
