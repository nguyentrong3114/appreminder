import 'app.dart';
import 'firebase_options.dart';
import 'services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'services/setting_service.dart';
import 'provider/setting_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // <-- Thêm dòng này
import 'package:flutter_app/services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  await AlarmService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingProvider(settingsService),
      child: const MyApp(),
    ),
  );
}
