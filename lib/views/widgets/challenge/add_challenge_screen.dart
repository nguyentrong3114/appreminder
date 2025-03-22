import 'package:flutter/material.dart';
import 'package:flutter_app/views/widgets/challenge/add_onetime_task.dart';
import 'package:flutter_app/views/widgets/challenge/be_active_screen.dart';
import 'package:flutter_app/views/widgets/challenge/be_weird_screen.dart';
import 'package:flutter_app/views/widgets/challenge/connect_screen.dart';
import 'package:flutter_app/views/widgets/challenge/self_improvement_screen.dart';
import 'package:flutter_app/views/widgets/challenge/self_relaxation_screen.dart';
import 'add_regular_habit_screen.dart';
import 'healthy_eating_screen.dart';
import 'challenge_screen.dart';
import 'package:intl/intl.dart';

class AddChallengeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TẠO',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tạo riêng cho bạn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),

            // Thói quen thường xuyên
            OptionTile(
              icon: Icons.calendar_today,
              title: 'Thói quen thường xuyên',
              onTap: () {
                // Lấy ngày đã chọn từ ChallengeScreen
                DateTime selectedDate = ChallengeScreen.selectedDate;
                String formattedDate = DateFormat(
                  'MMMM d, yyyy',
                  'vi_VN',
                ).format(selectedDate);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => RegularHabitScreen(
                          initialStartDate: selectedDate,
                          formattedStartDate: formattedDate,
                        ),
                  ),
                );
              },
            ),

            SizedBox(height: 16),

            // Nhiệm vụ một lần
            // Trong OptionTile cho "Thử thách một lần"
            OptionTile(
              icon: Icons.calendar_today,
              title: 'Thử thách một lần',
              onTap: () {
                // Lấy ngày đã chọn từ ChallengeScreen
                DateTime selectedDate = ChallengeScreen.selectedDate;
                String formattedDate = DateFormat(
                  'MMMM d, yyyy',
                  'vi_VN',
                ).format(selectedDate);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => OnetimeTask(
                          initialStartDate: selectedDate,
                          formattedStartDate: formattedDate,
                        ),
                  ),
                );
              },
            ),

            SizedBox(height: 32),

            Text(
              'Hoặc chọn từ những danh mục này',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),

            // Grid danh mục
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
                children: [
                  CategoryCard(
                    imagePath: 'assets/images/cat_fish.png',
                    title: 'Ăn ngon \nsống khỏe',
                    color: Colors.orange.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthyEatingScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_relaxation.png',
                    title: 'Chill một chút nha',
                    color: Colors.teal.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelfRelaxationScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_active.png',
                    title: 'Vận động kiểu của tớ',
                    color: Colors.pink.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BeActiveScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_heart.png',
                    title: 'Lập dị một chút, chất riêng một tí',
                    color: Colors.purple.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BeWeirdScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_connect.png',
                    title: 'Gắn kết yêu thương',
                    color: const Color.fromARGB(255, 110, 228, 241),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectScreen(),
                        ),
                      );
                    },
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_selfimprovement.png',
                    title: 'Hoàn thiện bản thân',
                    color: const Color.fromARGB(255, 252, 120, 128),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelfImprovementScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cho mục chọn thói quen/nhiệm vụ
class OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// Widget cho thẻ danh mục
class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.imagePath,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap with GestureDetector
      onTap: onTap,
      child: Container(
        height: 220,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 130,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                title,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
