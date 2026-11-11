import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../../features/cars/data/models/car_model.dart';
import '../../features/settings/domain/repositories/notification_settings_repository.dart';
import 'notification_localization_helper.dart';
import 'notification_service.dart';

class VehicleReminderScheduler {
  final NotificationService notificationService;
  final NotificationSettingsRepository settingsRepository;

  VehicleReminderScheduler({
    required this.notificationService,
    required this.settingsRepository,
  });

  /// Computes a stable, unique 32-bit ID for the delivery notification of a vehicle.
  static int deliveryNotificationId(int carId) => carId * 10;

  /// Computes a stable, unique 32-bit ID for the advance reminder of a vehicle.
  static int advanceNotificationId(int carId) => (carId * 10) + 1;

  /// Special ID for immediate test notification.
  static const int testNotificationId = 999999;

  /// Special ID for scheduled 10-second diagnostic notification.
  static const int testScheduledNotificationId = 999998;

  /// Schedules or updates reminders for a vehicle based on current settings and vehicle status.
  /// Each vehicle is scheduled independently based on its own estimatedTimeOut.
  Future<void> scheduleVehicleReminders(
    CarModel car, [
    String? languageCode,
  ]) async {
    final deliveryId = deliveryNotificationId(car.id);
    final advanceId = advanceNotificationId(car.id);

    // If vehicle is delivered, all reminders for this vehicle must be cancelled
    if (car.status == 'delivered') {
      await notificationService.cancelNotification(deliveryId);
      await notificationService.cancelNotification(advanceId);
      debugPrint(
        '[AutoDesk VehicleScheduler] Vehicle is delivered (id: ${car.id}). Cancelled reminders.',
      );
      return;
    }

    final settings = await settingsRepository.getSettings();

    // If notifications are globally disabled, cancel reminders
    if (!settings.notificationsEnabled) {
      await notificationService.cancelNotification(deliveryId);
      await notificationService.cancelNotification(advanceId);
      debugPrint(
        '[AutoDesk VehicleScheduler] Notifications disabled in settings. Cancelled reminders for vehicle ${car.id}.',
      );
      return;
    }

    // Ensure notification permission is requested if not already granted
    final hasPermission =
        await notificationService.isNotificationPermissionGranted();
    if (!hasPermission) {
      await notificationService.requestNotificationPermission();
    }

    final now = DateTime.now();
    final timeZoneName = now.timeZoneName;
    final timeZoneOffset = now.timeZoneOffset;
    final calculatedLocalTime = car.estimatedTimeOut.toLocal();
    final isFuture = car.estimatedTimeOut.isAfter(now);
    final canExact = await notificationService.canScheduleExactAlarms();
    final scheduleMode = canExact ? 'exactAllowWhileIdle' : 'inexactAllowWhileIdle';

    String deliveryResult = 'not attempted (past time)';
    bool attempted = false;

    // 1. Delivery Time Reminder (at car.estimatedTimeOut)
    if (isFuture) {
      attempted = true;
      final title = _resolveDeliveryTitle(languageCode);
      final body = _resolveDeliveryBody(
        vin: car.vin,
        customer: car.customerName,
        languageCode: languageCode,
      );

      try {
        await notificationService.scheduleNotification(
          id: deliveryId,
          title: title,
          body: body,
          scheduledDate: car.estimatedTimeOut,
          payload: 'car_details:${car.id}',
        );
        deliveryResult = 'SUCCESS scheduled delivery alarm';
      } catch (e, stack) {
        deliveryResult = 'EXCEPTION: $e\n$stack';
      }
    } else {
      // Past delivery time - cancel any pending
      await notificationService.cancelNotification(deliveryId);
      deliveryResult = 'CANCELLED (timeout in past: ${car.estimatedTimeOut} <= now: $now)';
    }

    // 2. Advance Reminder (at car.estimatedTimeOut - advanceMinutes)
    if (settings.advanceReminderEnabled) {
      final advanceDate = car.estimatedTimeOut.subtract(
        Duration(minutes: settings.advanceReminderMinutes),
      );

      if (advanceDate.isAfter(now)) {
        final title = _resolveAdvanceTitle(
          minutes: settings.advanceReminderMinutes,
          languageCode: languageCode,
        );
        final body = _resolveAdvanceBody(
          vin: car.vin,
          customer: car.customerName,
          minutes: settings.advanceReminderMinutes,
          languageCode: languageCode,
        );

        try {
          await notificationService.scheduleNotification(
            id: advanceId,
            title: title,
            body: body,
            scheduledDate: advanceDate,
            payload: 'car_details:${car.id}',
          );
        } catch (_) {}
      } else {
        // Advance time has passed
        await notificationService.cancelNotification(advanceId);
      }
    } else {
      // Advance reminder disabled in settings - cancel advance reminder only
      await notificationService.cancelNotification(advanceId);
    }

    // Fetch pending notification requests to verify registration
    final pendingRequests =
        await notificationService.getPendingNotificationRequests();
    final pendingIds = pendingRequests.map((r) => r.id).toList();

    debugPrint(
      '[AutoDesk VehicleScheduler] Diagnostic Log for Vehicle:\n'
      '  - Vehicle ID: ${car.id}\n'
      '  - VIN: ${car.vin}\n'
      '  - Customer name: ${car.customerName}\n'
      '  - Status: ${car.status}\n'
      '  - estimatedTimeOut: ${car.estimatedTimeOut} (isUtc: ${car.estimatedTimeOut.isUtc})\n'
      '  - DateTime.now(): $now\n'
      '  - Timezone name: $timeZoneName\n'
      '  - UTC offset: $timeZoneOffset\n'
      '  - Calculated local time: $calculatedLocalTime\n'
      '  - Notification ID: $deliveryId\n'
      '  - isFuture: $isFuture\n'
      '  - attempted: $attempted\n'
      '  - schedule mode: $scheduleMode\n'
      '  - result/exception: $deliveryResult\n'
      '  - getPendingNotificationRequests(): $pendingIds\n',
    );
  }

