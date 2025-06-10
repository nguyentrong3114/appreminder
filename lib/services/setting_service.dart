import 'package:shared_preferences/shared_preferences.dart';


// Thêm vào services/settings_service.dart

class SettingsService {
  static const _keyUse24HourFormat = 'use24HourFormat';
  static const _keyStartWeekOn = 'startWeekOn';
  static const _keyDateFormat = 'dateFormat';
  static const _keyFontFamily = 'fontFamily';
  static const _keyAlarmSound = 'alarmSound';
  static const _keyNotificationSound = 'notificationSound';

  final SharedPreferences prefs;

  SettingsService(this.prefs);

  bool get use24HourFormat => prefs.getBool(_keyUse24HourFormat) ?? true;

  Future<void> setUse24HourFormat(bool value) async {
    await prefs.setBool(_keyUse24HourFormat, value);
  }

  int get startWeekOn => prefs.getInt(_keyStartWeekOn) ?? 0; // Mặc định Thứ 2

  Future<void> setStartWeekOn(int value) async {
    await prefs.setInt(_keyStartWeekOn, value);
  }

  String get dateFormat => prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy';

  Future<void> setDateFormat(String value) async {
    await prefs.setString(_keyDateFormat, value);
  }

  String get fontFamily => prefs.getString(_keyFontFamily) ?? 'Roboto';

  Future<void> setFontFamily(String value) async {
    await prefs.setString(_keyFontFamily, value);
  }

  String get alarmSound => prefs.getString(_keyAlarmSound) ?? 'alarm1';

  Future<void> setAlarmSound(String value) async => await prefs.setString(_keyAlarmSound, value);

  String get notificationSound => prefs.getString(_keyNotificationSound) ?? 'noti1';

  Future<void> setNotificationSound(String value) async => await prefs.setString(_keyNotificationSound, value);
}


