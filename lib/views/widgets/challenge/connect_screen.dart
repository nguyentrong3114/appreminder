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
      home: const ConnectScreen(),
    );
  }
}

class ConnectScreen extends StatelessWidget {
  final DateTime? selectedDate;
  const ConnectScreen({super.key, this.selectedDate});
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
            color: Color.fromARGB(255, 110, 228, 241),
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
                  color: const Color.fromARGB(255, 110, 228, 241),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gắn kết yêu thương',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Nó có thể giảm căng thẳng, giúp ta sống lâu hơn và giảm nguy cơ cô đơn hay trầm cảm. 🌿😊',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/cat_connect.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTipItem(
                context,
                Icons.family_restroom_outlined,
                'Trò chuyện với gia đình',
                'Trò chuyện với gia đình giúp tăng cường tình cảm, giảm căng thẳng và tạo niềm vui.👨‍👩‍👧‍👦👨‍👩‍👧‍👦',
              ),
              _buildTipItem(
                context,
                Icons.people_outline,
                'Kết nối lại với bạn cũ',
                'Kết nối lại với bạn cũ giúp tăng cường tình bạn, giảm căng thẳng và tạo niềm vui.👫👫',
              ),
              _buildTipItem(
                context,
                Icons.phone_outlined,
                'Gọi điện thoại',
                'Gọi điện thoại cho người thân giúp tăng cường tình cảm, giảm căng thẳng và tạo niềm vui.📞📞',
              ),
              _buildTipItem(
                context,
                Icons.pets_outlined,
                'Cứu trợ động vật',
                'Cứu trợ động vật giúp tăng cường tình cảm, giảm căng thẳng và tạo niềm vui.🐶🐱',
              ),
              _buildTipItem(
                context,
                Icons.airplane_ticket_outlined,
                'Đi du lịch',
                'Du lịch giúp bạn khám phá thế giới, tăng cường kiến thức và giảm căng thẳng.🌍🌍',
              ),
              _buildTipItem(
                context,
                Icons.people_alt_outlined,
                'Tham gia vào một cộng đồng',
                'Tham gia vào một cộng đồng giúp tăng cường tình bạn, giảm căng thẳng và tạo niềm vui.👨‍👩‍👧‍👦👨‍👩‍👧‍👦',
              ),
              _buildTipItem(
                context,
                Icons.favorite_border_outlined,
                'Trao đi sự ấm áp',
                'Trao đi sự ấm áp giúp tăng cường tình cảm, giảm căng thẳng và tạo niềm vui.📚📚',
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
    final Color mainColor = const Color.fromARGB(255, 110, 228, 241);

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
