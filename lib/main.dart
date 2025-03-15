import 'views/home_screen.dart';
import 'views/add_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter được khởi tạo đúng
  await initializeDateFormatting('vi_VN', null); // Khởi tạo locale tiếng Việt

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    routes: {
      '/add_event': (context) => AddEventScreen(),
    },
  ));
}
