// import 'package:flutter/material.dart';

// class EventDetailScreen extends StatelessWidget {
//   final String title;
//   final String time;

//   EventDetailScreen({required this.title, required this.time});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chi tiết sự kiện")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Thời gian: $time", style: TextStyle(fontSize: 18)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Chỉnh sửa sự kiện
//               },
//               child: Text("Chỉnh sửa"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // Xóa sự kiện
//               },
//               child: Text("Xóa", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
