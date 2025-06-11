import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart';
import 'challenge_screen.dart';
import 'package:intl/intl.dart';

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
  final DateTime? selectedDate;

  const BeWeirdScreen({super.key, this.selectedDate});

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
                context,
                Icons.work_outlined,
                'Tìm việc làm',
                'Tìm công việc mà bạn yêu thích, không phải vì tiền bạc mà vì đam mê.👩‍💻👨‍🎨',
              ),
              _buildTipItem(
                context,
                Icons.pets_outlined,
                'Nuôi thú cưng',
                'Nuôi thú cưng giúp bạn giảm căng thẳng, tăng cường sức khỏe và tạo niềm vui.🐶🐱',
              ),
              _buildTipItem(
                context,
                Icons.eco_outlined,
                'Trồng cây',
                'Cây xanh giúp cải thiện chất lượng không khí, giảm căng thẳng và tạo cảm giác thoải mái.🌳🌳',
              ),
              _buildTipItem(
                context,
                Icons.brush_outlined,
                'Học vẽ',
                'Học vẽ giúp bạn thể hiện cảm xúc, tăng cường trí não và giảm căng thẳng.🎨🎨',
              ),
              _buildTipItem(
                context,
                Icons.gamepad_outlined,
                'Chơi cờ',
                'Chơi cờ giúp cải thiện trí não, tăng cường tư duy và giảm căng thẳng.♟️♟️',
              ),
              _buildTipItem(
                context,
                Icons.cake_outlined,
                'Tiệc tùng',
                'Tổ chức tiệc tùng giúp tăng cường tình bạn, giảm căng thẳng và tạo niềm vui.🎉🎉',
              ),
              _buildTipItem(
                context,
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

  Widget _buildTipItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegularHabitScreen(
                        initialTitle: title,
                        initialIcon: icon,
                        initialColor: Colors.purple.shade200,
                        reminderEnabledByDefault: false,
                        initialStartDate: ChallengeScreen.selectedDate,
                        formattedStartDate: DateFormat(
                          'MMMM d, yyyy',
                          'vi_VN',
                        ).format(ChallengeScreen.selectedDate),
                      ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.purple.shade200),
            ),
          ),
        ],
      ),
    );
  }
}
