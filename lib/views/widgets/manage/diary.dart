import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/views/widgets/manage/add_diary_screen.dart';

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
      initialScrollOffset: (currentMonthIndex - 2) * 80.0,
    );
  }

  @override
  void dispose() {
    monthScrollController.dispose();
    super.dispose();
  }

  void _initializeMonths() {
    DateTime now = DateTime.now();
    DateTime startMonth = DateTime(
      now.year - 2,
      1,
      1,
    ); // Bắt đầu từ 2 năm trước

    // Tạo danh sách các tháng (48 tháng = 4 năm)
    selectedMonths = List.generate(48, (index) {
      int monthsToAdd = index;
      return DateTime(
        startMonth.year + (startMonth.month + monthsToAdd - 1) ~/ 12,
        (startMonth.month + monthsToAdd - 1) % 12 + 1,
        1,
      );
    });

    // Tìm chỉ mục của tháng hiện tại
    currentMonthIndex = selectedMonths.indexWhere(
      (month) => month.month == now.month && month.year == now.year,
    );

    // Đặt tháng hiện tại
    currentMonth = selectedMonths[currentMonthIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildMonthSelection(), Expanded(child: _buildDiaryContent())],
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
          bool isSelected =
              month.month == currentMonth.month &&
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
    // Lấy ngày bắt đầu & kết thúc của tháng đang chọn
    final start = DateTime(currentMonth.year, currentMonth.month, 1);
    final end = DateTime(currentMonth.year, currentMonth.month + 1, 1);

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('diaries')
              .where('date', isGreaterThanOrEqualTo: start)
              .where('date', isLessThan: end)
              .orderBy('date', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/cat_relaxation.png', 
                  height: 100,
                ),
                SizedBox(height: 18),
                Text(
                  "Không có nhật ký trong tháng này.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final diaries = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: diaries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = diaries[index];
            final data = doc.data() as Map<String, dynamic>;

            // Xử lý ngày giờ
            DateTime? date;
            if (data['date'] != null) {
              if (data['date'] is Timestamp) {
                date = (data['date'] as Timestamp).toDate();
              } else if (data['date'] is DateTime) {
                date = data['date'];
              }
            }

            // Xử lý màu
            final colorName = data['color'] ?? "Xanh lá cây";
            final color = _colorFromName(colorName);

            return Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    (data['mood'] ?? '😊').toString(),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                title: Text(
                  data['content'] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle:
                    date != null
                        ? Text(
                          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        )
                        : null,
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  _showDiaryDetail(doc, data, date);
                },
              ),
            );
          },
        );
      },
    );
  }

  Color _colorFromName(String colorName) {
    switch (colorName) {
      case "Xanh lá cây":
        return Colors.green;
      case "Xanh da trời":
        return Colors.blue;
      case "Tím":
        return Colors.purple;
      case "Hồng":
        return Colors.pink;
      case "Vàng":
        return Colors.amber;
      case "Cam":
        return Colors.orange;
      case "Xanh ngọc":
        return Colors.teal;
      case "Xanh dương":
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  void _showDiaryDetail(
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    DateTime? date,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final color = _colorFromName(data['color'] ?? "Xanh lá cây");
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Text(
                  (data['mood'] ?? '😊').toString(),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Text("Chi tiết nhật ký", style: TextStyle(color: color)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (date != null)
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year} "
                      "${date.hour.toString().padLeft(2, '0')}:"
                      "${date.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              Text(
                data['content'] ?? "",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.palette, size: 18, color: color),
                  const SizedBox(width: 6),
                  Text(
                    data['color'] ?? "",
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // XÓA
            TextButton.icon(
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Xác nhận xóa"),
                        content: const Text(
                          "Bạn chắc chắn muốn xóa nhật ký này?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Hủy"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Xóa"),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('diaries')
                      .doc(doc.id)
                      .delete();
                }
              },
            ),

            // SỬA
            TextButton.icon(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              label: Text(
                'Sửa',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddDiaryScreen(initData: data, docId: doc.id),
                  ),
                );
              },
            ),
            // ĐÓNG
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
