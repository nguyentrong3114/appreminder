import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // PHẦN 1: AUTHENTICATION & CONFIGURATION
  // ==========================================

  /// Lấy user hiện tại đang đăng nhập
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Collection riêng cho từng user - đảm bảo data security
  CollectionReference get _habitsCollection {
    if (_currentUserId == null) {
      throw Exception('User chưa đăng nhập');
    }
    print('Current user: $_currentUserId');
    print('Collection path: users/$_currentUserId/habits');
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('habits');
  }

  // ==========================================
  // PHẦN 2: CRUD OPERATIONS - QUẢN LÝ HABIT
  // ==========================================

  /// TẠO MỚI HABIT
  /// Lưu habit mới vào Firestore với đầy đủ metadata
  Future<String> saveHabit(Habit habit) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Vui lòng đăng nhập để lưu thử thách');
      }

      print('Saving habit for user: $_currentUserId');

      final habitData = {
        // Core habit info
        'title': habit.title,
        'iconCodePoint': habit.iconCodePoint,
        'colorValue': habit.colorValue,

        // Date configuration
        'startDate': Timestamp.fromDate(habit.startDate),
        'endDate':
            habit.endDate != null ? Timestamp.fromDate(habit.endDate!) : null,
        'hasEndDate': habit.hasEndDate,

        // Habit behavior
        'type': habit.type.toString(),
        'repeatType': habit.repeatType.toString(),
        'selectedWeekdays': habit.selectedWeekdays,
        'selectedMonthlyDays': habit.selectedMonthlyDays,

        // Reminder & tracking
        'reminderEnabled': habit.reminderEnabled,
        'reminderTimes': habit.reminderTimes,
        'streakEnabled': habit.streakEnabled,
        'tags': habit.tags,

        // System metadata
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,

        // Statistics initialization
        'completionCount': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletedDate': null,
      };

      print('Habit data to save: ${habitData.keys.toList()}');

      final docRef = await _habitsCollection.add(habitData);
      print('Habit saved with ID: ${docRef.id}');

      // Log chi tiết cho monthly habits
      if (habit.repeatType == RepeatType.monthly &&
          habit.selectedMonthlyDays.isNotEmpty) {
        print('Monthly habit with days: ${habit.selectedMonthlyDays}');
      }

      return docRef.id;
    } catch (e) {
      print('Save error: $e');
      throw Exception('Không thể lưu thử thách: $e');
    }
  }

  /// CẬP NHẬT HABIT
  /// Update thông tin habit đã có sẵn
  Future<void> updateHabit(Habit habit) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Vui lòng đăng nhập để cập nhật thử thách');
      }

      print('Updating habit ${habit.id} for user: $_currentUserId');

      final habitData = {
        // Core habit info
        'title': habit.title,
        'iconCodePoint': habit.iconCodePoint,
        'colorValue': habit.colorValue,

        // Date configuration
        'startDate': Timestamp.fromDate(habit.startDate),
        'endDate':
            habit.endDate != null ? Timestamp.fromDate(habit.endDate!) : null,
        'hasEndDate': habit.hasEndDate,

        // Habit behavior
        'type': habit.type.toString(),
        'repeatType': habit.repeatType.toString(),
        'selectedWeekdays': habit.selectedWeekdays,
        'selectedMonthlyDays': habit.selectedMonthlyDays,

        // Reminder & tracking
        'reminderEnabled': habit.reminderEnabled,
        'reminderTimes': habit.reminderTimes,
        'streakEnabled': habit.streakEnabled,
        'tags': habit.tags,

        // System metadata
        'userId': _currentUserId,
        'updatedAt': FieldValue.serverTimestamp(), // Chỉ update timestamp
      };

      print('Updating habit data: ${habitData.keys.toList()}');

      await _habitsCollection.doc(habit.id).update(habitData);
      print('Habit updated successfully: ${habit.id}');
    } catch (e) {
      print('Update error: $e');
      throw Exception('Không thể cập nhật thử thách: $e');
    }
  }

  /// XÓA HABIT (Soft/Hard Delete)
  /// Soft delete: đánh dấu isActive=false, Hard delete: xóa hoàn toàn
  Future<void> deleteHabit(String habitId, {bool hardDelete = false}) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      if (hardDelete) {
        print('Hard deleting habit: $habitId');
        await _habitsCollection.doc(habitId).delete();
      } else {
        print('Soft deleting habit: $habitId');
        await _habitsCollection.doc(habitId).update({
          'isActive': false,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Habit deleted successfully');
    } catch (e) {
      print('Delete error: $e');
      throw Exception('Không thể xóa thử thách: $e');
    }
  }

  /// KHÔI PHỤC HABIT
  /// Restore habit từ soft delete
  Future<void> restoreHabit(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('Restoring habit: $habitId');
      await _habitsCollection.doc(habitId).update({
        'isActive': true,
        'deletedAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Habit restored successfully');
    } catch (e) {
      print('Restore error: $e');
      throw Exception('Không thể khôi phục thử thách: $e');
    }
  }

  // ==========================================
  // PHẦN 3: QUERY & FILTERING - TRUY VẤN DỮ LIỆU
  // ==========================================

  /// LẤY HABITS THEO LOẠI (Regular/Challenge)
  /// Stream real-time với filtering và search
  Stream<List<Habit>> getHabitsByType(
    HabitType type, {
    bool activeOnly = true,
    String? searchQuery,
  }) {
    if (_currentUserId == null) {
      print('No user authenticated');
      return Stream.value([]);
    }

    print('Getting habits by type: $type for user: $_currentUserId');

    Query query = _habitsCollection.where('type', isEqualTo: type.toString());

    // Filter chỉ lấy active habits
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Found ${snapshot.docs.length} habits of type $type');

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

          // Apply search filter
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
          print('Stream error: $error');
        });
  }

  /// LẤY TẤT CẢ HABITS
  /// Stream real-time với multiple filters
  Stream<List<Habit>> getAllHabits({
    bool activeOnly = true,
    String? searchQuery,
    RepeatType? filterByRepeatType,
  }) {
    if (_currentUserId == null) {
      print('No user authenticated');
      return Stream.value([]);
    }

    print('Getting all habits for user: $_currentUserId');

    Query query = _habitsCollection;

    // Filter active/inactive
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    // Filter theo repeat type
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
          print('Found ${snapshot.docs.length} total habits');

          var habits =
              snapshot.docs
                  .map((doc) {
                    try {
                      return _createHabitFromDoc(doc);
                    } catch (e) {
                      print('Error parsing habit ${doc.id}: $e');
                      return null;
                    }
                  })
                  .where((habit) => habit != null)
                  .cast<Habit>()
                  .toList();

          // Apply search filter
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
          print('Stream error: $error');
        });
  }

  /// LẤY HABITS THEO NGÀY CỤ THỂ
  /// Filter habits cần thực hiện trong ngày
  Stream<List<Habit>> getHabitsForDate(DateTime date) {
    return getAllHabits().map((habits) {
      return habits
          .where((habit) => _shouldHabitRunOnDate(habit, date))
          .toList();
    });
  }

  /// LẤY HABIT THEO ID
  /// Get single habit với error handling
  Future<Habit?> getHabitById(String habitId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User chưa đăng nhập');
      }

      print('Getting habit: $habitId');
      final doc = await _habitsCollection.doc(habitId).get();

      if (doc.exists) {
        print('Habit found');
        return _createHabitFromDoc(doc as QueryDocumentSnapshot);
      }

      print('Habit not found');
      return null;
    } catch (e) {
      print('Get habit error: $e');
      throw Exception('Không thể lấy thông tin thử thách: $e');
    }
  }

  // ==========================================
  // PHẦN 4: BUSINESS LOGIC - LOGIC NGHIỆP VỤ
  // ==========================================

  /// CHUYỂN ĐỔI FIRESTORE DOC THÀNH HABIT OBJECT
  /// Xử lý migration và data parsing
  Habit _createHabitFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Migration logic cho selectedMonthlyDays
    List<int> selectedMonthlyDays = [];
    if (data.containsKey('selectedMonthlyDays')) {
      selectedMonthlyDays = List<int>.from(data['selectedMonthlyDays'] ?? []);
    } else if (data.containsKey('monthlyDay')) {
      selectedMonthlyDays = [data['monthlyDay'] as int];
      print(
        'Migrating monthlyDay ${data['monthlyDay']} to selectedMonthlyDays',
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
      selectedMonthlyDays: selectedMonthlyDays,
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

  /// KIỂM TRA HABIT CÓ CHẠY VÀO NGÀY CỤ THỂ KHÔNG
  /// Logic xác định habit có active trong ngày hay không
  bool _shouldHabitRunOnDate(Habit habit, DateTime date) {
    // Check start date
    if (date.isBefore(habit.startDate)) return false;

    // Check end date
    if (habit.hasEndDate &&
        habit.endDate != null &&
        date.isAfter(habit.endDate!)) {
      return false;
    }

    // Check repeat pattern
    switch (habit.repeatType) {
      case RepeatType.daily:
        return true;

      case RepeatType.weekly:
        return habit.selectedWeekdays.contains(date.weekday);

      case RepeatType.monthly:
        return habit.selectedMonthlyDays.contains(date.day);

      case RepeatType.yearly:
        return date.day == habit.startDate.day &&
            date.month == habit.startDate.month;
    }
  }

  // ==========================================
  // PHẦN 5: COMPLETION TRACKING - THEO DÕI HOÀN THÀNH
  // ==========================================

  /// ĐÁNH DẤU HABIT HOÀN THÀNH
  /// Lưu completion record và update stats
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

      print('Habit marked as completed for $date');
    } catch (e) {
      print('Mark completed error: $e');
      throw Exception('Không thể đánh dấu hoàn thành: $e');
    }
  }

  /// CẬP NHẬT THỐNG KÊ HABIT
  /// Update completion count, streaks, last completed date
  Future<void> _updateHabitStats(String habitId, DateTime completedDate) async {
    final doc = await _habitsCollection.doc(habitId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    int completionCount = (data['completionCount'] ?? 0) + 1;
    int currentStreak = data['currentStreak'] ?? 0;
    int longestStreak = data['longestStreak'] ?? 0;

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

  // ==========================================
  // PHẦN 6: STATISTICS - THỐNG KÊ & BÁO CÁO
  // ==========================================

  /// LẤY THỐNG KÊ TỔNG QUAN CỦA USER
  /// Dashboard statistics và overview metrics
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
      'habitsToday': 0, // TODO: Implement logic
      'currentStreaks': 0, // TODO: Implement logic
    };
  }

  // ==========================================
  // PHẦN 7: DATA MIGRATION - NÂNG CẤP DỮ LIỆU
  // ==========================================

  /// MIGRATION - CẬP NHẬT TẤT CẢ HABITS CŨ
  /// Chuyển đổi từ monthlyDay sang selectedMonthlyDays
  Future<void> migrateOldHabits() async {
    try {
      if (_currentUserId == null) return;

      print('Starting migration for user: $_currentUserId');

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
            'Migrated habit ${doc.id}: monthlyDay $monthlyDay -> selectedMonthlyDays [$monthlyDay]',
          );
        }
      }

      print('Migration completed');
    } catch (e) {
      print('Migration error: $e');
    }
  }
}
