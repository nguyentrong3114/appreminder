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

  // ✨ PHƯƠNG THỨC LƯU HABIT CẢI TIẾN
  Future<String> saveHabit(Habit habit) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Vui lòng đăng nhập để lưu thử thách');
      }

      print('💾 Saving habit for user: $_currentUserId');

      // Tạo habit data với cấu trúc mới
      final habitData = {
        'title': habit.title,
        'iconCodePoint': habit.iconCodePoint,
        'colorValue': habit.colorValue,
        'startDate': Timestamp.fromDate(habit.startDate),
        'endDate':
            habit.endDate != null ? Timestamp.fromDate(habit.endDate!) : null,
        'hasEndDate': habit.hasEndDate,
        'type': habit.type.toString(),
        'repeatType': habit.repeatType.toString(),
        'selectedWeekdays': habit.selectedWeekdays,
        'selectedMonthlyDays': habit.selectedMonthlyDays, // ✨ THÊM MỚI
        'reminderEnabled': habit.reminderEnabled,
        'reminderTimes': habit.reminderTimes,
        'streakEnabled': habit.streakEnabled,
        'tags': habit.tags,
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // ✨ THÊM METADATA MỚI
        'isActive': true,
        'completionCount': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletedDate': null,
      };

      print('📊 Habit data to save: ${habitData.keys.toList()}');

      final docRef = await _habitsCollection.add(habitData);
      print('✅ Habit saved with ID: ${docRef.id}');

      // ✨ THÊM LOG CHI TIẾT
      if (habit.repeatType == RepeatType.monthly &&
          habit.selectedMonthlyDays.isNotEmpty) {
        print('📅 Monthly habit with days: ${habit.selectedMonthlyDays}');
      }

      return docRef.id;
    } catch (e) {
      print('❌ Save error: $e');
      throw Exception('Không thể lưu thử thách: $e');
    }
  }

  // ✨ LẤY HABITS THEO LOẠI VỚI BỘ LỌC CẢI TIẾN
  Stream<List<Habit>> getHabitsByType(
    HabitType type, {
    bool activeOnly = true,
    String? searchQuery,
  }) {
    if (_currentUserId == null) {
      print('❌ No user authenticated');
      return Stream.value([]);
    }

    print('📊 Getting habits by type: $type for user: $_currentUserId');

    Query query = _habitsCollection.where('type', isEqualTo: type.toString());

    // ✨ BỘ LỌC ACTIVE
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📈 Found ${snapshot.docs.length} habits of type $type');

          var habits =
              snapshot.docs
                  .map((doc) {
                    try {
                      return _createHabitFromDoc(doc);
                    } catch (e) {
                      print('❌ Error parsing habit ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((habit) => habit != null)
                  .cast<Habit>()
                  .toList();

          // ✨ FILTER BY SEARCH QUERY
          if (searchQuery != null && searchQuery.isNotEmpty) {
            habits =
                habits
                    .where(
                      (habit) => habit.title.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
          }

          return habits;
        })
        .handleError((error) {
          print('❌ Stream error: $error');
        });
  }

  // ✨ LẤY TẤT CẢ HABITS VỚI BỘ LỌC
  Stream<List<Habit>> getAllHabits({
    bool activeOnly = true,
    String? searchQuery,
    RepeatType? filterByRepeatType,
  }) {
    if (_currentUserId == null) {
      print('❌ No user authenticated');
      return Stream.value([]);
    }

    print('📊 Getting all habits for user: $_currentUserId');

    Query query = _habitsCollection;

    // ✨ BỘ LỌC ACTIVE
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    // ✨ BỘ LỌC THEO REPEAT TYPE
    if (filterByRepeatType != null) {
      query = query.where(
        'repeatType',
        isEqualTo: filterByRepeatType.toString(),
      );
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📈 Found ${snapshot.docs.length} total habits');

          var habits =
              snapshot.docs
                  .map((doc) {
                    try {
                      return _createHabitFromDoc(doc);
                    } catch (e) {
                      print('❌ Error parsing habit ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((habit) => habit != null)
                  .cast<Habit>()
                  .toList();

          // ✨ FILTER BY SEARCH QUERY
          if (searchQuery != null && searchQuery.isNotEmpty) {
            habits =
                habits
                    .where(
                      (habit) => habit.title.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
          }

          return habits;
        })
        .handleError((error) {
          print('❌ Stream error: $error');
        });
  }

  // ✨ PHƯƠNG THỨC TẠO HABIT TỪ DOCUMENT
  Habit _createHabitFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // ✨ XỬ LÝ MIGRATION CHO selectedMonthlyDays
    List<int> selectedMonthlyDays = [];
    if (data.containsKey('selectedMonthlyDays')) {
      selectedMonthlyDays = List<int>.from(data['selectedMonthlyDays'] ?? []);
    } else if (data.containsKey('monthlyDay')) {
      // Migration từ format cũ
      selectedMonthlyDays = [data['monthlyDay'] as int];
      print(
        '🔄 Migrating monthlyDay ${data['monthlyDay']} to selectedMonthlyDays',
      );
    }

    return Habit(
      id: doc.id,
      title: data['title'] ?? '',
      iconCodePoint: data['iconCodePoint'] ?? '',
      colorValue: data['colorValue'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
      hasEndDate: data['hasEndDate'] ?? false,
      type: HabitType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => HabitType.regular,
      ),
      repeatType: RepeatType.values.firstWhere(
        (e) => e.toString() == data['repeatType'],
        orElse: () => RepeatType.daily,
      ),
      selectedWeekdays: List<int>.from(data['selectedWeekdays'] ?? []),
      selectedMonthlyDays: selectedMonthlyDays, // ✨ SỬ DỤNG selectedMonthlyDays
      reminderEnabled: data['reminderEnabled'] ?? false,
      reminderTimes: List<String>.from(data['reminderTimes'] ?? []),
      streakEnabled: data['streakEnabled'] ?? false,
      tags: List<Map<String, dynamic>>.from(data['tags'] ?? []),
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // ✨ LẤY HABITS THEO NGÀY CỤ THỂ
  Stream<List<Habit>> getHabitsForDate(DateTime date) {
    return getAllHabits().map((habits) {
      return habits
          .where((habit) => _shouldHabitRunOnDate(habit, date))
          .toList();
    });
  }

  // ✨ KIỂM TRA HABIT CÓ CHẠY VÀO NGÀY CỤ THỂ KHÔNG
  bool _shouldHabitRunOnDate(Habit habit, DateTime date) {
    // Kiểm tra ngày bắt đầu
    if (date.isBefore(habit.startDate)) return false;

    // Kiểm tra ngày kết thúc
    if (habit.hasEndDate &&
        habit.endDate != null &&
        date.isAfter(habit.endDate!)) {
      return false;
    }

    switch (habit.repeatType) {
      case RepeatType.daily:
        return true;

      case RepeatType.weekly:
        return habit.selectedWeekdays.contains(date.weekday);

      case RepeatType.monthly:
        // ✨ LOGIC MỚI CHO selectedMonthlyDays
        return habit.selectedMonthlyDays.contains(date.day);

      case RepeatType.yearly:
        return date.day == habit.startDate.day &&
            date.month == habit.startDate.month;
    }
  }

  // ✨ LẤY HABIT THEO ID VỚI ERROR HANDLING TỐT HỌN
  Future<Habit?> getHabitById(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('🔍 Getting habit: $habitId');
      final doc = await _habitsCollection.doc(habitId).get();

      if (doc.exists) {
        print('✅ Habit found');
        return _createHabitFromDoc(doc as QueryDocumentSnapshot);
      }

      print('❌ Habit not found');
      return null;
    } catch (e) {
      print('❌ Get habit error: $e');
      throw Exception('Không thể lấy thông tin thử thách: $e');
    }
  }

  //PHƯƠNG THỨC UPDATE HABIT
  Future<void> updateHabit(Habit habit) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Vui lòng đăng nhập để cập nhật thử thách');
      }

      print('🔄 Updating habit ${habit.id} for user: $_currentUserId');

      // Tạo habit data để update
      final habitData = {
        'title': habit.title,
        'iconCodePoint': habit.iconCodePoint,
        'colorValue': habit.colorValue,
        'startDate': Timestamp.fromDate(habit.startDate),
        'endDate':
            habit.endDate != null ? Timestamp.fromDate(habit.endDate!) : null,
        'hasEndDate': habit.hasEndDate,
        'type': habit.type.toString(),
        'repeatType': habit.repeatType.toString(),
        'selectedWeekdays': habit.selectedWeekdays,
        'selectedMonthlyDays': habit.selectedMonthlyDays,
        'reminderEnabled': habit.reminderEnabled,
        'reminderTimes': habit.reminderTimes,
        'streakEnabled': habit.streakEnabled,
        'tags': habit.tags,
        'userId': _currentUserId,
        'updatedAt': FieldValue.serverTimestamp(), // ✅ Chỉ update timestamp
        // Giữ nguyên các field khác như createdAt, completionCount, currentStreak, etc.
      };

      print('📊 Updating habit data: ${habitData.keys.toList()}');

      // ✅ SỬ DỤNG UPDATE THAY VÌ ADD
      await _habitsCollection.doc(habit.id).update(habitData);

      print('✅ Habit updated successfully: ${habit.id}');
    } catch (e) {
      print('❌ Update error: $e');
      throw Exception('Không thể cập nhật thử thách: $e');
    }
  }

  // ✨ XÓA HABIT (SOFT DELETE)
  Future<void> deleteHabit(String habitId, {bool hardDelete = false}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      if (hardDelete) {
        print('🗑️ Hard deleting habit: $habitId');
        await _habitsCollection.doc(habitId).delete();
      } else {
        print('🗑️ Soft deleting habit: $habitId');
        await _habitsCollection.doc(habitId).update({
          'isActive': false,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('✅ Habit deleted successfully');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception('Không thể xóa thử thách: $e');
    }
  }

  // ✨ KHÔI PHỤC HABIT
  Future<void> restoreHabit(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('🔄 Restoring habit: $habitId');
      await _habitsCollection.doc(habitId).update({
        'isActive': true,
        'deletedAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Habit restored successfully');
    } catch (e) {
      print('❌ Restore error: $e');
      throw Exception('Không thể khôi phục thử thách: $e');
    }
  }

  // ✨ ĐÁNH DẤU HABIT HOÀN THÀNH
  Future<void> markHabitCompleted(String habitId, DateTime date) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      final completionData = {
        'habitId': habitId,
        'userId': _currentUserId,
        'completedDate': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Lưu vào collection completions
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('completions')
          .add(completionData);

      // Cập nhật habit stats
      await _updateHabitStats(habitId, date);

      print('✅ Habit marked as completed for $date');
    } catch (e) {
      print('❌ Mark completed error: $e');
      throw Exception('Không thể đánh dấu hoàn thành: $e');
    }
  }

  // ✨ CẬP NHẬT THỐNG KÊ HABIT
  Future<void> _updateHabitStats(String habitId, DateTime completedDate) async {
    final doc = await _habitsCollection.doc(habitId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    int completionCount = (data['completionCount'] ?? 0) + 1;
    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;

    // Tính streak logic ở đây...
    currentStreak++;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    await _habitsCollection.doc(habitId).update({
      'completionCount': completionCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': Timestamp.fromDate(completedDate),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✨ LẤY THỐNG KÊ USER
  Future<Map<String, dynamic>> getUserStats() async {
    if (_currentUserId == null) {
      throw Exception('User chưa đăng nhập');
    }

    final habitsSnapshot =
        await _habitsCollection.where('isActive', isEqualTo: true).get();

    final completionsSnapshot =
        await _firestore
            .collection('users')
            .doc(_currentUserId)
            .collection('completions')
            .get();

    return {
      'totalHabits': habitsSnapshot.docs.length,
      'totalCompletions': completionsSnapshot.docs.length,
      'habitsToday': 0, // Implement logic
      'currentStreaks': 0, // Implement logic
    };
  }

  // ✨ MIGRATION - CẬP NHẬT TẤT CẢ HABITS CŨ
  Future<void> migrateOldHabits() async {
    try {
      if (_currentUserId == null) return;

      print('🔄 Starting migration for user: $_currentUserId');

      final snapshot =
          await _habitsCollection
              .where('selectedMonthlyDays', isNull: true)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('monthlyDay')) {
          final monthlyDay = data['monthlyDay'] as int;
          await doc.reference.update({
            'selectedMonthlyDays': [monthlyDay],
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print(
            '✅ Migrated habit ${doc.id}: monthlyDay $monthlyDay -> selectedMonthlyDays [$monthlyDay]',
          );
        }
      }

      print('🎉 Migration completed');
    } catch (e) {
      print('❌ Migration error: $e');
    }
  }
}
