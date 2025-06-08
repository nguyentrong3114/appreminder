import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../services/notification_service.dart';

class NotificationTestPage extends StatefulWidget {
  @override
  _NotificationTestPageState createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final NotificationService _notificationService = NotificationService();
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _addLog('📱 Trang test notification đã khởi tạo');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔔 Test Notification'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearLogs,
            icon: Icon(Icons.clear_all),
            tooltip: 'Xóa logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Buttons section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTestButton(
                  '🔔 Test Ngay Lập Tức',
                  Colors.green,
                  _testInstantNotification,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  '⏰ Test Sau 10 Giây',
                  Colors.orange,
                  _testScheduledNotification,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  '📋 Kiểm Tra Quyền',
                  Colors.blue,
                  _checkPermissions,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  '📋 Xem Thông Báo Đang Chờ',
                  Colors.purple,
                  _checkPendingNotifications,
                ),
                SizedBox(height: 12),
                _buildTestButton(
                  '🗑️ Xóa Tất Cả Thông Báo',
                  Colors.red,
                  _cancelAllNotifications,
                ),
              ],
            ),
          ),

          // Divider
          Divider(thickness: 2),

          // Logs section
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📝 Logs:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              _logs[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Test methods
  Future<void> _testInstantNotification() async {
    _addLog('🔔 Bắt đầu test thông báo ngay lập tức...');

    try {
      await _notificationService.testNotificationNow();
      _addLog('✅ Đã gửi thông báo test');

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gửi test notification!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _addLog('❌ Lỗi: $e');
    }
  }

  Future<void> _testScheduledNotification() async {
    _addLog('⏰ Bắt đầu test thông báo sau 10 giây...');

    try {
      // ✅ Gọi method public của NotificationService
      await _notificationService.testScheduledNotification();
      _addLog('✅ Đã lên lịch test notification');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thông báo sẽ hiện sau 10 giây!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _addLog('❌ Lỗi: $e');
    }
  }

  Future<void> _checkPermissions() async {
    _addLog('📋 Kiểm tra quyền...');

    try {
      await _notificationService.debugNotificationStatus();
      _addLog('✅ Đã kiểm tra quyền (xem console)');
    } catch (e) {
      _addLog('❌ Lỗi: $e');
    }
  }

  Future<void> _checkPendingNotifications() async {
    _addLog('📋 Kiểm tra thông báo đang chờ...');

    try {
      final pending = await _notificationService.getPendingNotifications();
      _addLog('📊 Số thông báo đang chờ: ${pending.length}');

      for (var notification in pending) {
        _addLog('   - ID: ${notification.id}, Title: ${notification.title}');
      }

      if (pending.isEmpty) {
        _addLog('   - Không có thông báo nào đang chờ');
      }
    } catch (e) {
      _addLog('❌ Lỗi: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    _addLog('🗑️ Xóa tất cả thông báo...');

    try {
      await _notificationService.cancelAllNotifications();
      _addLog('✅ Đã xóa tất cả thông báo');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa tất cả thông báo!'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      _addLog('❌ Lỗi: $e');
    }
  }
}
