import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart'; // Thêm import này
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
      home: const SelfImprovementScreen(),
    );
  }
}

class SelfImprovementScreen extends StatelessWidget {
  final DateTime? selectedDate;

  const SelfImprovementScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 252, 120, 128),
          ),
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
                  color: const Color.fromARGB(255, 252, 120, 128),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hoàn thiện bản thân',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Đó là một hành trình không ngừng, giúp bạn hiểu rõ hơn về tính cách, suy nghĩ và cảm xúc của mình. ✨🌿💖',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/cat_selfimprovement.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTipItem(
                context,
                Icons.language_outlined,
                'Học một ngôn ngữ mới',
                'Giúp tăng cường trí não, kỹ năng giao tiếp và mở rộng tầm hiểu biết.🌍📚',
              ),
              _buildTipItem(
                context,
                Icons.work_outlined,
                'Quản lý khối lượng công việc',
                'Giúp bạn làm việc hiệu quả, giảm căng thẳng và tăng cường sức khỏe.📅📝',
              ),
              _buildTipItem(
                context,
                Icons.emoji_objects_outlined,
                'Học một kỹ năng mới',
                'Học kỹ năng mới giúp bạn phát triển bản thân, tăng cường tự tin và sự sáng tạo.🎶🎨',
              ),
              _buildTipItem(
                context,
                Icons.done_all_outlined,
                'Hoàn thành công việc trước thời hạn deadline',
                'Giúp bạn tự tin, tăng cường sự tự tin và giảm căng thẳng.📅📝',
              ),
              _buildTipItem(
                context,
                Icons.music_note_outlined,
                'Học cách chơi một nhạc cụ mới',
                'Giúp tăng cường trí não, giảm căng thẳng và tạo niềm vui.🎶🎵',
              ),
              _buildTipItem(
                context,
                Icons.emoji_emotions_outlined,
                'Giữ kỳ vọng ở mức cân bằng',
                'Giúp bạn tự tin, tăng cường sự tự tin và giảm căng thẳng.🌙🌟',
              ),
              _buildTipItem(
                context,
                Icons.refresh_outlined,
                'Tái tạo năng lượng cho tâm hồn',
                'Giảm căng thẳng, tăng cường tinh thần và tạo niềm vui.🌿🌟',
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
    final Color mainColor = const Color.fromARGB(255, 252, 120, 128);

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
              color: mainColor,
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
              color: mainColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: mainColor),
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
                        initialColor: mainColor,
                        reminderEnabledByDefault: true,
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
                color: mainColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: mainColor),
            ),
          ),
        ],
      ),
    );
  }
}
