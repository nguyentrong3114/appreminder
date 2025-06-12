import 'app.dart';
import 'firebase_options.dart';
import 'services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'services/setting_service.dart';
import 'provider/setting_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // <-- Thêm dòng này
import 'package:flutter_app/services/notification_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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
      child: MyApp(navigatorKey: rootNavigatorKey),
    ),
  );

  // Lắng nghe dynamic link để kích hoạt VIP
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData data) async {
    final Uri? deepLink = data.link;
    if (deepLink != null && deepLink.path == '/vip') {
      final userId = deepLink.queryParameters['userId'];
      if (userId != null && userId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'isVip': true});
        // Đóng dialog nếu đang mở
        if (rootNavigatorKey.currentState?.canPop() ?? false) {
          rootNavigatorKey.currentState?.pop();
        }
        // Hiển thị SnackBar
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kích hoạt VIP thành công')),
          );
        }
      }
    }
  });
}
