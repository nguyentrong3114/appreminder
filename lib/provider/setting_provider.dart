import 'package:flutter/material.dart';
import 'package:flutter_app/services/setting_service.dart';

class TimeFormatProvider extends ChangeNotifier {
  final SettingsService settingsService;
  bool _use24HourFormat;

  TimeFormatProvider(this.settingsService)
      : _use24HourFormat = settingsService.use24HourFormat;

  bool get use24HourFormat => _use24HourFormat;

  Future<void> setUse24HourFormat(bool value) async {
    _use24HourFormat = value;
    await settingsService.setUse24HourFormat(value);
    notifyListeners();
  }
}