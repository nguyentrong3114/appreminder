import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNoteScreen extends StatefulWidget {
  final DocumentSnapshot? noteDoc;
  const AddNoteScreen({super.key, this.noteDoc});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isPinned = false;
  Color _noteColor = Colors.white;
  bool get isEditMode => widget.noteDoc != null;
  @override
  void initState() {
    super.initState();

    // Nếu là chế độ edit, load dữ liệu hiện có
    if (isEditMode) {
      final data = widget.noteDoc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _contentController.text = data['content'] ?? '';
      _isPinned = data['isPinned'] ?? false;
      _noteColor = data['color'] != null ? Color(data['color']) : Colors.white;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noteColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomToolbar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _noteColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        isEditMode ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú',
      ), // Thay đổi title
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Quay lại',
      ),
      actions: [
        // Thêm nút xóa nếu là chế độ edit
        if (isEditMode)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteDialog,
            tooltip: 'Xóa',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Tiêu đề',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _contentController,
              style: const TextStyle(fontSize: 16.0),
              decoration: const InputDecoration(
                hintText: 'Nội dung ghi chú',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
              ),
              maxLines: null,
              minLines: 10,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: _noteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chỉnh sửa lúc ${DateTime.now().hour}:${DateTime.now().minute}',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinned = !_isPinned;
                      });
                    },
                    tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim lên trên',
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens_outlined),
                    onPressed: _showColorPicker,
                    tooltip: 'Màu nền',
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: _saveNote,
                    tooltip: 'Lưu',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          .doc(widget.noteDoc!.id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ghi chú thành công!')),
        );
        Navigator.of(context).pop(true); // Return true để báo đã xóa
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  void _showColorPicker() {
    final List<Color> colors = [
      Colors.white,
      Colors.red[100]!,
      Colors.orange[100]!,
      Colors.yellow[100]!,
      Colors.green[100]!,
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.blueGrey[100]!,
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Màu nền',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final bool isSelected = _noteColor == colors[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _noteColor = colors[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child:
                            isSelected
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Lỗi đăng nhập'),
              content: const Text('Bạn chưa đăng nhập!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    if (title.isEmpty && content.isEmpty) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Thông báo'),
              content: const Text('Ghi chú trống sẽ không được lưu.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    try {
      Map<String, dynamic> noteData = {
        'title': title,
        'content': content,
        'isPinned': _isPinned,
        'color': _noteColor.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditMode) {
        // Cập nhật note hiện có
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(widget.noteDoc!.id)
            .update(noteData);
      } else {
        // Tạo note mới
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .add(noteData);
      }

      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Thành công'),
              content: Text(
                isEditMode
                    ? 'Đã cập nhật ghi chú thành công!'
                    : 'Đã lưu ghi chú thành công!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(
                      context,
                    ).pop(true); // Return true để báo đã lưu
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Lỗi'),
              content: Text('Lỗi lưu ghi chú: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}
