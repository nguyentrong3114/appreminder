import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  DiaryScreenState createState() => DiaryScreenState();
}

class DiaryScreenState extends State<DiaryScreen> {
  List<DateTime> selectedMonths = [];
  DateTime currentMonth = DateTime.now();
  late ScrollController monthScrollController;
  int currentMonthIndex = 24; // Giả sử chúng ta có 48 tháng (4 năm)
  
  @override
  void initState() {
    super.initState();
    _initializeMonths();
    
    // Khởi tạo ScrollController với vị trí ban đầu
    monthScrollController = ScrollController(
      initialScrollOffset: (currentMonthIndex - 2) * 80.0
    );
  }
  
  @override
  void dispose() {
    monthScrollController.dispose();
    super.dispose();
  }
  
  void _initializeMonths() {
    DateTime now = DateTime.now();
    DateTime startMonth = DateTime(now.year - 2, 1, 1); // Bắt đầu từ 2 năm trước
    
    // Tạo danh sách các tháng (48 tháng = 4 năm)
    selectedMonths = List.generate(
      48,
      (index) {
        int monthsToAdd = index;
        return DateTime(
          startMonth.year + (startMonth.month + monthsToAdd - 1) ~/ 12,
          (startMonth.month + monthsToAdd - 1) % 12 + 1,
          1,
        );
      },
    );
    
    // Tìm chỉ mục của tháng hiện tại
    currentMonthIndex = selectedMonths.indexWhere((month) => 
      month.month == now.month && 
      month.year == now.year
    );
    
    // Đặt tháng hiện tại
    currentMonth = selectedMonths[currentMonthIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMonthSelection(),
        Expanded(
          child: _buildDiaryContent(),
        ),
      ],
    );
  }

  Widget _buildMonthSelection() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedMonths.length,
        controller: monthScrollController,
        itemBuilder: (context, index) {
          DateTime month = selectedMonths[index];
          bool isSelected = month.month == currentMonth.month && 
                            month.year == currentMonth.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                currentMonth = month;
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4CD6A8) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "thg ${month.month}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "${month.year}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiaryContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hình ảnh mèo
          // Image.asset(
          //   'assets/images/cat.png', // Đảm bảo bạn đã thêm hình ảnh vào thư mục assets
          //   width: 150,
          //   height: 150,
          //   fit: BoxFit.contain,
          //   errorBuilder: (context, error, stackTrace) {
          //     return SizedBox(
          //       width: 150,
          //       height: 150,
          //       child: Icon(
          //         Icons.pets,
          //         size: 80,
          //         color: Colors.grey,
          //       ),
          //     );
          //   },
          // ),
          SizedBox(height: 20),
          // Văn bản "Thêm nhật ký ở đây"
          Text(
            "Thêm nhật ký ở đây",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 40),
          // Nút thêm mới (không cần thiết kế vì đã có trong navigation bar)
        ],
      ),
    );
  }
}
