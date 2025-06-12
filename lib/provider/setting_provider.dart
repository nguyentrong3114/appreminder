import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/services/setting_service.dart';

class SettingProvider extends ChangeNotifier {
  final SettingsService settingsService;
  bool _use24HourFormat;
  int _startWeekOn;
  String _dateFormat;
  String _fontFamily;
  String _notificationSound;
  String _alarmSound;
  bool _isVip = false;

  SettingProvider(this.settingsService)
    : _use24HourFormat = settingsService.use24HourFormat,
      _startWeekOn = settingsService.startWeekOn,
      _dateFormat = settingsService.dateFormat,
      _fontFamily = settingsService.fontFamily,
      _notificationSound = settingsService.notificationSound,
      _alarmSound = settingsService.alarmSound,
      _isVip = settingsService.isVip;

  bool get use24HourFormat => _use24HourFormat;
  int get startWeekOn => _startWeekOn;
  String get dateFormat => _dateFormat;
  String get fontFamily => _fontFamily.isNotEmpty ? _fontFamily : 'Roboto';
  String get notificationSound => _notificationSound;
  String get alarmSound => _alarmSound;
  bool get isVip => _isVip;

  Future<void> setUse24HourFormat(bool value) async {
    _use24HourFormat = value;
    await settingsService.setUse24HourFormat(value);
    notifyListeners();
  }

  Future<void> setStartWeekOn(int value) async {
    _startWeekOn = value;
    await settingsService.setStartWeekOn(value);
    notifyListeners();
  }

  Future<void> setDateFormat(String value) async {
    _dateFormat = value;
    await settingsService.setDateFormat(value);
    notifyListeners();
  }

  Future<void> setFontFamily(String value) async {
    _fontFamily = value;
    await settingsService.setFontFamily(value);
    notifyListeners();
  }

  Future<void> setNotificationSound(String value) async {
    _notificationSound = value;
    await settingsService.setNotificationSound(value);
    notifyListeners();
  }

  Future<void> setAlarmSound(String value) async {
    _alarmSound = value;
    await settingsService.setAlarmSound(value);
    notifyListeners();
  }

  Future<void> setVip(bool value) async {
    _isVip = value;
    await settingsService.setVip(value);
    notifyListeners();
  }

  Future<void> syncVipStatusFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isVipRemote = doc.data()?['isVip'] == true;
      await setVip(isVipRemote);
    }
  }
}