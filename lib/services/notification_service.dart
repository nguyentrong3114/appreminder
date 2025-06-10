import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Cấu hình Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Kiểm tra quyền notification
    final notificationStatus = await Permission.notification.status;
    print('📱 Trạng thái quyền thông báo: $notificationStatus');

    if (notificationStatus.isDenied) {
      final result = await Permission.notification.request();
      print('📱 Kết quả xin quyền: $result');
    }

    // ✅ THÊM: Kiểm tra Android version và quyền exactAlarm
    if (Platform.isAndroid) {
      try {
        final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
        print('⏰ Trạng thái exact alarm: $exactAlarmStatus');

        if (exactAlarmStatus.isDenied) {
          final result = await Permission.scheduleExactAlarm.request();
          print('⏰ Kết quả xin exact alarm: $result');
        }
      } catch (e) {
        print('⚠️ Không thể kiểm tra exact alarm permission: $e');
      }
    }
  }

  Future<void> debugNotificationStatus() async {
    // Kiểm tra thông báo đang chờ
    final pending = await getPendingNotifications();
    print('📋 Số thông báo đang chờ: ${pending.length}');

    for (var notification in pending) {
      print('🔔 ID: ${notification.id}, Title: ${notification.title}');
    }

    // Kiểm tra quyền
    final notificationPermission = await Permission.notification.status;
    final exactAlarmPermission = await Permission.scheduleExactAlarm.status;

    print('📱 Quyền thông báo: $notificationPermission');
    print('⏰ Quyền exact alarm: $exactAlarmPermission');
  }

  // ✅ THÊM METHOD NÀY VÀO
  // ✅ THÊM PARAMETERS VÀO METHOD NÀY
  Future<void> scheduleOnetimeTaskNotification({
    required int id,
    required String title,
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
    String? soundName, // ✨ THÊM PARAMETER NÀY
    String? alarmSound, // ✨ THÊM PARAMETER NÀY
  }) async {
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Kiểm tra thời gian không được trong quá khứ
    if (scheduledDateTime.isBefore(DateTime.now())) {
      print(
        'Không thể lên lịch thông báo trong quá khứ: ${scheduledDateTime.toString()}',
      );
      return;
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    // SỬ DỤNG ÂM THANH CUSTOM
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'onetime_task_channel',
          'Onetime Task Reminders',
          channelDescription: 'Notifications for onetime task reminders',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
          // ÁP DỤNG ÂM THANH TỪ SETTINGS
          sound:
              soundName != null
                  ? RawResourceAndroidNotificationSound(soundName)
                  : null,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // ✨ iOS SOUND (nếu cần)
      // sound: soundName,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        '⏰ Nhắc nhở nhiệm vụ',
        title,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Đã lên lịch thông báo: $title với âm thanh: $soundName');
      print('📅 Thời gian: ${tzDateTime.toString()}');
      print('🆔 ID: $id');
    } catch (e) {
      print('❌ Lỗi khi lên lịch thông báo: $e');
    }
  }

  Future<void> testNotificationNow() async {
    print('🔴 BẮT ĐẦU test notification...');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          showWhen: true,
          when: null,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      print('🔴 Đang gửi test notification...');

      await _notificationsPlugin.show(
        999,
        '🔔 Test Notification',
        'Nếu bạn thấy thông báo này, notification đang hoạt động! Thời gian: ${DateTime.now().toString()}',
        notificationDetails,
      );

      print('✅ Test notification ĐÃ GỬI thành công!');

      // Kiểm tra ngay sau khi gửi
      final pending = await getPendingNotifications();
      print('📋 Số thông báo pending sau khi gửi: ${pending.length}');
    } catch (e) {
      print('❌ LỖI khi gửi test notification: $e');
    }
  }
  // ✅ THÊM CÁC METHOD NÀY VÀO NotificationService CLASS

  Future<void> cancelHabitNotifications(
    String habitId,
    int estimatedCount,
  ) async {
    // Cancel notifications for this habit
    for (int i = 0; i < estimatedCount; i++) {
      final id = (habitId + i.toString()).hashCode.abs();
      await cancelNotification(id);
    }
    print('✅ Đã hủy notifications cho habit: $habitId');
  }

  Future<void> scheduleRegularHabitDaily({
    required String habitId,
    required String title,
    required List<TimeOfDay> reminderTimes,
    required DateTime startDate,
  }) async {
    for (int i = 0; i < reminderTimes.length; i++) {
      final time = reminderTimes[i];
      final now = DateTime.now();
      DateTime scheduledDate = startDate.isAfter(now) ? startDate : now;

      final scheduledDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        time.hour,
        time.minute,
      );

      DateTime finalScheduledTime = scheduledDateTime;
      if (scheduledDateTime.isBefore(now)) {
        finalScheduledTime = scheduledDateTime.add(Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'regular_habit_channel',
            'Regular Habit Reminders',
            channelDescription: 'Daily habit reminder notifications',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          (habitId + i.toString()).hashCode.abs(),
          '🔄 Nhắc nhở thói quen',
          title,
          tz.TZDateTime.from(finalScheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        print(
          '✅ Đã lên lịch daily reminder: $title lúc ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        );
      } catch (e) {
        print('❌ Lỗi lên lịch daily reminder: $e');
      }
    }
  }

  Future<void> scheduleRegularHabitWeekly({
    required String habitId,
    required String title,
    required List<TimeOfDay> reminderTimes,
    required List<int> selectedWeekdays,
    required DateTime startDate,
  }) async {
    for (int i = 0; i < reminderTimes.length; i++) {
      final time = reminderTimes[i];

      for (int j = 0; j < selectedWeekdays.length; j++) {
        final weekday = selectedWeekdays[j];
        final id = (habitId + i.toString() + j.toString()).hashCode.abs();

        DateTime nextWeekday = _getNextWeekday(startDate, weekday);
        final now = DateTime.now();

        final scheduledDateTime = DateTime(
          nextWeekday.year,
          nextWeekday.month,
          nextWeekday.day,
          time.hour,
          time.minute,
        );

        if (scheduledDateTime.isBefore(now)) {
          nextWeekday = nextWeekday.add(Duration(days: 7));
        }

        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
              'regular_habit_channel',
              'Regular Habit Reminders',
              channelDescription: 'Weekly habit reminder notifications',
              importance: Importance.max,
              priority: Priority.max,
              enableVibration: true,
              playSound: true,
            );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            '🔄 Nhắc nhở thói quen',
            title,
            tz.TZDateTime.from(
              DateTime(
                nextWeekday.year,
                nextWeekday.month,
                nextWeekday.day,
                time.hour,
                time.minute,
              ),
              tz.local,
            ),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );

          print('✅ Đã lên lịch weekly reminder: $title');
        } catch (e) {
          print('❌ Lỗi lên lịch weekly reminder: $e');
        }
      }
    }
  }

  Future<void> scheduleRegularHabitMonthly({
    required String habitId,
    required String title,
    required List<TimeOfDay> reminderTimes,
    required List<int> selectedMonthlyDays,
    required DateTime startDate,
  }) async {
    for (int i = 0; i < reminderTimes.length; i++) {
      final time = reminderTimes[i];

      for (int j = 0; j < selectedMonthlyDays.length; j++) {
        final day = selectedMonthlyDays[j];
        final id =
            (habitId + 'monthly' + i.toString() + day.toString()).hashCode
                .abs();

        final now = DateTime.now();
        DateTime scheduledDate = DateTime(
          now.year,
          now.month,
          day > 28 ? 28 : day,
          time.hour,
          time.minute,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = DateTime(
            now.year,
            now.month + 1,
            day > 28 ? 28 : day,
            time.hour,
            time.minute,
          );
        }

        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
              'regular_habit_channel',
              'Regular Habit Reminders',
              channelDescription: 'Monthly habit reminder notifications',
              importance: Importance.max,
              priority: Priority.max,
              enableVibration: true,
              playSound: true,
            );

        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            '🔄 Nhắc nhở thói quen',
            title,
            tz.TZDateTime.from(scheduledDate, tz.local),
            NotificationDetails(android: androidDetails),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          );

          print('✅ Đã lên lịch monthly reminder: $title ngày $day');
        } catch (e) {
          print('❌ Lỗi lên lịch monthly reminder: $e');
        }
      }
    }
  }

  Future<void> scheduleRegularHabitYearly({
    required String habitId,
    required String title,
    required List<TimeOfDay> reminderTimes,
    required DateTime startDate,
  }) async {
    for (int i = 0; i < reminderTimes.length; i++) {
      final time = reminderTimes[i];
      final id = (habitId + 'yearly' + i.toString()).hashCode.abs();

      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        startDate.month,
        startDate.day > 28 ? 28 : startDate.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = DateTime(
          now.year + 1,
          startDate.month,
          startDate.day > 28 ? 28 : startDate.day,
          time.hour,
          time.minute,
        );
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'regular_habit_channel',
            'Regular Habit Reminders',
            channelDescription: 'Yearly habit reminder notifications',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
          );

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          '🔄 Nhắc nhở thói quen',
          title,
          tz.TZDateTime.from(scheduledDate, tz.local),
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );

        print('✅ Đã lên lịch yearly reminder: $title');
      } catch (e) {
        print('❌ Lỗi lên lịch yearly reminder: $e');
      }
    }
  }

  // Helper method
  DateTime _getNextWeekday(DateTime startDate, int targetWeekday) {
    final currentWeekday = startDate.weekday;
    int daysToAdd = (targetWeekday - currentWeekday + 7) % 7;
    if (daysToAdd == 0) daysToAdd = 7;
    return startDate.add(Duration(days: daysToAdd));
  }

  // Test với ID và channel khác
  Future<void> alternativeTest() async {
    print('🟡 Testing với method khác...');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'alternative_test',
          'Alternative Test',
          channelDescription: 'Alternative test channel',
          importance: Importance.max,
          priority: Priority.high,
          autoCancel: false,
          ongoing: false,
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(
        888,
        '🟡 Alternative Test',
        'Test với method khác - ${DateTime.now().millisecondsSinceEpoch}',
        notificationDetails,
      );
      print('✅ Alternative test sent!');
    } catch (e) {
      print('❌ Alternative test failed: $e');
    }
  }

  // Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Thêm vào NotificationService class
  Future<void> testScheduledNotification() async {
    final now = DateTime.now();
    final scheduledTime = now.add(Duration(seconds: 10));

    print('📅 Thời gian hiện tại: ${now.toString()}');
    print('📅 Thời gian lên lịch: ${scheduledTime.toString()}');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_scheduled',
          'Test Scheduled',
          channelDescription: 'Test scheduled notifications',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      // ✅ Sử dụng _notificationsPlugin TRONG class NotificationService
      await _notificationsPlugin.zonedSchedule(
        12345,
        '⏰ Test Scheduled',
        'Thông báo test sau 10 giây - ${now.toString().substring(11, 19)}',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print('✅ Test scheduled notification thành công!');
    } catch (e) {
      print('❌ Lỗi test scheduled: $e');
    }
  }

  // Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Lấy danh sách thông báo đã lên lịch
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
