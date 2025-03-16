import 'package:flutter/material.dart';
import 'add_regular_habit_screen.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegularHabitScreen()),
                );
              },
            ),

            SizedBox(height: 16),

            // Nhiệm vụ một lần
            OptionTile(
              icon: Icons.event_available,
              title: 'Nhiệm vụ một lần',
              onTap: () {},
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
                    title: 'Eat \nhealthy',
                    color: Colors.orange.shade200,
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_relaxation.png',
                    title: 'Self Relaxation',
                    color: Colors.teal.shade200,
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_active.png',
                    title: 'Be active \nmy way',
                    color: Colors.pink.shade200,
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_heart.png',
                    title: 'Be weird. \nBe you',
                    color: Colors.purple.shade200,
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_connect.png',
                    title: 'Connet \n with others',
                    color: const Color.fromARGB(255, 110, 228, 241),
                  ),
                  CategoryCard(
                    imagePath: 'assets/images/cat_selfimprovement.png',
                    title: 'Self \nimprovement',
                    color: const Color.fromARGB(255, 252, 120, 128),
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

  const CategoryCard({
    required this.imagePath,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
