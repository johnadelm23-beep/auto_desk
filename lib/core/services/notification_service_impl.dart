import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  tz.Location? _location;
  bool _isInitialized = false;

  static const String channelId = 'auto_desk_delivery_channel';
  static const String channelName = 'Vehicle Delivery Reminders';
  static const String channelDescription =
      'Notifications for vehicle scheduled delivery times and advance reminders';

  NotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  tz.Location get localLocation {
    if (_location == null) {
      tz_data.initializeTimeZones();
      _location = tz.local;
    }
    return _location!;
  }

  NotificationDetails get _notificationDetails {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize timezone database and detect local location
    tz_data.initializeTimeZones();
    _location = await _detectLocalLocation();
    tz.setLocalLocation(_location!);

    // 2. Platform initialization settings
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Notification tap handling
      },
    );

    // 3. Create high-importance notification channel for Android
    if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Prompt for runtime notification permission on Android 13+ (API 33+)
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<tz.Location> _detectLocalLocation() async {
    // 1. Try native platform timezone identifier via flutter_timezone
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final id = timezoneInfo.identifier;
      if (tz.timeZoneDatabase.locations.containsKey(id)) {
        return tz.getLocation(id);
      }
    } catch (_) {}

    // 2. Try DateTime.now().timeZoneName
    try {
      final name = DateTime.now().timeZoneName;
      if (tz.timeZoneDatabase.locations.containsKey(name)) {
        return tz.getLocation(name);
      }
    } catch (_) {}

    // 3. Match based on UTC offset (Taskora pattern)
    try {
      final offset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == offset) {
          return loc;
        }
      }
    } catch (_) {}

    return tz.local;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final enabled =
          await androidImplementation?.areNotificationsEnabled();
      return enabled ?? false;
    }
    return true;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final canSchedule =
          await androidImplementation?.canScheduleExactNotifications();
      return canSchedule ?? true;
    }
    return true;
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final location = localLocation;
    final nowTz = tz.TZDateTime.now(location);
    final scheduledTz = tz.TZDateTime.from(scheduledDate.toLocal(), location);

    debugPrint(
      '[AutoDesk NotificationService] scheduleNotification called:\n'
      '  - ID: $id\n'
      '  - title: $title\n'
      '  - scheduledDate: $scheduledDate (isUtc: ${scheduledDate.isUtc})\n'
      '  - scheduledDate.toLocal(): ${scheduledDate.toLocal()}\n'
      '  - Location: ${location.name}\n'
      '  - nowTz: $nowTz\n'
      '  - scheduledTz: $scheduledTz\n'
      '  - isAfter: ${scheduledTz.isAfter(nowTz)}\n',
    );

    // Never schedule notifications for past times
    if (!scheduledTz.isAfter(nowTz)) {
      debugPrint('[AutoDesk NotificationService] SKIPPED: scheduledTz is not after nowTz.');
      return;
    }

    try {
      // First attempt exact schedule (preferred for delivery reminders)
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTz,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('[AutoDesk NotificationService] exactAllowWhileIdle succeeded for ID: $id');
    } catch (e) {
      debugPrint('[AutoDesk NotificationService] exact schedule failed ($e), falling back to inexactAllowWhileIdle');
      // Graceful fallback to inexact scheduling if exact alarm permission is missing/restricted
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTz,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('[AutoDesk NotificationService] inexactAllowWhileIdle succeeded for ID: $id');
    }
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _plugin.cancelAll();
  }

  @override
  Future<List<int>> getActiveScheduledNotificationIds() async {
    if (!_isInitialized) {
      await initialize();
    }
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((r) => r.id).toList();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _plugin.pendingNotificationRequests();
  }
}