  /// Cancels both delivery and advance reminders for a single vehicle.
  Future<void> cancelVehicleReminders(int carId) async {
    await notificationService.cancelNotification(deliveryNotificationId(carId));
    await notificationService.cancelNotification(advanceNotificationId(carId));
  }

  /// Reschedules reminders for all active vehicles independently based on their own timeouts.
  Future<void> rescheduleAllActiveVehicles(
    List<CarModel> activeCars, [
    String? languageCode,
  ]) async {
    if (languageCode != null) {
      NotificationLocalizationHelper.setLanguage(languageCode);
    }

    final settings = await settingsRepository.getSettings();

    if (!settings.notificationsEnabled) {
      await notificationService.cancelAllNotifications();
      return;
    }

    for (final car in activeCars) {
      await scheduleVehicleReminders(car, languageCode);
    }
  }

  /// Reconciles scheduled reminders with database active vehicles on app startup.
  /// Removes obsolete notifications and schedules missing ones per vehicle.
  Future<void> reconcileReminders({
    required List<CarModel> activeCars,
    String? languageCode,
  }) async {
    if (languageCode != null) {
      NotificationLocalizationHelper.setLanguage(languageCode);
    }

    final settings = await settingsRepository.getSettings();

    if (!settings.notificationsEnabled) {
      await notificationService.cancelAllNotifications();
      return;
    }

    final now = DateTime.now();
    final expectedIds = <int>{};

    for (final car in activeCars) {
      if (car.status == 'delivered') continue;

      if (car.estimatedTimeOut.isAfter(now)) {
        expectedIds.add(deliveryNotificationId(car.id));
      }

      if (settings.advanceReminderEnabled) {
        final advanceDate = car.estimatedTimeOut.subtract(
          Duration(minutes: settings.advanceReminderMinutes),
        );
        if (advanceDate.isAfter(now)) {
          expectedIds.add(advanceNotificationId(car.id));
        }
      }
    }

    // Cancel obsolete notifications that are not expected
    final scheduledIds =
        await notificationService.getActiveScheduledNotificationIds();
    for (final id in scheduledIds) {
      if (id != testNotificationId &&
          id != testScheduledNotificationId &&
          !expectedIds.contains(id)) {
        await notificationService.cancelNotification(id);
      }
    }

    // Re-schedule all valid active cars with their own timeout values
    for (final car in activeCars) {
      await scheduleVehicleReminders(car, languageCode);
    }
  }

