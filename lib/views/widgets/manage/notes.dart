import 'package:flutter/material.dart';
import 'package:flutter_app/views/widgets/manage/add_notes_screen.dart';

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
    // Empty state with cat illustration
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   'assets/images/cat_notes.png', // Make sure to add this image to your assets
          //   width: 120,
          //   height: 120,
          // ),
          SizedBox(height: 20),
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
