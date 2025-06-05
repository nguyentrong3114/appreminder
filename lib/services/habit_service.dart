import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _habitsCollection {
    return _firestore.collection('habits');
  }

  // Lưu habit (cả regular và onetime)
  Future<String> saveHabit(Habit habit) async {
    try {
      final docRef = await _habitsCollection.add(habit.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể lưu thử thách: $e');
    }
  }

  // Lấy habits theo loại
  Stream<List<Habit>> getHabitsByType(HabitType type) {
    return _habitsCollection
        .where('type', isEqualTo: type.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Lấy tất cả habits
  Stream<List<Habit>> getAllHabits() {
    return _habitsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // Lấy habit theo ID
  Future<Habit?> getHabitById(String habitId) async {
    try {
      final doc = await _habitsCollection.doc(habitId).get();
      if (doc.exists) {
        return Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin thử thách: $e');
    }
  }
}
