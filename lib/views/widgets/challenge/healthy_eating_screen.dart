import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HealthyEatingScreen(),
    );
  }
}

class HealthyEatingScreen extends StatelessWidget {
  const HealthyEatingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
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
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ăn Ngon Sống Khỏe',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Ăn uống lành mạnh là về sự cân bằng và đảm bảo rằng cơ thể bạn nhận đủ dưỡng chất cần thiết để hoạt động tốt.😊🥦',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/cat_fish.png',
                          width: 150,
                          height: 150,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // List of tips
              _buildTipItem(
                icon: Icons.coffee_outlined,
                title: 'Bắt đầu ngày mới thật tràn đầy năng lượng',
                description:
                    'Bữa sáng giúp bạn tỉnh táo hơn, tập trung hơn và vui vẻ hơn! 😊🍞🥑',
              ),
              _buildTipItem(
                icon: Icons.restaurant_outlined,
                title: 'Hộp cơm mang theo',
                description:
                    'Cung cấp năng lượng và dưỡng chất để bạn tiếp tục tràn đầy sức sống suốt buổi chiều! ⚡🥗😊',
              ),
              _buildTipItem(
                icon: Icons.set_meal_outlined,
                title: 'Thêm cá vào bữa ăn nào',
                description:
                    'Là nguồn cung cấp Omega-3 quan trọng cho cơ thể! 🐟💙✨',
              ),
              _buildTipItem(
                icon: Icons.lunch_dining_outlined,
                title: 'Thịt bò, ngon và đầy dinh dưỡng',
                description:
                    "Là nguồn cung cấp tuyệt vời của sắt, kẽm, niacin, riboflavin, vitamin B12 và thiamine! 💪🥩✨",
              ),
              _buildTipItem(
                icon: Icons.medication_outlined,
                title: 'Bổ sung vitamin mỗi ngày nhé',
                description: 'Giảm căng thẳng và lo âu! 😌🌿✨',
              ),
              _buildTipItem(
                icon: Icons.cake_outlined,
                title: 'Nhâm nhi chút bánh cho vui nha',
                description: 'Giúp tiêu hóa tốt hơn! 😊🍃✨',
              ),
              _buildTipItem(
                icon: Icons.coffee_outlined,
                title: 'Một tách trà mỗi ngày',
                description:
                    'Trà có thể giúp giảm nguy cơ đau tim và đột quỵ! 🍵💚✨',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
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
              color: Colors.orange.shade200,
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
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange),
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
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
