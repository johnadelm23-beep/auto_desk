import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'core/services/vehicle_reminder_scheduler.dart';
import 'features/cars/domain/repositories/cars_repository.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Timezone initialization
  tz_data.initializeTimeZones();
  try {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  } catch (_) {
    // Fallback to default timezone if platform channel is unavailable
  }

  // 2. Localization & Dependency Injection
  await EasyLocalization.ensureInitialized();
  await initDependencies();

  // 3. Notification Service initialization & startup reconciliation
  try {
    final notificationService = sl<NotificationService>();
    await notificationService.initialize();

    final reminderScheduler = sl<VehicleReminderScheduler>();
    final carsRepo = sl<CarsRepository>();
    final activeCars = await carsRepo.getActiveCars();
    await reminderScheduler.reconcileReminders(activeCars: activeCars);
  } catch (_) {
    // Safe startup fallback if running on unsupported platform or tests
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AutoDeskApp(),
    ),
  );
}
