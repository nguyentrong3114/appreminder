import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteDetailScreen extends StatefulWidget {
  final DocumentSnapshot noteDoc;
  
  const NoteDetailScreen({super.key, required this.noteDoc});

  @override
  NoteDetailScreenState createState() => NoteDetailScreenState();
}

class NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPinned = false;
  Color _noteColor = Colors.white;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final data = widget.noteDoc.data() as Map<String, dynamic>;
    
    _titleController = TextEditingController(text: data['title'] ?? '');
    _contentController = TextEditingController(text: data['content'] ?? '');
    _isPinned = data['isPinned'] ?? false;
    _noteColor = data['color'] != null ? Color(data['color']) : Colors.white;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.noteDoc.data() as Map<String, dynamic>;
    final updatedAt = (data['updatedAt'] != null && data['updatedAt'] is Timestamp)
        ? (data['updatedAt'] as Timestamp).toDate()
        : null;

    return Scaffold(
      backgroundColor: _noteColor,
      appBar: AppBar(
        backgroundColor: _noteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset về giá trị ban đầu
                  _titleController.text = data['title'] ?? '';
                  _contentController.text = data['content'] ?? '';
                  _isPinned = data['isPinned'] ?? false;
                  _noteColor = data['color'] != null ? Color(data['color']) : Colors.white;
                });
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            if (_isEditing)
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Tiêu đề...',
                  border: InputBorder.none,
                ),
              )
            else
              Text(
                _titleController.text.isEmpty ? '(Không có tiêu đề)' : _titleController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Thông tin thời gian và pin
            Row(
              children: [
                if (_isPinned)
                  const Icon(Icons.push_pin, color: Colors.orange, size: 16),
                if (_isPinned) const SizedBox(width: 4),
                if (updatedAt != null)
                  Text(
                    'Cập nhật: ${_formatTime(updatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Nội dung
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Nội dung ghi chú...',
                        border: InputBorder.none,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _contentController.text.isEmpty ? 'Không có nội dung' : _contentController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
            
            // Các tùy chọn khi đang chỉnh sửa
            if (_isEditing) ...[
              const Divider(),
              Row(
                children: [
                  // Pin/Unpin
                  IconButton(
                    icon: Icon(
                      _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _isPinned ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinned = !_isPinned;
                      });
                    },
                  ),
                  const Text('Ghim'),
                  
                  const Spacer(),
                  
                  // Color picker
                  Row(
                    children: [
                      _buildColorOption(Colors.white),
                      _buildColorOption(Colors.yellow[100]!),
                      _buildColorOption(Colors.green[100]!),
                      _buildColorOption(Colors.blue[100]!),
                      _buildColorOption(Colors.pink[100]!),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _noteColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _noteColor == color ? Colors.black : Colors.grey,
            width: _noteColor == color ? 2 : 1,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa ghi chú'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote();
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(widget.noteDoc.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ghi chú thành công!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    }
  }

  void _saveNote() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      if (title.isEmpty && content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ghi chú không thể để trống!')),
        );
        return;
      }

      Map<String, dynamic> updateData = {
        'title': title,
        'content': content,
        'isPinned': _isPinned,
        'color': _noteColor.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(widget.noteDoc.id)
          .update(updateData);

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thay đổi thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: $e')),
        );
      }
    }
  }
}
