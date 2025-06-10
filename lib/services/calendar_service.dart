import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar.dart' as calendar_model;
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy user hiện tại
  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get eventCollection =>
      _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('events');

  // Thêm sự kiện mới
  Future<void> addEvent(calendar_model.CalendarEvent event) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception("Người dùng chưa đăng nhập");

    // Nếu event.id là userId hoặc rỗng thì tạo id mới
    String eventId =
        event.id == userId || event.id.isEmpty
            ? eventCollection.doc().id
            : event.id;

    await eventCollection.doc(eventId).set({
      'id': eventId,
      'userId': userId,
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
  Future<void> updateEvent(
    String id,
    calendar_model.CalendarEvent updatedEvent,
  ) async {
    await eventCollection.doc(id).update({
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
    await eventCollection.doc(id).delete();
  }

  // Lấy tất cả sự kiện (cho admin hoặc test)
  Future<List<calendar_model.CalendarEvent>> fetchAllEvents() async {
    final snapshot = await eventCollection.get();
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
    // KHÔNG cần where('userId', isEqualTo: userId) nữa!
    final snapshot = await eventCollection
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
  Future<Map<String, List<calendar_model.CalendarEvent>>>
      getEventsByDayMap() async {
    final allEvents = await fetchUserEvents();
    return calendar_model.getEventsByDay(allEvents);
  }
}
