import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Lấy user hiện tại
  String? get _currentUserId => _auth.currentUser?.uid;

  // ✅ Collection riêng cho từng user
  CollectionReference get _habitsCollection {
    if (_currentUserId == null) {
      throw Exception('User chưa đăng nhập');
    }
    print('🔐 Current user: $_currentUserId');
    print('📍 Collection path: users/$_currentUserId/habits');
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('habits');
  }

  // ✅ Lưu habit với user ID
  Future<String> saveHabit(Habit habit) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Vui lòng đăng nhập để lưu thử thách');
      }

      print('💾 Saving habit for user: $_currentUserId');

      // Thêm userId vào habit data
      final habitData = habit.toMap();
      habitData['userId'] = _currentUserId;

      final docRef = await _habitsCollection.add(habitData);
      print('✅ Habit saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Save error: $e');
      throw Exception('Không thể lưu thử thách: $e');
    }
  }

  // ✅ Lấy habits theo loại - BỎ where userId
  Stream<List<Habit>> getHabitsByType(HabitType type) {
    if (_currentUserId == null) {
      print('❌ No user authenticated');
      return Stream.value([]);
    }

    print('📊 Getting habits by type: $type for user: $_currentUserId');

    return _habitsCollection
        .where('type', isEqualTo: type.toString())
        // ❌ BỎ dòng này: .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📈 Found ${snapshot.docs.length} habits of type $type');
          return snapshot.docs.map((doc) {
            return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ Lấy tất cả habits - BỎ where userId
  Stream<List<Habit>> getAllHabits() {
    if (_currentUserId == null) {
      print('❌ No user authenticated');
      return Stream.value([]);
    }

    print('📊 Getting all habits for user: $_currentUserId');

    return _habitsCollection
        // ❌ BỎ dòng này: .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📈 Found ${snapshot.docs.length} total habits');
          return snapshot.docs.map((doc) {
            return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        })
        .handleError((error) {
          print('❌ Stream error: $error');
        });
  }

  // ✅ Rest methods không đổi...
  Future<Habit?> getHabitById(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('🔍 Getting habit: $habitId');
      final doc = await _habitsCollection.doc(habitId).get();

      if (doc.exists) {
        print('✅ Habit found');
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }

      print('❌ Habit not found');
      return null;
    } catch (e) {
      print('❌ Get habit error: $e');
      throw Exception('Không thể lấy thông tin thử thách: $e');
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> updates) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      await _habitsCollection.doc(habitId).update(updates);
    } catch (e) {
      throw Exception('Không thể cập nhật thử thách: $e');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      await _habitsCollection.doc(habitId).delete();
    } catch (e) {
      throw Exception('Không thể xóa thử thách: $e');
    }
  }
}
