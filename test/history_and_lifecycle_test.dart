import 'dart:io';

import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/core/services/car_photo_storage_service.dart';
import 'package:auto_desk/core/utils/duration_formatter.dart';
import 'package:auto_desk/features/cars/data/models/car_model.dart';
import 'package:auto_desk/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:auto_desk/features/history/data/repositories/history_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;
  late CarPhotoStorageService storageService;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('autodesk_history_lifecycle_test_');
    dbFile = File('${tempDir.path}/test_db.sqlite');
    storageService = CarPhotoStorageService(baseDirectoryProvider: () async => tempDir);
  });

  tearDown(() {
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  AppDatabase openDb() => AppDatabase.forTesting(NativeDatabase(dbFile));

  group('DurationFormatter tests', () {
    test('formats minutes, hours, days correctly', () {
      final base = DateTime(2026, 1, 1, 10, 0);

      // Same time or invalid
      expect(DurationFormatter.format(base, base), equals('1m'));
      expect(DurationFormatter.format(base, base.subtract(const Duration(minutes: 5))), equals('0m'));

      // Minutes
      expect(
        DurationFormatter.format(base, base.add(const Duration(minutes: 35))),
        equals('35m'),
      );

      // Hours only
      expect(
        DurationFormatter.format(base, base.add(const Duration(hours: 4))),
        equals('4h'),
      );

      // Hours and minutes
      expect(
        DurationFormatter.format(base, base.add(const Duration(hours: 3, minutes: 25))),
        equals('3h 25m'),
      );

      // Days only
      expect(
        DurationFormatter.format(base, base.add(const Duration(days: 3))),
        equals('3d'),
      );

      // Days and hours
      expect(
        DurationFormatter.format(base, base.add(const Duration(days: 2, hours: 6))),
        equals('2d 6h'),
      );
    });
  });

  group('Vehicle Delivery Lifecycle', () {
    test('transitioning status to delivered automatically sets actualTimeOut', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );

      final carId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_LIFECYCLE_01',
          customerName: 'Alice Johnson',
          timeIn: DateTime.now().subtract(const Duration(days: 2)),
          estimatedTimeOut: DateTime.now().add(const Duration(days: 1)),
          complaint: 'Brake pads replacement',
          estimatedCost: 250.0,
          status: 'in_progress',
          notes: 'Customer requested inspection',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );

      var car = await carsRepo.getCarById(carId);
      expect(car, isNotNull);
      expect(car!.status, equals('in_progress'));
      expect(car.actualTimeOut, isNull);

      final beforeDelivery = DateTime.now().subtract(const Duration(seconds: 1));
      // Transition to delivered
      final updated = await carsRepo.updateCarStatus(carId, 'delivered');
      expect(updated, isTrue);

      final deliveredCar = await carsRepo.getCarById(carId);
      expect(deliveredCar, isNotNull);
      expect(deliveredCar!.status, equals('delivered'));
      expect(deliveredCar.actualTimeOut, isNotNull);
      expect(deliveredCar.actualTimeOut!.isAfter(beforeDelivery), isTrue);

      // Preserve all other fields
      expect(deliveredCar.vin, equals('VIN_LIFECYCLE_01'));
      expect(deliveredCar.customerName, equals('Alice Johnson'));
      expect(deliveredCar.complaint, equals('Brake pads replacement'));
      expect(deliveredCar.estimatedCost, equals(250.0));
      expect(deliveredCar.notes, equals('Customer requested inspection'));

      await db.close();
    });

    test('ordinary edit of delivered vehicle preserves existing actualTimeOut', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );

      final originalActualTime = DateTime(2026, 1, 10, 14, 30);
      final carId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_PRESERVE_DELIVERY',
          customerName: 'Bob Smith',
          timeIn: DateTime(2026, 1, 8, 9, 0),
          estimatedTimeOut: DateTime(2026, 1, 10, 12, 0),
          actualTimeOut: originalActualTime,
          complaint: 'Oil change and filter',
          estimatedCost: 120.0,
          status: 'delivered',
          notes: 'Completed',
          createdAt: DateTime(2026, 1, 8, 9, 0),
        ),
      );

      var car = await carsRepo.getCarById(carId);
      expect(car!.actualTimeOut, equals(originalActualTime));

      // Ordinary edit: update notes and cost, without explicit actualTimeOut
      final updatedCar = CarModel(
        id: carId,
        vin: car.vin,
        customerName: 'Bob Smith - Updated',
        timeIn: car.timeIn,
        estimatedTimeOut: car.estimatedTimeOut,
        actualTimeOut: null, // Ordinary edit form doesn't provide actualTimeOut
        complaint: car.complaint,
        estimatedCost: 150.0,
        status: 'delivered',
        notes: 'Notes updated after delivery',
        createdAt: car.createdAt,
      );

      await carsRepo.updateCar(updatedCar);

      final reloaded = await carsRepo.getCarById(carId);
      expect(reloaded!.status, equals('delivered'));
      expect(reloaded.customerName, equals('Bob Smith - Updated'));
      expect(reloaded.estimatedCost, equals(150.0));
      expect(reloaded.notes, equals('Notes updated after delivery'));
      // actualTimeOut must be preserved, not overwritten with now
      expect(reloaded.actualTimeOut, equals(originalActualTime));

      await db.close();
    });

    test('changing delivered car back to active clears actualTimeOut', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );

      final carId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_REOPEN_CAR',
          customerName: 'Charlie Brown',
          timeIn: DateTime(2026, 1, 5, 8, 0),
          estimatedTimeOut: DateTime(2026, 1, 7, 18, 0),
          actualTimeOut: DateTime(2026, 1, 7, 16, 0),
          complaint: 'Suspension squeak',
          estimatedCost: 350.0,
          status: 'delivered',
          notes: 'Customer picked up',
          createdAt: DateTime(2026, 1, 5, 8, 0),
        ),
      );

      // Reopen car to ready or in_progress
      final changed = await carsRepo.updateCarStatus(carId, 'ready');
      expect(changed, isTrue);

      final reopenedCar = await carsRepo.getCarById(carId);
      expect(reopenedCar!.status, equals('ready'));
      expect(reopenedCar.actualTimeOut, isNull);

      // Active cars list should include reopened car
      final activeCars = await carsRepo.getActiveCars();
      expect(activeCars.any((c) => c.id == carId), isTrue);

      await db.close();
    });
  });

  group('Delivered vehicles vs Active & Overdue exclusion', () {
    test('delivered cars are excluded from active, overdue, and upcoming queries', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );

      final now = DateTime.now();

      // Car 1: Delivered (estimated time was in the past)
      await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_DELIVERED_PAST',
          customerName: 'Delivered Person',
          timeIn: now.subtract(const Duration(days: 5)),
          estimatedTimeOut: now.subtract(const Duration(days: 2)), // past!
          actualTimeOut: now.subtract(const Duration(days: 2)),
          complaint: 'Past job',
          status: 'delivered',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      );

      // Car 2: Active overdue
      final overdueCarId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_ACTIVE_OVERDUE',
          customerName: 'Late Person',
          timeIn: now.subtract(const Duration(days: 3)),
          estimatedTimeOut: now.subtract(const Duration(hours: 4)), // past!
          complaint: 'Ongoing overdue job',
          status: 'in_progress',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      );

      // Car 3: Active upcoming
      final upcomingCarId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_ACTIVE_UPCOMING',
          customerName: 'Soon Person',
          timeIn: now.subtract(const Duration(hours: 2)),
          estimatedTimeOut: now.add(const Duration(hours: 10)), // next 24h
          complaint: 'Due soon',
          status: 'received',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      );

      // 1. Check active cars: must NOT contain the delivered car
      final active = await carsRepo.getActiveCars();
      final activeVins = active.map((c) => c.vin).toList();
      expect(activeVins, contains('VIN_ACTIVE_OVERDUE'));
      expect(activeVins, contains('VIN_ACTIVE_UPCOMING'));
      expect(activeVins, isNot(contains('VIN_DELIVERED_PAST')));

      // 2. Check overdue query in DAO: must NOT contain delivered car
      final overdue = await db.carsDao.getOverdueCars(now: now);
      expect(overdue.map((c) => c.id), contains(overdueCarId));
      expect(overdue.any((c) => c.vin == 'VIN_DELIVERED_PAST'), isFalse);

      // 3. Check upcoming query in DAO: must NOT contain delivered car
      final upcoming = await db.carsDao.getUpcomingDeliveries(now: now);
      expect(upcoming.map((c) => c.id), contains(upcomingCarId));
      expect(upcoming.any((c) => c.vin == 'VIN_DELIVERED_PAST'), isFalse);

      // 4. Check statistics
      final stats = await db.carsDao.getDashboardStatistics(now: now);
      expect(stats.totalCars, equals(3));
      expect(stats.delivered, equals(1));
      expect(stats.overdue, equals(1));
      expect(stats.upcomingDeliveries, equals(1));

      await db.close();
    });
  });

  group('History Repository queries: Search, Date Filter, and Sorting', () {
    test('getDeliveredCars filters and sorts correctly', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );
      final historyRepo = HistoryRepositoryImpl(db.carsDao);

      final date1 = DateTime(2026, 1, 10, 10, 0);
      final date2 = DateTime(2026, 1, 15, 14, 0);
      final date3 = DateTime(2026, 1, 20, 16, 0);

      // Car 1
      await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'WBA1234567890DEL1',
          customerName: 'David Miller',
          timeIn: DateTime(2026, 1, 8),
          estimatedTimeOut: DateTime(2026, 1, 10),
          actualTimeOut: date1,
          complaint: 'Oil change',
          status: 'delivered',
          createdAt: DateTime(2026, 1, 8),
        ),
      );

      // Car 2
      await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VF1987654321DEL2',
          customerName: 'Sarah Connor',
          timeIn: DateTime(2026, 1, 12),
          estimatedTimeOut: DateTime(2026, 1, 15),
          actualTimeOut: date2,
          complaint: 'Alternator fix',
          status: 'delivered',
          createdAt: DateTime(2026, 1, 12),
        ),
      );

      // Car 3
      await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'WAUZZZ445566DEL3',
          customerName: 'David Lee',
          timeIn: DateTime(2026, 1, 18),
          estimatedTimeOut: DateTime(2026, 1, 20),
          actualTimeOut: date3,
          complaint: 'Timing belt',
          status: 'delivered',
          createdAt: DateTime(2026, 1, 18),
        ),
      );

      // Active car that should NEVER show in history
      await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'ACTIVE_CAR_NOT_HISTORY',
          customerName: 'David Active',
          timeIn: DateTime(2026, 1, 22),
          estimatedTimeOut: DateTime(2026, 1, 25),
          complaint: 'Ongoing work',
          status: 'in_progress',
          createdAt: DateTime(2026, 1, 22),
        ),
      );

      // 1. All delivered cars, default sorting (newest first: Car 3, then Car 2, then Car 1)
      final allDelivered = await historyRepo.getDeliveredCars();
      expect(allDelivered.length, equals(3));
      expect(allDelivered[0].vin, equals('WAUZZZ445566DEL3'));
      expect(allDelivered[1].vin, equals('VF1987654321DEL2'));
      expect(allDelivered[2].vin, equals('WBA1234567890DEL1'));

      // 2. Ascending sorting (oldest first: Car 1, Car 2, Car 3)
      final oldestFirst = await historyRepo.getDeliveredCars(ascending: true);
      expect(oldestFirst.length, equals(3));
      expect(oldestFirst[0].vin, equals('WBA1234567890DEL1'));
      expect(oldestFirst[1].vin, equals('VF1987654321DEL2'));
      expect(oldestFirst[2].vin, equals('WAUZZZ445566DEL3'));

      // 3. Search by VIN substring
      final searchVin = await historyRepo.getDeliveredCars(searchQuery: 'VF1987');
      expect(searchVin.length, equals(1));
      expect(searchVin.first.customerName, equals('Sarah Connor'));

      // 4. Search by Customer Name
      final searchCustomer = await historyRepo.getDeliveredCars(searchQuery: 'David');
      expect(searchCustomer.length, equals(2));
      expect(searchCustomer.map((c) => c.vin), containsAll(['WBA1234567890DEL1', 'WAUZZZ445566DEL3']));
      expect(searchCustomer.any((c) => c.vin == 'ACTIVE_CAR_NOT_HISTORY'), isFalse);

      // 5. Date filtering (between Jan 12 and Jan 16: only Car 2)
      final dateFiltered = await historyRepo.getDeliveredCars(
        startDate: DateTime(2026, 1, 12),
        endDate: DateTime(2026, 1, 16),
      );
      expect(dateFiltered.length, equals(1));
      expect(dateFiltered.first.vin, equals('VF1987654321DEL2'));

      await db.close();
    });

    test('watchDeliveredCars and watchActiveCars streams update reactively upon status change', () async {
      final db = openDb();
      final carsRepo = CarsRepositoryImpl(
        carsDao: db.carsDao,
        carPhotosDao: db.carPhotosDao,
        photoStorageService: storageService,
      );
      final historyRepo = HistoryRepositoryImpl(db.carsDao);

      final carId = await carsRepo.addCar(
        CarModel(
          id: 0,
          vin: 'VIN_REACTIVE_007',
          customerName: 'James Bond',
          timeIn: DateTime.now().subtract(const Duration(days: 1)),
          estimatedTimeOut: DateTime.now().add(const Duration(hours: 3)),
          complaint: 'Ejector seat repair',
          status: 'ready',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      // Initially active
      var activeList = await carsRepo.watchActiveCars().first;
      var deliveredList = await historyRepo.watchDeliveredCars().first;
      expect(activeList.any((c) => c.id == carId), isTrue);
      expect(deliveredList.any((c) => c.id == carId), isFalse);

      // Change status to delivered
      await carsRepo.updateCarStatus(carId, 'delivered');

      activeList = await carsRepo.watchActiveCars().first;
      deliveredList = await historyRepo.watchDeliveredCars().first;
      expect(activeList.any((c) => c.id == carId), isFalse);
      expect(deliveredList.any((c) => c.id == carId), isTrue);

      // Change back to active (in_progress)
      await carsRepo.updateCarStatus(carId, 'in_progress');

      activeList = await carsRepo.watchActiveCars().first;
      deliveredList = await historyRepo.watchDeliveredCars().first;
      expect(activeList.any((c) => c.id == carId), isTrue);
      expect(deliveredList.any((c) => c.id == carId), isFalse);

      await db.close();
    });
  });
}
