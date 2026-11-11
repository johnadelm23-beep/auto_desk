import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/core/services/car_photo_storage_service.dart';
import 'package:auto_desk/core/services/notification_localization_helper.dart';
import 'package:auto_desk/core/services/notification_service.dart';
import 'package:auto_desk/core/services/vehicle_reminder_scheduler.dart';
import 'package:auto_desk/features/cars/data/models/car_model.dart';
import 'package:auto_desk/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:auto_desk/features/settings/data/models/notification_settings_model.dart';
import 'package:auto_desk/features/settings/domain/repositories/notification_settings_repository.dart';
import 'package:auto_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:auto_desk/features/settings/presentation/cubit/settings_state.dart';
import 'package:auto_desk/features/settings/presentation/screens/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

/// In-memory mock of NotificationService for unit and integration testing.
class FakeNotificationService implements NotificationService {
  final Map<int, ScheduledNotification> scheduled = {};
  final List<ShownNotification> shown = [];
  bool permissionGranted = true;
  bool exactAlarmsAllowed = true;

  @override
  tz.Location get localLocation => tz.UTC;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestNotificationPermission() async => permissionGranted;

  @override
  Future<bool> isNotificationPermissionGranted() async => permissionGranted;

  @override
  Future<bool> canScheduleExactAlarms() async => exactAlarmsAllowed;

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Mimics real behavior: past timestamps are ignored
    if (!scheduledDate.isAfter(DateTime.now())) {
      return;
    }
    scheduled[id] = ScheduledNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    shown.add(
      ShownNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduled.clear();
  }

  @override
  Future<List<int>> getActiveScheduledNotificationIds() async {
    return scheduled.keys.toList();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return scheduled.entries
        .map(
          (e) => PendingNotificationRequest(
            e.key,
            e.value.title,
            e.value.body,
            e.value.payload,
          ),
        )
        .toList();
  }
}

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String? payload;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.payload,
  });
}

class ShownNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;

  ShownNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });
}

