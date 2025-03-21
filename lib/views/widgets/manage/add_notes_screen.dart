import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isArchived = false;
  Color _noteColor = Colors.white;
  List<String> labels = [];
  DateTime? reminderTime;
  List<String> images = [];

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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Quay lại',
      ),
      actions: [
        IconButton(
          icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () {
            setState(() {
              _isPinned = !_isPinned;
            });
          },
          tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim lên trên',
        ),
        IconButton(
          icon: const Icon(Icons.add_alert_outlined),
          onPressed: _showReminderDialog,
          tooltip: 'Thêm nhắc nhở',
        ),
        IconButton(
          icon: Icon(_isArchived ? Icons.archive : Icons.archive_outlined),
          onPressed: () {
            setState(() {
              _isArchived = !_isArchived;
            });
          },
          tooltip: _isArchived ? 'Bỏ lưu trữ' : 'Lưu trữ',
        ),
        _buildMoreMenu(),
      ],
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'delete':
            _showDeleteConfirmation();
            break;
          case 'copy':
            _copyNoteToClipboard();
            break;
          case 'share':
            _shareNote();
            break;
          case 'labels':
            _showLabelsDialog();
            break;
          case 'help':
            _showHelpDialog();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.black54),
              SizedBox(width: 12),
              Text('Xóa'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, color: Colors.black54),
              SizedBox(width: 12),
              Text('Tạo bản sao'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.black54),
              SizedBox(width: 12),
              Text('Chia sẻ'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'labels',
          child: Row(
            children: [
              Icon(Icons.label_outline, color: Colors.black54),
              SizedBox(width: 12),
              Text('Nhãn'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.black54),
              SizedBox(width: 12),
              Text('Trợ giúp & phản hồi'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
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
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                ),
              ),
              maxLines: null,
              minLines: 10,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (images.isNotEmpty) _buildImagePreview(),
            if (labels.isNotEmpty) _buildLabelsPreview(),
            if (reminderTime != null) _buildReminderPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      images.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabelsPreview() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: labels.map((label) {
          return Chip(
            label: Text(label),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                labels.remove(label);
              });
            },
            backgroundColor: Colors.grey[200],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReminderPreview() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Chip(
        avatar: const Icon(Icons.access_time, size: 18),
        label: Text(_formatReminderTime()),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () {
          setState(() {
            reminderTime = null;
          });
        },
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  String _formatReminderTime() {
    if (reminderTime == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(
      reminderTime!.year, 
      reminderTime!.month, 
      reminderTime!.day
    );
    
    String timeStr = '${reminderTime!.hour}:${reminderTime!.minute.toString().padLeft(2, '0')}';
    
    if (reminderDate.isAtSameMomentAs(today)) {
      return 'Hôm nay, $timeStr';
    } else if (reminderDate.isAtSameMomentAs(tomorrow)) {
      return 'Ngày mai, $timeStr';
    } else {
      return '${reminderTime!.day}/${reminderTime!.month}/${reminderTime!.year}, $timeStr';
    }
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
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: _showChecklistDialog,
                    tooltip: 'Danh sách kiểm tra',
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens_outlined),
                    onPressed: _showColorPicker,
                    tooltip: 'Màu nền',
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: _addImage,
                    tooltip: 'Thêm hình ảnh',
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

  void _showReminderDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thêm nhắc nhở',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Sáng mai'),
                onTap: () {
                  final now = DateTime.now();
                  final tomorrow = now.add(const Duration(days: 1));
                  setState(() {
                    reminderTime = DateTime(
                      tomorrow.year,
                      tomorrow.month,
                      tomorrow.day,
                      8,
                      0,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Tối nay'),
                onTap: () {
                  final now = DateTime.now();
                  setState(() {
                    reminderTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      20,
                      0,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Chọn ngày và giờ'),
                onTap: () async {
                  Navigator.pop(context);
                  // Normally would use a date/time picker
                  setState(() {
                    reminderTime = DateTime.now().add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa ghi chú?'),
          content: const Text('Ghi chú đã xóa sẽ được chuyển vào thùng rác.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to notes list
              },
              child: const Text('XÓA'),
            ),
          ],
        );
      },
    );
  }

  void _copyNoteToClipboard() {
    // Implementation would copy note content to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép ghi chú')),
    );
  }

  void _shareNote() {
    // Implementation would share note
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang chia sẻ ghi chú...')),
    );
  }

  void _showLabelsDialog() {
    final TextEditingController labelController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nhãn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        hintText: 'Tạo nhãn mới',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.add),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          this.setState(() {
                            labels.add(value);
                          });
                          labelController.clear();
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (labels.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: labels.map((label) {
                          return Chip(
                            label: Text(label),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              this.setState(() {
                                labels.remove(label);
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trợ giúp & phản hồi'),
          content: const Text('Đây là phần trợ giúp và phản hồi cho ứng dụng ghi chú.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ĐÓNG'),
            ),
          ],
        );
      },
    );
  }

  void _showChecklistDialog() {
    // Implementation would show checklist dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng danh sách kiểm tra sẽ sớm ra mắt')),
    );
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
                        child: isSelected
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

  void _addImage() {
    // For demonstration, just add a sample image URL
    setState(() {
      images.add('https://picsum.photos/200/300?random=${images.length}');
    });
    
    // Normally would use image picker:
    // final ImagePicker _picker = ImagePicker();
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _images.add(image.path);
    //   });
    // }
  }

  void _saveNote() {
    // Implementation would save the note
    final title = _titleController.text;
    final content = _contentController.text;
    
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ghi chú trống sẽ không được lưu')),
      );
      Navigator.pop(context);
      return;
    }
    
    // Save note logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu ghi chú')),
    );
    Navigator.pop(context);
  }
}
