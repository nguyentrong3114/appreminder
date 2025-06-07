import 'package:firebase_auth/firebase_auth.dart';
import '../models/Calendar.dart' as calendar_model;
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final _eventCollection = FirebaseFirestore.instance.collection('events');

  // Thêm sự kiện mới
  Future<void> addEvent(calendar_model.CalendarEvent event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Người dùng chưa đăng nhập");

    // Nếu event.id là userId thì tạo id mới
    String eventId = event.id == user.uid || event.id.isEmpty
      ? _eventCollection.doc().id
      : event.id;

    await _eventCollection.doc(eventId).set({
      'id': eventId,
      'userId': user.uid,
      'title': event.title,
      'detail': event.detail,
      'location': event.location,
      'description': event.description,
      'startTime': Timestamp.fromDate(event.startTime),
      'endTime': Timestamp.fromDate(event.endTime),
      'allDay': event.allDay,
      'reminder': event.reminder,
      'alarmReminder': event.alarmReminder,
    });
  }

  // Cập nhật sự kiện theo id
  Future<void> updateEvent(String id, calendar_model.CalendarEvent updatedEvent) async {
    await _eventCollection.doc(id).update({
      'title': updatedEvent.title,
      'detail': updatedEvent.detail,
      'location': updatedEvent.location,
      'description': updatedEvent.description,
      'startTime': Timestamp.fromDate(updatedEvent.startTime),
      'endTime': Timestamp.fromDate(updatedEvent.endTime),
      'allDay': updatedEvent.allDay,
      'reminder': updatedEvent.reminder,
      'alarmReminder': updatedEvent.alarmReminder,
    });
  }

  // Xoá sự kiện theo id
  Future<void> deleteEvent(String id) async {
    await _eventCollection.doc(id).delete();
  }

  // Lấy tất cả sự kiện (cho admin hoặc test)
  Future<List<calendar_model.CalendarEvent>> fetchAllEvents() async {
    final snapshot = await _eventCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return calendar_model.CalendarEvent(
        id: data['id'],
        userId: data['userId'],
        title: data['title'],
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
  }

  // Lấy sự kiện chỉ của user hiện tại
  Future<List<calendar_model.CalendarEvent>> fetchUserEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await _eventCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('startTime')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return calendar_model.CalendarEvent(
        id: data['id'],
        userId: data['userId'],
        title: data['title'],
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
  }

  // Lấy danh sách các ngày có sự kiện
  Future<List<DateTime>> getEventDays() async {
    final allEvents = await fetchUserEvents();
    final eventsByDay = calendar_model.getEventsByDay(allEvents);
    return eventsByDay.keys.map((key) {
      final parts = key.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();
  }

  // Trả về Map<"yyyy-MM-dd", List<CalendarEvent>>
  Future<Map<String, List<calendar_model.CalendarEvent>>> getEventsByDayMap() async {
    final allEvents = await fetchUserEvents();
    return calendar_model.getEventsByDay(allEvents);
  }
}
