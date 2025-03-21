import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  bool isAllDayEnabled = false;
  bool isReminderEnabled =false;
  bool isAlarmEnabled = false;
  bool isRepeatEnabled = false;
  bool isPinnedEnabled = false;
  bool isSubTaskEnabled = false;
  int selectedColorIndex = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  
  // Biến để theo dõi nếu có thay đổi chưa lưu
  bool hasUnsavedChanges = false;
  List<Color> colors = [
    const Color(0xFF4CD080), // Green
    const Color(0xFFFFBE55), // Yellow/Orange
    const Color(0xFFFF6B81), // Pink
    const Color(0xFF8F9BFF), // Purple/Blue
    const Color(0xFFFF8A65), // Orange
    Colors.black,
    const Color(0xFF4CD080), // Green again (for the leaf icon)
  ];

  @override
  void initState() {
    super.initState();
    
    // Thêm listeners để theo dõi thay đổi
    _titleController.addListener(_onTextChanged);
    _detailsController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    // Hủy controllers khi widget bị hủy
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }
  
  // Theo dõi khi có thay đổi trong form
  void _onTextChanged() {
    if (!hasUnsavedChanges) {
      setState(() {
        hasUnsavedChanges = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleInput(),
                              const Divider(),
                              _buildAllDaySection(),
                              _buildDateTimeSection(),
                              const Divider(),
                              _buildReminderSection(),
                              const Divider(),
                              _buildOptionsSection(),
                              const Divider(),
                              _buildColorPickerSection(),
                              const Divider(),
                            
                             
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF4CD080), size: 28),
            onPressed: () {
              _handleCloseButton();
            },
          ),
          const Text(
            'TO DO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF4CD080), size: 28),
            onPressed: () {
              _saveTodo();
            },
          ),
        ],
      ),
    );
  }
  void _handleCloseButton() {
    // Kiểm tra nếu có thay đổi chưa lưu
    if (hasUnsavedChanges || 
        _titleController.text.isNotEmpty || 
        _detailsController.text.isNotEmpty) {
      _showDiscardChangesDialog();
    } else {
      // Không có thay đổi, thoát trực tiếp
      Navigator.of(context).pop();
    }
  }
  
  // Hiển thị hộp thoại xác nhận khi có thay đổi chưa lưu
  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy thay đổi?'),
          content: const Text('Bạn có thay đổi chưa lưu. Bạn có muốn hủy bỏ những thay đổi này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('TIẾP TỤC CHỈNH SỬA'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: const Text('HỦY BỎ'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
            ),
          ],
        );
      },
    );
  }
  
  // Lưu todo
  void _saveTodo() {
    // Kiểm tra xem có dữ liệu để lưu không
    if (_titleController.text.isEmpty) {
      // Hiển thị thông báo nếu tiêu đề trống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Thực hiện lưu dữ liệu (có thể thêm logic lưu vào cơ sở dữ liệu ở đây)
    
    // Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu công việc'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Quay lại màn hình trước
    Navigator.of(context).pop();
  }
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Tiêu đề',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 18),
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Thêm chi tiết',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  const SizedBox(width: 8),
                  
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllDaySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4CD080),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '24',
                style: TextStyle(color: Color(0xFF4CD080), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cả ngày',
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Switch(
            value: isAllDayEnabled,
            onChanged: (value) {
              setState(() {
                isAllDayEnabled = value;
              });
            },
            activeColor: const Color(0xFF4CD080),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.arrow_forward, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                '16/03/2025',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              const Text(
                '08:15 CH',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                '16/03/2025',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              const Text(
                '09:15 CH',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                'Cài đặt nhắc nhở',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Switch(
                value: isReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    isReminderEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4CD080),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Text(
                '15 phút trước',
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            children: [
              const Icon(Icons.add, color: Color(0xFF4CD080), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Thêm nhắc nhở',
                style: TextStyle(fontSize: 14, color: Color(0xFF4CD080)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
         
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.sync, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                'Không lặp lại',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.push_pin, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                'Ghim',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Switch(
                value: isPinnedEnabled,
                onChanged: (value) {
                  setState(() {
                    isPinnedEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4CD080),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFF4CD080)),
              const SizedBox(width: 12),
              const Text(
                'Xanh lá cây',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              colors.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColorIndex = index;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    border: selectedColorIndex == index
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: selectedColorIndex == index
                      ? const Center(
                          child: Icon(Icons.check, color: Colors.white, size: 16),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  

}
