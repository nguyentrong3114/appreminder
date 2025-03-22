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
      home: const SelfRelaxationScreen(),
    );
  }
}

class SelfRelaxationScreen extends StatelessWidget {
  final DateTime? selectedDate;

  const SelfRelaxationScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal.shade200),
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
                  color: Colors.teal.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Chill một chút nha',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tự thưởng cho mình đi, bạn xứng đáng mà.😊🐱',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/cat_relaxation.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTipItem(
                context,
                Icons.mediation_outlined,
                'Thư giãn tâm trí và cơ thể',
                'Giảm lo âu, xua tan muộn phiền, ngủ ngon hơn và tăng cường sức khỏe.😊🧘‍♂️',
              ),
              _buildTipItem(
                context,
                Icons.bedtime_outlined,
                'Ngủ đủ giấc',
                'Giảm căng thẳng, tâm trạng tươi vui.😊💤',
              ),
              _buildTipItem(
                context,
                Icons.music_note_outlined,
                'Nghe nhạc',
                'Giúp giảm căng thẳng và tăng cường trí não.🎶🎵',
              ),
              _buildTipItem(
                context,
                Icons.emoji_emotions_outlined,
                'Cười nhiều hơn',
                'Cười giúp giảm căng thẳng, tăng cường hệ miễn dịch và giảm đau.😊🤣',
              ),
              _buildTipItem(
                context,
                Icons.people_outlined,
                'Tám chuyện với bạn bè',
                'Giúp giảm căng thẳng, tăng cảm giác hạnh phúc và giảm cảm giác cô đơn.😊👭',
              ),
              _buildTipItem(
                context,
                Icons.nightlight_round_outlined,
                'Ngủ sớm hơn',
                'Giúp cơ thể nghỉ ngơi và phục hồi sau một ngày làm việc mệt mỏi.😊🌙',
              ),
              _buildTipItem(
                context,
                Icons.book_outlined,
                'Đọc sách',
                'Giúp giảm căng thẳng, tăng cường trí não và giúp bạn ngủ ngon hơn.📚📖',
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
    final Color mainColor = Colors.teal.shade200;

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
              color: Colors.teal.withOpacity(0.2),
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
                        initialStartDate:
                            ChallengeScreen.selectedDate, // Thêm dòng này
                        formattedStartDate: DateFormat(
                          'MMMM d, yyyy',
                          'vi_VN',
                        ).format(ChallengeScreen.selectedDate), // Thêm dòng này
                      ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
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
