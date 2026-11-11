import '../../data/models/notification_settings_model.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettingsModel> getSettings();

  Future<void> saveSettings(NotificationSettingsModel settings);

  Stream<NotificationSettingsModel> watchSettings();
}

