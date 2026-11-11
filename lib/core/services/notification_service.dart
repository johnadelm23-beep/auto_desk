import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationService {
  Future<void> initialize();

  tz.Location get localLocation;

  Future<bool> requestNotificationPermission();

  Future<bool> isNotificationPermissionGranted();

  Future<bool> canScheduleExactAlarms();

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<List<int>> getActiveScheduledNotificationIds();

  Future<List<PendingNotificationRequest>> getPendingNotificationRequests();
}