/// In-memory mock of NotificationSettingsRepository.
class FakeNotificationSettingsRepository
    implements NotificationSettingsRepository {
  NotificationSettingsModel currentSettings;
  final StreamController<NotificationSettingsModel> _controller =
      StreamController<NotificationSettingsModel>.broadcast();

  FakeNotificationSettingsRepository({
    NotificationSettingsModel? initialSettings,
  }) : currentSettings = initialSettings ?? const NotificationSettingsModel();

  @override
  Future<NotificationSettingsModel> getSettings() async => currentSettings;

  @override
  Future<void> saveSettings(NotificationSettingsModel settings) async {
    currentSettings = settings;
    _controller.add(settings);
  }

  @override
  Stream<NotificationSettingsModel> watchSettings() async* {
    yield currentSettings;
    yield* _controller.stream;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];

  late Directory tempDir;
  late File dbFile;
  late CarPhotoStorageService storageService;
  late FakeNotificationService fakeNotifications;
  late FakeNotificationSettingsRepository fakeSettingsRepo;
  late VehicleReminderScheduler scheduler;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('autodesk_notif_test_');
    dbFile = File('${tempDir.path}/test_db.sqlite');
    storageService =
        CarPhotoStorageService(baseDirectoryProvider: () async => tempDir);
    fakeNotifications = FakeNotificationService();
    fakeSettingsRepo = FakeNotificationSettingsRepository();
    scheduler = VehicleReminderScheduler(
      notificationService: fakeNotifications,
      settingsRepository: fakeSettingsRepo,
    );
  });

  tearDown(() {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  AppDatabase openDb() => AppDatabase.forTesting(NativeDatabase(dbFile));

  CarsRepositoryImpl createRepo(AppDatabase db) => CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
        reminderScheduler: scheduler,
      );

  group('Independent Per-Vehicle Scheduling (Product Requirements)', () {
    test('two vehicles with different timeout values receive different scheduled notification times', () async {
      final db = openDb();
      final repo = createRepo(db);

      final timeoutA = DateTime.now().add(const Duration(hours: 2));
      final timeoutB = DateTime.now().add(const Duration(hours: 5));

      final carAId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_VEHICLE_A',
          customerName: 'Customer A',
          timeIn: DateTime.now().subtract(const Duration(hours: 1)),
          estimatedTimeOut: timeoutA,
          complaint: 'Service A',
          status: 'in_progress',
          createdAt: DateTime.now(),
        ),
      );

      final carBId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_VEHICLE_B',
          customerName: 'Customer B',
          timeIn: DateTime.now().subtract(const Duration(hours: 1)),
          estimatedTimeOut: timeoutB,
          complaint: 'Service B',
          status: 'ready',
          createdAt: DateTime.now(),
        ),
      );

      // Verify IDs are distinct
      final deliveryIdA = VehicleReminderScheduler.deliveryNotificationId(carAId);
      final deliveryIdB = VehicleReminderScheduler.deliveryNotificationId(carBId);
      expect(deliveryIdA, isNot(equals(deliveryIdB)));

      // Verify each vehicle receives its own delivery notification at its own estimatedTimeOut
      final notifA = fakeNotifications.scheduled[deliveryIdA]!;
      final notifB = fakeNotifications.scheduled[deliveryIdB]!;
      expect(notifA.scheduledDate, equals(timeoutA));
      expect(notifB.scheduledDate, equals(timeoutB));
      expect(notifA.scheduledDate, isNot(equals(notifB.scheduledDate)));

      await db.close();
    });

    test('editing one vehicle timeout does not change another vehicle schedule', () async {
      final db = openDb();
      final repo = createRepo(db);

      final initialTimeoutA = DateTime.now().add(const Duration(hours: 2));
      final initialTimeoutB = DateTime.now().add(const Duration(hours: 5));

      final carAId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_EDIT_A',
          customerName: 'Customer A',
          timeIn: DateTime.now(),
          estimatedTimeOut: initialTimeoutA,
          complaint: 'Job A',
          status: 'in_progress',
          createdAt: DateTime.now(),
        ),
      );

      final carBId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_EDIT_B',
          customerName: 'Customer B',
          timeIn: DateTime.now(),
          estimatedTimeOut: initialTimeoutB,
          complaint: 'Job B',
          status: 'received',
          createdAt: DateTime.now(),
        ),
      );

      final deliveryIdA = VehicleReminderScheduler.deliveryNotificationId(carAId);
      final deliveryIdB = VehicleReminderScheduler.deliveryNotificationId(carBId);

      // Edit only Vehicle A
      final newTimeoutA = DateTime.now().add(const Duration(hours: 8));
      final carA = await repo.getCarById(carAId);
      final updatedCarA = CarModel(
        id: carA!.id,
        vin: carA.vin,
        customerName: carA.customerName,
        timeIn: carA.timeIn,
        estimatedTimeOut: newTimeoutA,
        complaint: carA.complaint,
        status: carA.status,
        createdAt: carA.createdAt,
      );

      await repo.updateCar(updatedCarA);

      // Vehicle A's notification was rescheduled to newTimeoutA
      expect(fakeNotifications.scheduled[deliveryIdA]!.scheduledDate, equals(newTimeoutA));

      // Vehicle B's notification remained untouched at initialTimeoutB
      expect(fakeNotifications.scheduled[deliveryIdB]!.scheduledDate, equals(initialTimeoutB));

      await db.close();
    });

    test('advance reminders are calculated independently for each vehicle', () async {
      final db = openDb();
      final repo = createRepo(db);

      final timeoutA = DateTime.now().add(const Duration(hours: 3));
      final timeoutB = DateTime.now().add(const Duration(hours: 6));

      final carAId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_ADV_A',
          customerName: 'Customer A',
          timeIn: DateTime.now(),
          estimatedTimeOut: timeoutA,
          complaint: 'A',
          status: 'in_progress',
          createdAt: DateTime.now(),
        ),
      );

      final carBId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_ADV_B',
          customerName: 'Customer B',
          timeIn: DateTime.now(),
          estimatedTimeOut: timeoutB,
          complaint: 'B',
          status: 'in_progress',
          createdAt: DateTime.now(),
        ),
      );

      final advanceIdA = VehicleReminderScheduler.advanceNotificationId(carAId);
      final advanceIdB = VehicleReminderScheduler.advanceNotificationId(carBId);

      // Default: 30 minutes before each vehicle's own timeout
      expect(fakeNotifications.scheduled[advanceIdA]!.scheduledDate,
          equals(timeoutA.subtract(const Duration(minutes: 30))));
      expect(fakeNotifications.scheduled[advanceIdB]!.scheduledDate,
          equals(timeoutB.subtract(const Duration(minutes: 30))));

      await db.close();
    });

    test('disabling advance reminders preserves main timeout notifications', () async {
      final db = openDb();
      final repo = createRepo(db);

      final timeout = DateTime.now().add(const Duration(hours: 4)).copyWith(millisecond: 0, microsecond: 0);
      final carId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_PRESERVE_MAIN',
          customerName: 'Customer',
          timeIn: DateTime.now(),
          estimatedTimeOut: timeout,
          complaint: 'Test',
          status: 'ready',
          createdAt: DateTime.now(),
        ),
      );

      final deliveryId = VehicleReminderScheduler.deliveryNotificationId(carId);
      final advanceId = VehicleReminderScheduler.advanceNotificationId(carId);

      expect(fakeNotifications.scheduled.containsKey(deliveryId), isTrue);
      expect(fakeNotifications.scheduled.containsKey(advanceId), isTrue);

      // Disable advance reminders only
      await fakeSettingsRepo.saveSettings(
        const NotificationSettingsModel(
          notificationsEnabled: true,
          advanceReminderEnabled: false,
        ),
      );

      final activeCars = await repo.getActiveCars();
      await scheduler.rescheduleAllActiveVehicles(activeCars);

      // Main timeout notification is preserved
      expect(fakeNotifications.scheduled.containsKey(deliveryId), isTrue);
      expect(
        fakeNotifications.scheduled[deliveryId]!.scheduledDate.millisecondsSinceEpoch ~/ 1000,
        equals(timeout.millisecondsSinceEpoch ~/ 1000),
      );

      // Advance reminder is cancelled
      expect(fakeNotifications.scheduled.containsKey(advanceId), isFalse);

      await db.close();
    });
  });

  group('Localization Keys & Translation Verification', () {
    test('all required keys exist in en.json and ar.json', () {
      final enContent = File('assets/translations/en.json').readAsStringSync();
      final arContent = File('assets/translations/ar.json').readAsStringSync();

      final enJson = jsonDecode(enContent) as Map<String, dynamic>;
      final arJson = jsonDecode(arContent) as Map<String, dynamic>;

      const requiredKeys = [
        'delivery_reminder_title',
        'delivery_reminder_body',
        'advance_reminder_title',
        'advance_reminder_body',
        'view_all',
      ];

      for (final key in requiredKeys) {
        expect(enJson.containsKey(key), isTrue, reason: '$key missing in en.json');
        expect(arJson.containsKey(key), isTrue, reason: '$key missing in ar.json');
        expect(enJson[key], isNotEmpty);
        expect(arJson[key], isNotEmpty);
      }
    });

    test('notification messages are translated in English and Arabic with VIN and customer name', () {
      // English
      final enTitle = NotificationLocalizationHelper.deliveryTitle('en');
      final enBody = NotificationLocalizationHelper.deliveryBody(
        vin: 'VIN12345678',
        customer: 'John Doe',
        languageCode: 'en',
      );
      final enAdvTitle = NotificationLocalizationHelper.advanceTitle(
        minutes: 15,
        languageCode: 'en',
      );
      final enAdvBody = NotificationLocalizationHelper.advanceBody(
        vin: 'VIN12345678',
        customer: 'John Doe',
        minutes: 15,
        languageCode: 'en',
      );

      expect(enTitle, equals('Delivery Reminder'));
      expect(enBody, equals('Vehicle VIN12345678 for John Doe is due for delivery now.'));
      expect(enAdvTitle, equals('Upcoming Delivery (15m)'));
      expect(enAdvBody, equals('Vehicle VIN12345678 for John Doe is scheduled for delivery in 15 minutes.'));

      // Arabic
      final arTitle = NotificationLocalizationHelper.deliveryTitle('ar');
      final arBody = NotificationLocalizationHelper.deliveryBody(
        vin: 'VIN12345678',
        customer: 'John Doe',
        languageCode: 'ar',
      );
      final arAdvTitle = NotificationLocalizationHelper.advanceTitle(
        minutes: 30,
        languageCode: 'ar',
      );
      final arAdvBody = NotificationLocalizationHelper.advanceBody(
        vin: 'VIN12345678',
        customer: 'John Doe',
        minutes: 30,
        languageCode: 'ar',
      );

      expect(arTitle, equals('تذكير بموعد التسليم'));
      expect(arBody, equals('السيارة VIN12345678 الخاصة بالعميل John Doe موعد تسليمها الآن.'));
      expect(arAdvTitle, equals('تذكير بقرب موعد التسليم (30 د)'));
      expect(arAdvBody, equals('السيارة VIN12345678 للعميل John Doe موعد تسليمها بعد 30 دقيقة.'));
    });
  });

  group('VehicleReminderScheduler unit tests', () {
    test('computes unique, stable IDs for different vehicles and reminder types', () {
      expect(VehicleReminderScheduler.deliveryNotificationId(1), equals(10));
      expect(VehicleReminderScheduler.advanceNotificationId(1), equals(11));

      expect(VehicleReminderScheduler.deliveryNotificationId(2), equals(20));
      expect(VehicleReminderScheduler.advanceNotificationId(2), equals(21));

      expect(VehicleReminderScheduler.deliveryNotificationId(105), equals(1050));
      expect(VehicleReminderScheduler.advanceNotificationId(105), equals(1051));

      expect(VehicleReminderScheduler.testNotificationId, equals(999999));
    });

    test('does not schedule delivery or advance reminders for past timestamps', () async {
      final pastDelivery = DateTime.now().subtract(const Duration(hours: 1));
      final car = CarModel(
        id: 8,
        vin: 'VIN_PAST_CAR',
        customerName: 'John Doe',
        timeIn: DateTime.now().subtract(const Duration(days: 1)),
        estimatedTimeOut: pastDelivery,
        complaint: 'Past job',
        status: 'received',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await scheduler.scheduleVehicleReminders(car);

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(8)), isFalse);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(8)), isFalse);
    });

    test('cancels reminders if vehicle is already delivered', () async {
      final carId = 9;
      fakeNotifications.scheduled[VehicleReminderScheduler.deliveryNotificationId(carId)] =
          ScheduledNotification(
        id: VehicleReminderScheduler.deliveryNotificationId(carId),
        title: 'Due',
        body: 'Body',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );

      final car = CarModel(
        id: carId,
        vin: 'VIN_ALREADY_DELIVERED',
        customerName: 'Delivered Person',
        timeIn: DateTime.now().subtract(const Duration(days: 1)),
        estimatedTimeOut: DateTime.now().add(const Duration(hours: 1)),
        actualTimeOut: DateTime.now(),
        complaint: 'Done',
        status: 'delivered',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await scheduler.scheduleVehicleReminders(car);

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isFalse);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(carId)), isFalse);
    });

    test('cancels all reminders when notifications are globally disabled', () async {
      await fakeSettingsRepo.saveSettings(
        const NotificationSettingsModel(notificationsEnabled: false),
      );

      final car = CarModel(
        id: 12,
        vin: 'VIN_DISABLED_NOTIF',
        customerName: 'Customer',
        timeIn: DateTime.now(),
        estimatedTimeOut: DateTime.now().add(const Duration(hours: 3)),
        complaint: 'Checkup',
        status: 'in_progress',
        createdAt: DateTime.now(),
      );

      await scheduler.scheduleVehicleReminders(car);

      expect(fakeNotifications.scheduled.isEmpty, isTrue);
    });

    test('respects advance reminder settings (15 minutes vs 30 minutes vs disabled)', () async {
      await fakeSettingsRepo.saveSettings(
        const NotificationSettingsModel(
          notificationsEnabled: true,
          advanceReminderEnabled: true,
          advanceReminderMinutes: 15,
        ),
      );

      final deliveryTime = DateTime.now().add(const Duration(hours: 1));
      final car = CarModel(
        id: 15,
        vin: 'VIN_15M',
        customerName: 'Fifteen Minute Customer',
        timeIn: DateTime.now(),
        estimatedTimeOut: deliveryTime,
        complaint: 'Test 15m',
        status: 'received',
        createdAt: DateTime.now(),
      );

      await scheduler.scheduleVehicleReminders(car);
      final advance15 = fakeNotifications.scheduled[VehicleReminderScheduler.advanceNotificationId(15)]!;
      expect(advance15.scheduledDate, equals(deliveryTime.subtract(const Duration(minutes: 15))));

      await fakeSettingsRepo.saveSettings(
        const NotificationSettingsModel(
          notificationsEnabled: true,
          advanceReminderEnabled: false,
        ),
      );

      await scheduler.scheduleVehicleReminders(car);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(15)), isTrue);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(15)), isFalse);
    });

    test('repeated scheduling does not create duplicate notifications', () async {
      final deliveryTime = DateTime.now().add(const Duration(hours: 2));
      final car = CarModel(
        id: 20,
        vin: 'VIN_REPEAT',
        customerName: 'Repeat Customer',
        timeIn: DateTime.now(),
        estimatedTimeOut: deliveryTime,
        complaint: 'Repeat check',
        status: 'ready',
        createdAt: DateTime.now(),
      );

      await scheduler.scheduleVehicleReminders(car);
      await scheduler.scheduleVehicleReminders(car);
      await scheduler.scheduleVehicleReminders(car);

      expect(fakeNotifications.scheduled.length, equals(2));
    });
  });

  group('CarsRepository Lifecycle & Notification Synchronization', () {
    test('adding car automatically schedules reminders', () async {
      final db = openDb();
      final repo = createRepo(db);

      final deliveryTime = DateTime.now().add(const Duration(hours: 3));
      final carId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_AUTO_ADD',
          customerName: 'Bruce Wayne',
          timeIn: DateTime.now(),
          estimatedTimeOut: deliveryTime,
          complaint: 'Batmobile maintenance',
          status: 'in_progress',
          createdAt: DateTime.now(),
        ),
      );

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isTrue);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(carId)), isTrue);

      await db.close();
    });

    test('transitioning status to delivered cancels all reminders', () async {
      final db = openDb();
      final repo = createRepo(db);

      final deliveryTime = DateTime.now().add(const Duration(hours: 3));
      final carId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_DELIVER_CANCEL',
          customerName: 'Diana Prince',
          timeIn: DateTime.now(),
          estimatedTimeOut: deliveryTime,
          complaint: 'Shield repair',
          status: 'ready',
          createdAt: DateTime.now(),
        ),
      );

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isTrue);

      await repo.updateCarStatus(carId, 'delivered');

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isFalse);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(carId)), isFalse);

      await db.close();
    });

    test('reopening delivered vehicle reschedules reminders', () async {
      final db = openDb();
      final repo = createRepo(db);

      final futureDelivery = DateTime.now().add(const Duration(hours: 4));
      final carId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_REOPEN_SCHEDULE',
          customerName: 'Barry Allen',
          timeIn: DateTime.now().subtract(const Duration(days: 1)),
          estimatedTimeOut: futureDelivery,
          actualTimeOut: DateTime.now(),
          complaint: 'Treadwear',
          status: 'delivered',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isFalse);

      await repo.updateCarStatus(carId, 'in_progress');

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isTrue);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(carId)), isTrue);

      await db.close();
    });

    test('deleting car cancels all its reminders', () async {
      final db = openDb();
      final repo = createRepo(db);

      final deliveryTime = DateTime.now().add(const Duration(hours: 3));
      final carId = await repo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_DELETE_CANCEL',
          customerName: 'Arthur Curry',
          timeIn: DateTime.now(),
          estimatedTimeOut: deliveryTime,
          complaint: 'Submarine inspection',
          status: 'received',
          createdAt: DateTime.now(),
        ),
      );

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isTrue);

      await repo.deleteCar(carId);

      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.deliveryNotificationId(carId)), isFalse);
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.advanceNotificationId(carId)), isFalse);

      await db.close();
    });
  });

  group('Startup Reconciliation & Recovery', () {
    test('reconcileReminders cleans up obsolete reminders and schedules missing ones', () async {
      final now = DateTime.now();

      fakeNotifications.scheduled[10] = ScheduledNotification(
        id: 10,
        title: 'Car 1 Due',
        body: 'Body',
        scheduledDate: now.add(const Duration(hours: 1)),
      );
      fakeNotifications.scheduled[20] = ScheduledNotification(
        id: 20,
        title: 'Car 2 Due',
        body: 'Body',
        scheduledDate: now.add(const Duration(hours: 2)),
      );
      fakeNotifications.scheduled[30] = ScheduledNotification(
        id: 30,
        title: 'Car 3 Due',
        body: 'Body',
        scheduledDate: now.add(const Duration(hours: 3)),
      );

      final activeCars = [
        CarModel(
          id: 2,
          vin: 'VIN_ACTIVE_2',
          customerName: 'Active Two',
          timeIn: now,
          estimatedTimeOut: now.add(const Duration(hours: 2)),
          complaint: 'Tuneup',
          status: 'in_progress',
          createdAt: now,
        ),
        CarModel(
          id: 4,
          vin: 'VIN_ACTIVE_4',
          customerName: 'Active Four',
          timeIn: now,
          estimatedTimeOut: now.add(const Duration(hours: 4)),
          complaint: 'Inspection',
          status: 'ready',
          createdAt: now,
        ),
      ];

      await scheduler.reconcileReminders(activeCars: activeCars);

      expect(fakeNotifications.scheduled.containsKey(10), isFalse);
      expect(fakeNotifications.scheduled.containsKey(30), isFalse);
      expect(fakeNotifications.scheduled.containsKey(20), isTrue);
      expect(fakeNotifications.scheduled.containsKey(21), isTrue);
      expect(fakeNotifications.scheduled.containsKey(40), isTrue);
      expect(fakeNotifications.scheduled.containsKey(41), isTrue);
    });
  });

  group('SettingsCubit and Test Notification', () {
    test('loads settings and toggles settings reactively', () async {
      final db = openDb();
      final repo = createRepo(db);

      final cubit = SettingsCubit(
        settingsRepository: fakeSettingsRepo,
        notificationService: fakeNotifications,
        reminderScheduler: scheduler,
        carsRepository: repo,
      );

      await cubit.loadSettings();
      expect(cubit.state.status, equals(SettingsStatus.success));
      expect(cubit.state.settings.notificationsEnabled, isTrue);
      expect(cubit.state.settings.advanceReminderMinutes, equals(30));

      await cubit.setAdvanceReminderMinutes(15);
      expect(cubit.state.settings.advanceReminderMinutes, equals(15));
      expect(fakeSettingsRepo.currentSettings.advanceReminderMinutes, equals(15));

      await cubit.toggleAdvanceReminder(false);
      expect(cubit.state.settings.advanceReminderEnabled, isFalse);

      await cubit.sendTestNotification('en');
      expect(fakeNotifications.shown.length, equals(1));
      expect(fakeNotifications.shown.first.id, equals(VehicleReminderScheduler.testNotificationId));

      await cubit.scheduleTestNotification10s('en');
      expect(fakeNotifications.scheduled.containsKey(VehicleReminderScheduler.testScheduledNotificationId), isTrue);
      expect(cubit.state.pendingNotificationIds, contains(VehicleReminderScheduler.testScheduledNotificationId));

      await cubit.close();
      await db.close();
    });
  });

  group('SettingsScreen Widget & Rendering Tests', () {
    testWidgets('Settings screen does not overflow on narrow screens and has no ListTile background assertions',
        (tester) async {
      // Narrow mobile screen: 300px width
      tester.view.physicalSize = const Size(300, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = openDb();
      final repo = createRepo(db);
      final cubit = SettingsCubit(
        settingsRepository: fakeSettingsRepo,
        notificationService: fakeNotifications,
        reminderScheduler: scheduler,
        carsRepository: repo,
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: SettingsScreen(cubit: cubit),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);

      // Verify tapping ListTiles / Switches works with zero ink splash / background assertions
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      await tester.ensureVisible(switches.first);
      await tester.tap(switches.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Zero assertions
      expect(tester.takeException(), isNull);

      await cubit.close();
      await db.close();
    });
  });
}
