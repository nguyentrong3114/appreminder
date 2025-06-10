import 'package:flutter/material.dart';
import 'package:flutter_app/models/todo.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:flutter_app/views/widgets/manage/add_todo_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodoDetailScreen extends StatelessWidget {
  final Todo todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    Color taskColor = _getColorFromName(todo.colorValue);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: taskColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Chi tiết công việc',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [taskColor, taskColor.withOpacity(0.8)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (todo.details != null && todo.details!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          todo.details!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Time card
                  _buildInfoCard(
                    icon: Icons.schedule_outlined,
                    title: 'Thời gian',
                    children: [
                      _buildTimeRow(
                        'Bắt đầu',
                        _formatDateTime(context, todo.startDateTime),
                        Icons.play_arrow_outlined,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildTimeRow(
                        'Kết thúc',
                        _formatDateTime(context, todo.endDateTime),
                        Icons.stop_outlined,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Settings card
                  _buildInfoCard(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    children: [
                      _buildSettingRow(
                        'Màu sắc',
                        todo.colorValue,
                        widget: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: taskColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingRow(
                        'Nhắc nhở',
                        todo.reminderEnabled ? 'Đã bật' : 'Đã tắt',
                        icon:
                            todo.reminderEnabled
                                ? Icons.notifications_active_outlined
                                : Icons.notifications_off_outlined,
                        iconColor:
                            todo.reminderEnabled ? Colors.orange : Colors.grey,
                      ),
                      if (todo.reminderEnabled &&
                          todo.reminderTime != null) ...[
                        const SizedBox(height: 12),
                        _buildSettingRow(
                          'Thời gian nhắc',
                          todo.reminderTime!,
                          icon: Icons.access_time_outlined,
                          iconColor: Colors.blue,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => AddTodoScreen(existingTodo: todo),
                              ),
                            );
                            if (result == 'edited' && context.mounted) {
                              Navigator.pop(context, 'edited');
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Chỉnh sửa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: taskColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(context, todo.id),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Xóa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.grey[700]),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingRow(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    Widget? widget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            if (widget != null) widget,
            if (icon != null && widget == null) ...[
              Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
              const SizedBox(width: 8),
            ],
            if (value.isNotEmpty && widget == null)
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    Map<String, Color> colorMap = {
      'Xanh lá cây': Colors.green,
      'Xanh da trời': Colors.blue,
      'Tím': Colors.purple,
      'Hồng': Colors.pink,
      'Vàng': Colors.amber,
      'Cam': Colors.orange,
      'Xanh ngọc': Colors.teal,
      'Xanh dương đậm': Colors.indigo,
    };
    return colorMap[colorName] ?? Colors.blue;
  }

  String _formatDateTime(BuildContext context, DateTime dt) {
    final dateFormat = context.watch<SettingProvider>().dateFormat;
    final is24Hour = context.watch<SettingProvider>().use24HourFormat;

    final formattedDate = DateFormat(dateFormat).format(dt);
    final formattedTime =
        is24Hour
            ? DateFormat('HH:mm').format(dt)
            : DateFormat('hh:mm a').format(dt);

    return '$formattedDate $formattedTime';
  }

  Future<void> _showDeleteDialog(BuildContext context, String todoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_outlined,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xác nhận xóa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn xóa công việc này không? Hành động này không thể hoàn tác.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xóa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final notificationId = todo.id.hashCode;
      await NotificationService().cancelNotification(notificationId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('todos')
          .doc(todoId)
          .delete();
      if (context.mounted) Navigator.pop(context, 'deleted');
    }
  }
}
