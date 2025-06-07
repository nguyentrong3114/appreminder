import 'package:shared_preferences/shared_preferences.dart';


// Thêm vào services/settings_service.dart

class SettingsService {
  static const _keyUse24HourFormat = 'use24HourFormat';

  final SharedPreferences prefs;

  SettingsService(this.prefs);

  bool get use24HourFormat => prefs.getBool(_keyUse24HourFormat) ?? true;

  Future<void> setUse24HourFormat(bool value) async {
    await prefs.setBool(_keyUse24HourFormat, value);
  }
}