  /// Sends an immediate test notification to verify setup.
  Future<void> sendTestNotification([String? languageCode]) async {
    final title = _resolveTestTitle(languageCode);
    final body = _resolveTestBody(languageCode);

    await notificationService.showNotification(
      id: testNotificationId,
      title: title,
      body: body,
    );
  }

  /// Schedules a diagnostic test notification 10 seconds into the future.
  Future<void> scheduleTestNotification10s([String? languageCode]) async {
    final scheduledDate = DateTime.now().add(const Duration(seconds: 10));
    final title = _resolveTestTitle(languageCode);
    final body = languageCode?.startsWith('ar') == true
        ? 'إشعار مجدول تجريبي تم إطلاقه بعد 10 ثوانٍ بنجاح.'
        : 'Diagnostic test notification delivered after 10 seconds.';

    await notificationService.scheduleNotification(
      id: testScheduledNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: 'diagnostic_test_10s',
    );
  }

  String _resolveDeliveryTitle(String? languageCode) {
    try {
      final t = 'delivery_reminder_title'.tr();
      if (t.isNotEmpty && t != 'delivery_reminder_title') return t;
    } catch (_) {}
    return NotificationLocalizationHelper.deliveryTitle(languageCode);
  }

  String _resolveDeliveryBody({
    required String vin,
    required String customer,
    String? languageCode,
  }) {
    try {
      final b = 'delivery_reminder_body'.tr(namedArgs: {
        'vin': vin,
        'customer': customer,
      });
      if (b.isNotEmpty && b != 'delivery_reminder_body') return b;
    } catch (_) {}
    return NotificationLocalizationHelper.deliveryBody(
      vin: vin,
      customer: customer,
      languageCode: languageCode,
    );
  }

  String _resolveAdvanceTitle({
    required int minutes,
    String? languageCode,
  }) {
    try {
      final t = 'advance_reminder_title'.tr(namedArgs: {
        'minutes': '$minutes',
      });
      if (t.isNotEmpty && t != 'advance_reminder_title') return t;
    } catch (_) {}
    return NotificationLocalizationHelper.advanceTitle(
      minutes: minutes,
      languageCode: languageCode,
    );
  }

  String _resolveAdvanceBody({
    required String vin,
    required String customer,
    required int minutes,
    String? languageCode,
  }) {
    try {
      final b = 'advance_reminder_body'.tr(namedArgs: {
        'vin': vin,
        'customer': customer,
        'minutes': '$minutes',
      });
      if (b.isNotEmpty && b != 'advance_reminder_body') return b;
    } catch (_) {}
    return NotificationLocalizationHelper.advanceBody(
      vin: vin,
      customer: customer,
      minutes: minutes,
      languageCode: languageCode,
    );
  }

  String _resolveTestTitle(String? languageCode) {
    try {
      final t = 'test_notification_title'.tr();
      if (t.isNotEmpty && t != 'test_notification_title') return t;
    } catch (_) {}
    return NotificationLocalizationHelper.testTitle(languageCode);
  }

  String _resolveTestBody(String? languageCode) {
    try {
      final b = 'test_notification_body'.tr();
      if (b.isNotEmpty && b != 'test_notification_body') return b;
    } catch (_) {}
    return NotificationLocalizationHelper.testBody(languageCode);
  }
}
