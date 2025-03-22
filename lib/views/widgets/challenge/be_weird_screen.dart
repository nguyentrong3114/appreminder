import 'package:flutter/material.dart';

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
      home: const BeWeirdScreen(),
    );
  }
}

class BeWeirdScreen extends StatelessWidget {
  const BeWeirdScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade200),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lập dị một chút, chất riêng một tí',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Được gọi là kỳ lạ thật tuyệt, vì điều đó có nghĩa là bạn không giống bất kỳ ai khác. 😆🌈✨',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/cat_heart.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTipItem(
                Icons.work_outlined,
                'Tìm việc làm',
                'Tìm công việc mà bạn yêu thích, không phải vì tiền bạc mà vì đam mê.👩‍💻👨‍🎨',
              ),
              _buildTipItem(
                Icons.pets_outlined,
                'Nuôi thú cưng',
                'Nuôi thú cưng giúp bạn giảm căng thẳng, tăng cường sức khỏe và tạo niềm vui.🐶🐱',
              ),
              _buildTipItem(
                Icons.eco_outlined,
                'Trồng cây',
                'Cây xanh giúp cải thiện chất lượng không khí, giảm căng thẳng và tạo cảm giác thoải mái.🌳🌳',
              ),
              _buildTipItem(
                Icons.brush_outlined,
                'Học vẽ',
                'Học vẽ giúp bạn thể hiện cảm xúc, tăng cường trí não và giảm căng thẳng.🎨🎨',
              ),
              _buildTipItem(
                Icons.gamepad_outlined,
                'Chơi cờ',
                'Chơi cờ giúp cải thiện trí não, tăng cường tư duy và giảm căng thẳng.♟️♟️',
              ),
              _buildTipItem(
                Icons.cake_outlined,
                'Tiệc tùng',
                'Tổ chức tiệc tùng giúp tăng cường tình bạn, giảm căng thẳng và tạo niềm vui.🎉🎉',
              ),
              _buildTipItem(
                Icons.book_outlined,
                'Đi du lịch',
                'Du lịch giúp bạn khám phá thế giới, tăng cường kiến thức và giảm căng thẳng.🌍🌍',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
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
              color: Colors.purple.shade200,
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
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.purple.shade200),
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
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.purple.shade200),
          ),
        ],
      ),
    );
  }
}
