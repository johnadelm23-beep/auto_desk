import 'dart:io';

import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/core/services/car_photo_storage_service.dart';
import 'package:auto_desk/features/cars/data/models/car_model.dart';
import 'package:auto_desk/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:auto_desk/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late CarPhotoStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auto_desk_dashboard_test_');
    storageService = CarPhotoStorageService(
      baseDirectoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Empty dashboard state returns all zero stats and empty lists', () async {
    final dbFile = File('${tempDir.path}/empty_dashboard_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final dashboardRepo = DashboardRepositoryImpl(db.carsDao);

    final dashboardData = await dashboardRepo.getDashboardData();

    expect(dashboardData.stats.totalCars, equals(0));
    expect(dashboardData.stats.receivedToday, equals(0));
    expect(dashboardData.stats.inProgress, equals(0));
    expect(dashboardData.stats.ready, equals(0));
    expect(dashboardData.stats.delivered, equals(0));
    expect(dashboardData.stats.overdue, equals(0));
    expect(dashboardData.stats.upcomingDeliveries, equals(0));
    expect(dashboardData.overdueCars, isEmpty);
    expect(dashboardData.upcomingCars, isEmpty);
    expect(dashboardData.recentCars, isEmpty);

    await db.close();
  });

  test(
      'Statistics: total, received today, in progress, ready, delivered, overdue, upcoming',
      () async {
    final dbFile = File('${tempDir.path}/dashboard_stats_calc_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final carsRepo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );
    final dashboardRepo = DashboardRepositoryImpl(db.carsDao);

    // Controlled reference time: Tuesday, Nov 10, 2026 at 14:00
    final testNow = DateTime(2026, 11, 10, 14, 0);

    // 1. Car received today, in progress, due in 2 days
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_TODAY_PROGRESS',
        customerName: 'Customer 1',
        timeIn: DateTime(2026, 11, 10, 9, 30), // Today
        estimatedTimeOut: DateTime(2026, 11, 12, 16, 0), // Future (> 24h)
        complaint: 'Engine oil',
        status: 'in_progress',
        createdAt: DateTime(2026, 11, 10, 9, 30),
      ),
    );

    // 2. Car received today, ready, due in 5 hours (Upcoming delivery within 24h)
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_TODAY_READY_UPCOMING',
        customerName: 'Customer 2',
        timeIn: DateTime(2026, 11, 10, 11, 0), // Today
        estimatedTimeOut: DateTime(2026, 11, 10, 19, 0), // Upcoming (5 hours from 14:00)
        complaint: 'Brake pads',
        status: 'ready',
        createdAt: DateTime(2026, 11, 10, 11, 0),
      ),
    );

    // 3. Car received yesterday, delivered
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_DELIVERED',
        customerName: 'Customer 3',
        timeIn: DateTime(2026, 11, 9, 10, 0), // Yesterday
        estimatedTimeOut: DateTime(2026, 11, 9, 18, 0),
        actualTimeOut: DateTime(2026, 11, 9, 17, 30),
        complaint: 'Tire rotation',
        status: 'delivered',
        createdAt: DateTime(2026, 11, 9, 10, 0),
      ),
    );

    // 4. Car received 2 days ago, in progress, due yesterday (Overdue!)
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_OVERDUE',
        customerName: 'Customer 4',
        timeIn: DateTime(2026, 11, 8, 10, 0),
        estimatedTimeOut: DateTime(2026, 11, 9, 12, 0), // Overdue relative to Nov 10, 14:00
        complaint: 'Transmission issue',
        status: 'in_progress',
        createdAt: DateTime(2026, 11, 8, 10, 0),
      ),
    );

    final data = await dashboardRepo.getDashboardData(now: testNow);
    final stats = data.stats;

    expect(stats.totalCars, equals(4));
    expect(stats.receivedToday, equals(2)); // Car 1 and Car 2
    expect(stats.inProgress, equals(2)); // Car 1 and Car 4
    expect(stats.ready, equals(1)); // Car 2
    expect(stats.delivered, equals(1)); // Car 3
    expect(stats.overdue, equals(1)); // Car 4
    expect(stats.upcomingDeliveries, equals(1)); // Car 2

    expect(data.overdueCars.length, equals(1));
    expect(data.overdueCars.first.vin, equals('VIN_OVERDUE'));

    expect(data.upcomingCars.length, equals(1));
    expect(data.upcomingCars.first.vin, equals('VIN_TODAY_READY_UPCOMING'));

    await db.close();
  });

  test(
      'Delivered vehicles are strictly excluded from overdue and upcoming delivery counts',
      () async {
    final dbFile = File('${tempDir.path}/delivered_exclusion_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final carsRepo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );
    final dashboardRepo = DashboardRepositoryImpl(db.carsDao);

    final testNow = DateTime(2026, 11, 10, 14, 0);

    // Car delivered in the past whose estimated time out is in the past
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_DELIVERED_PAST_DUE',
        customerName: 'Delivered Past Due',
        timeIn: DateTime(2026, 11, 8, 8, 0),
        estimatedTimeOut: DateTime(2026, 11, 9, 12, 0), // Earlier than testNow
        status: 'delivered',
        complaint: 'Routine service',
        createdAt: DateTime(2026, 11, 8, 8, 0),
      ),
    );

    // Car delivered whose estimated time out is in the upcoming 24 hours
    await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'VIN_DELIVERED_UPCOMING_DUE',
        customerName: 'Delivered Upcoming Due',
        timeIn: DateTime(2026, 11, 10, 8, 0),
        estimatedTimeOut: DateTime(2026, 11, 10, 18, 0), // Within 24h
        status: 'delivered',
        complaint: 'Inspection',
        createdAt: DateTime(2026, 11, 10, 8, 0),
      ),
    );

    final data = await dashboardRepo.getDashboardData(now: testNow);
    final stats = data.stats;

    expect(stats.totalCars, equals(2));
    expect(stats.delivered, equals(2));
    // Delivered cars must never count as overdue or upcoming
    expect(stats.overdue, equals(0));
    expect(stats.upcomingDeliveries, equals(0));
    expect(data.overdueCars, isEmpty);
    expect(data.upcomingCars, isEmpty);

    await db.close();
  });

  test(
      'Dashboard updates reactively upon adding, editing, and deleting vehicles',
      () async {
    final dbFile = File('${tempDir.path}/dashboard_reactive_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final carsRepo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );
    final dashboardRepo = DashboardRepositoryImpl(db.carsDao);

    final testNow = DateTime(2026, 11, 10, 14, 0);

    // 1. Initial empty state
    var data = await dashboardRepo.getDashboardData(now: testNow);
    expect(data.stats.totalCars, equals(0));

    // 2. Add vehicle (in_progress, overdue)
    final carId = await carsRepo.addCar(
      CarModel(
        id: 0,
        vin: 'REACTIVE_CAR_1',
        customerName: 'Reactive Customer',
        timeIn: DateTime(2026, 11, 8, 10, 0),
        estimatedTimeOut: DateTime(2026, 11, 9, 10, 0), // Overdue
        status: 'in_progress',
        complaint: 'Electrical',
        createdAt: DateTime(2026, 11, 8, 10, 0),
      ),
    );

    data = await dashboardRepo.getDashboardData(now: testNow);
    expect(data.stats.totalCars, equals(1));
    expect(data.stats.inProgress, equals(1));
    expect(data.stats.overdue, equals(1));

    // 3. Edit vehicle: mark as delivered
    final existingCar = await carsRepo.getCarById(carId);
    expect(existingCar, isNotNull);

    await carsRepo.updateCar(
      CarModel(
        id: carId,
        vin: existingCar!.vin,
        customerName: existingCar.customerName,
        timeIn: existingCar.timeIn,
        estimatedTimeOut: existingCar.estimatedTimeOut,
        actualTimeOut: testNow,
        status: 'delivered', // Changed to delivered
        complaint: existingCar.complaint,
        createdAt: existingCar.createdAt,
      ),
    );

    data = await dashboardRepo.getDashboardData(now: testNow);
    expect(data.stats.totalCars, equals(1));
    expect(data.stats.inProgress, equals(0));
    expect(data.stats.delivered, equals(1));
    expect(data.stats.overdue, equals(0)); // No longer overdue because delivered

    // 4. Delete vehicle
    await carsRepo.deleteCar(carId);

    data = await dashboardRepo.getDashboardData(now: testNow);
    expect(data.stats.totalCars, equals(0));
    expect(data.stats.delivered, equals(0));
    expect(data.stats.inProgress, equals(0));

    await db.close();
  });
}

