import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/notification_settings_repository.dart';
import '../models/notification_settings_model.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  static const String _keyNotificationsEnabled =
      'autodesk_notifications_enabled';
  static const String _keyAdvanceEnabled =
      'autodesk_advance_reminder_enabled';
  static const String _keyAdvanceMinutes =
      'autodesk_advance_reminder_minutes';

  final SharedPreferencesAsync? _sharedPrefs;
  final StreamController<NotificationSettingsModel> _controller =
      StreamController<NotificationSettingsModel>.broadcast();

  NotificationSettingsRepositoryImpl({SharedPreferencesAsync? sharedPreferences})
      : _sharedPrefs = sharedPreferences;

  SharedPreferencesAsync get _prefs => _sharedPrefs ?? SharedPreferencesAsync();

  @override
  Future<NotificationSettingsModel> getSettings() async {
    final enabled = await _prefs.getBool(_keyNotificationsEnabled) ?? true;
    final advanceEnabled = await _prefs.getBool(_keyAdvanceEnabled) ?? true;
    final advanceMinutes = await _prefs.getInt(_keyAdvanceMinutes) ?? 30;

    return NotificationSettingsModel(
      notificationsEnabled: enabled,
      advanceReminderEnabled: advanceEnabled,
      advanceReminderMinutes: advanceMinutes,
    );
  }

  @override
  Future<void> saveSettings(NotificationSettingsModel settings) async {
    await _prefs.setBool(_keyNotificationsEnabled, settings.notificationsEnabled);
    await _prefs.setBool(
        _keyAdvanceEnabled, settings.advanceReminderEnabled);
    await _prefs.setInt(_keyAdvanceMinutes, settings.advanceReminderMinutes);

    _controller.add(settings);
  }

  @override
  Stream<NotificationSettingsModel> watchSettings() async* {
    yield await getSettings();
    yield* _controller.stream;
  }
}

