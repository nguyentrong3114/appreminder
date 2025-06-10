import 'package:flutter/material.dart';
import 'package:flutter_app/provider/setting_provider.dart';
import 'package:flutter_app/views/widgets/manage/add_notes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'note_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  NotesScreenState createState() => NotesScreenState();
}

class NotesScreenState extends State<NotesScreen> {
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(children: [Expanded(child: _buildNotesList())]),
    );
  }

  Widget _buildNotesList() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Text(
          'Bạn chưa đăng nhập.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Không có note nào
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/cat_heart.png', height: 100),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFF4CD6A8),
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddNoteScreen(),
                          ),
                        );
                      },
                    ),
                    const Text(
                      "Thêm ghi chú ở đây",
                      style: TextStyle(color: Color(0xFF4CD6A8), fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final notes = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final note = notes[index].data() as Map<String, dynamic>;
            final title = note['title'] ?? '';
            final content = note['content'] ?? '';
            final isPinned = note['isPinned'] ?? false;
            final noteColor =
                note['color'] != null ? Color(note['color']) : Colors.white;
            final updatedAt =
                (note['updatedAt'] != null && note['updatedAt'] is Timestamp)
                    ? (note['updatedAt'] as Timestamp).toDate()
                    : null;

            return Material(
              color: noteColor,
              borderRadius: BorderRadius.circular(18),
              elevation: isPinned ? 3 : 1,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                leading:
                    isPinned
                        ? const Icon(Icons.push_pin, color: Colors.orange)
                        : null,
                title: Text(
                  title.isEmpty ? "(Không có tiêu đề)" : title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    if (updatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Cập nhật: ${_formatTime(context, updatedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NoteDetailScreen(noteDoc: notes[index]),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(BuildContext context, DateTime date) {
    final dateFormat = context.watch<SettingProvider>().dateFormat;
    final is24Hour = context.watch<SettingProvider>().use24HourFormat;

    final formattedDate = DateFormat(dateFormat).format(date);
    final formattedTime =
        is24Hour
            ? DateFormat('HH:mm').format(date)
            : DateFormat('hh:mm a').format(date);

    return '$formattedDate $formattedTime';
  }

  Widget buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Color(0xFF4CD6A8) : Colors.grey,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(0xFF4CD6A8) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
