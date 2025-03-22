import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart'; // Thêm import này để dẫn tới màn hình tiếp theo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BeActiveScreen(),
    );
  }
}

class BeActiveScreen extends StatelessWidget {
  const BeActiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink.shade200),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.pink.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Vận động kiểu của tớ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Hoạt động thể chất không chỉ tốt cho sức khỏe mà còn mang lại vô vàn lợi ích khác. 💪🏃‍♂️✨',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/cat_active.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // List of tips with navigation to RegularHabitScreen
              _buildTipItem(
                context: context,
                icon: Icons.cleaning_services_outlined,
                title: 'Dọn dẹp',
                description:
                    'Giúp cơ thể vận động, tinh thần sảng khoái và không gian sạch sẽ.🧹🧽',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.directions_run_outlined,
                title: 'Tập thể dục',
                description:
                    'Giúp cơ thể khỏe mạnh, tăng cường sức khỏe tim mạch và giảm căng thẳng.💪🏋️‍♂️',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.local_dining_outlined,
                title: 'Nấu ăn tại nhà',
                description:
                    'Giúp cơ thể vận động, tinh thần sảng khoái và ăn uống lành mạnh.👨‍🍳🥗',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.health_and_safety_outlined,
                title: 'Kiểm tra sức khỏe định kỳ',
                description:
                    'Giúp phát hiện sớm các vấn đề về sức khỏe và tư vấn cách phòng tránh.🩺🩺',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.sports_outlined,
                title: 'Tham gia vào lớp Yoga',
                description:
                    'Giúp cơ thể linh hoạt, tinh thần sảng khoái và giảm căng thẳng.🧘‍♂️🧘‍♀️',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.bed_outlined,
                title: 'Dọn giường',
                description:
                    'Giúp cơ thể vận động, tinh thần sảng khoái và giảm căng thẳng.🛏️🛏️',
              ),
              _buildTipItem(
                context: context,
                icon: Icons.emoji_objects_outlined,
                title: 'Bỏ thói quen xấu',
                description:
                    'Giúp cơ thể khỏe mạnh, tinh thần sảng khoái và tăng cường sức khỏe.🚭🚭',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.pink.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
          ),
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.pink.shade200),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          // Thêm nút dẫn đến RegularHabitScreen
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegularHabitScreen(
                        initialTitle: title,
                        initialIcon: icon, // Truyền icon từ tip
                        initialColor: Colors.pink.shade200,
                        reminderEnabledByDefault: true, // Bật nhắc nhở mặc định
                      ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
