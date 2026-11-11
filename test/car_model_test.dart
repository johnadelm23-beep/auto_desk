import 'dart:io';

import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/core/services/car_photo_storage_service.dart';
import 'package:auto_desk/features/cars/data/models/car_model.dart';
import 'package:auto_desk/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:auto_desk/features/history/data/repositories/history_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late CarPhotoStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auto_desk_car_model_test_');
    storageService = CarPhotoStorageService(
      baseDirectoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Database Schema is version 3 with carModel column', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    expect(db.schemaVersion, equals(3));
    expect(db.cars.carModel, isNotNull);
    await db.close();
  });

  test('Adding a car with carModel persists and retrieves correctly', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final car = CarModel(
      id: 0,
      vin: '1HGCR2F83HA123456',
      carModel: 'Toyota Camry 2023',
      customerName: 'Sarah Connor',
      timeIn: DateTime(2026, 11, 11, 10, 0),
      estimatedTimeOut: DateTime(2026, 11, 11, 14, 0),
      complaint: 'Oil change and brake pads inspection',
      estimatedCost: 220.0,
      status: 'received',
      createdAt: DateTime(2026, 11, 11, 10, 0),
    );

    final carId = await repo.addCar(car);
    expect(carId, greaterThan(0));

    final fetchedCar = await repo.getCarById(carId);
    expect(fetchedCar, isNotNull);
    expect(fetchedCar!.vin, equals('1HGCR2F83HA123456'));
    expect(fetchedCar.carModel, equals('Toyota Camry 2023'));
    expect(fetchedCar.customerName, equals('Sarah Connor'));

    await db.close();
  });

  test('Editing carModel updates the model and preserves all other fields', () async {
    final dbFile = File('${tempDir.path}/car_model_edit.sqlite');
    AppDatabase openDb() => AppDatabase.forTesting(NativeDatabase(dbFile));

    var db = openDb();
    var repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final originalCar = CarModel(
      id: 0,
      vin: 'WBA3A5C58DF654321',
      carModel: 'BMW 320i',
      customerName: 'James Gordon',
      timeIn: DateTime(2026, 11, 11, 9, 0),
      estimatedTimeOut: DateTime(2026, 11, 11, 12, 0),
      complaint: 'Check engine light',
      estimatedCost: 350.0,
      status: 'in_progress',
      createdAt: DateTime(2026, 11, 11, 9, 0),
    );

    final carId = await repo.addCar(originalCar);
    final savedOriginal = await repo.getCarById(carId);
    expect(savedOriginal!.carModel, equals('BMW 320i'));

    // Edit car model
    final updatedCar = savedOriginal.copyWith(
      carModel: 'BMW 330i M-Sport',
    );
    final updateResult = await repo.updateCar(updatedCar);
    expect(updateResult, isTrue);

    await db.close();

    // Reopen database to verify persistence across restarts
    db = openDb();
    repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final reopenedCar = await repo.getCarById(carId);
    expect(reopenedCar, isNotNull);
    expect(reopenedCar!.id, equals(carId));
    expect(reopenedCar.vin, equals('WBA3A5C58DF654321'));
    expect(reopenedCar.carModel, equals('BMW 330i M-Sport'));
    expect(reopenedCar.customerName, equals('James Gordon'));
    expect(reopenedCar.createdAt, equals(savedOriginal.createdAt));
    expect(reopenedCar.complaint, equals('Check engine light'));
    expect(reopenedCar.status, equals('in_progress'));

    await db.close();
  });

  test('Pre-migration record compatibility (null carModel loads cleanly and can be updated)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    // Add car with no carModel (mimics pre-migration records)
    final legacyCar = CarModel(
      id: 0,
      vin: 'LEGACY_VIN_001',
      carModel: null,
      customerName: 'Old Customer',
      timeIn: DateTime(2026, 1, 1, 8, 0),
      estimatedTimeOut: DateTime(2026, 1, 1, 10, 0),
      complaint: 'Routine checkup',
      status: 'received',
      createdAt: DateTime(2026, 1, 1, 8, 0),
    );

    final carId = await repo.addCar(legacyCar);
    final loadedLegacy = await repo.getCarById(carId);
    expect(loadedLegacy, isNotNull);
    expect(loadedLegacy!.carModel, isNull);
    expect(loadedLegacy.vin, equals('LEGACY_VIN_001'));

    // Now update the legacy record with a carModel
    final updatedLegacy = loadedLegacy.copyWith(carModel: 'Hyundai Elantra 2021');
    final success = await repo.updateCar(updatedLegacy);
    expect(success, isTrue);

    final reloaded = await repo.getCarById(carId);
    expect(reloaded!.carModel, equals('Hyundai Elantra 2021'));
    expect(reloaded.vin, equals('LEGACY_VIN_001'));

    await db.close();
  });

  test('Search in delivered history matches carModel', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );
    final historyRepo = HistoryRepositoryImpl(db.carsDao);

    final deliveredCar = CarModel(
      id: 0,
      vin: 'DELIVERED_VIN_ABC',
      carModel: 'Mercedes-Benz C200',
      customerName: 'Bruce Wayne',
      timeIn: DateTime(2026, 11, 10, 8, 0),
      estimatedTimeOut: DateTime(2026, 11, 10, 12, 0),
      actualTimeOut: DateTime(2026, 11, 10, 11, 30),
      complaint: 'Transmission fluid service',
      status: 'delivered',
      createdAt: DateTime(2026, 11, 10, 8, 0),
    );

    await repo.addCar(deliveredCar);

    // Search by model name substring "Mercedes"
    final results = await historyRepo.getDeliveredCars(searchQuery: 'Mercedes');
    expect(results.length, equals(1));
    expect(results.first.carModel, equals('Mercedes-Benz C200'));

    // Search by non-matching query
    final noResults = await historyRepo.getDeliveredCars(searchQuery: 'Ferrari');
    expect(noResults, isEmpty);

    await db.close();
  });
}

