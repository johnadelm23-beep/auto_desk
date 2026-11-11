import 'dart:io';

import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/core/services/car_photo_storage_service.dart';
import 'package:auto_desk/features/cars/data/models/car_model.dart';
import 'package:auto_desk/features/cars/data/repositories/cars_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late Directory sourcePhotosDir;
  late CarPhotoStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('auto_desk_edit_test_');
    sourcePhotosDir =
        await Directory.systemTemp.createTemp('auto_desk_source_photos_');

    storageService = CarPhotoStorageService(
      baseDirectoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    if (await sourcePhotosDir.exists()) {
      await sourcePhotosDir.delete(recursive: true);
    }
  });

  Future<File> createDummyImage(String name) async {
    final file = File('${sourcePhotosDir.path}/$name.jpg');
    await file.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46]);
    return file;
  }

  test(
      'Edit each field, verify ID and createdAt are preserved, and changes persist across app reopen',
      () async {
    final dbFile = File('${tempDir.path}/car_edit_test.sqlite');
    AppDatabase openDb() => AppDatabase.forTesting(NativeDatabase(dbFile));

    var db = openDb();
    var repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final initialCreatedAt = DateTime(2026, 1, 1, 9, 30);
    final initialTimeIn = DateTime(2026, 1, 1, 10, 0);
    final initialTimeOut = DateTime(2026, 1, 2, 18, 0);

    // 1. Add original car
    final originalCar = CarModel(
      id: 0,
      vin: 'VIN_ORIGINAL',
      carModel: 'Original Car Model',
      customerName: 'Original Customer',
      timeIn: initialTimeIn,
      estimatedTimeOut: initialTimeOut,
      complaint: 'Original Complaint',
      estimatedCost: 100.0,
      status: 'received',
      notes: 'Original Notes',
      createdAt: initialCreatedAt,
    );

    final carId = await repo.addCar(originalCar);
    expect(carId, greaterThan(0));

    // Fetch the inserted car
    final insertedCar = await repo.getCarById(carId);
    expect(insertedCar, isNotNull);
    final originalCreatedTimestamp = insertedCar!.createdAt;

    // 2. Edit every field
    final newTimeIn = DateTime(2026, 1, 1, 11, 45);
    final newTimeOut = DateTime(2026, 1, 5, 16, 0);
    final newActualTimeOut = DateTime(2026, 1, 5, 15, 30);

    final updatedCar = CarModel(
      id: carId,
      vin: 'VIN_EDITED',
      carModel: 'Updated Car Model 2026',
      customerName: 'Updated Customer Name',
      timeIn: newTimeIn,
      estimatedTimeOut: newTimeOut,
      actualTimeOut: newActualTimeOut,
      complaint: 'Updated Engine Check Complaint',
      estimatedCost: 450.75,
      status: 'in_progress',
      notes: 'Updated Detailed Notes',
      createdAt: originalCreatedTimestamp, // Preserving original createdAt
    );

    final updateSuccess = await repo.updateCar(updatedCar);
    expect(updateSuccess, isTrue);

    // 3. Test persistence across app closure / reopen
    await db.close();

    db = openDb();
    repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final loadedCar = await repo.getCarById(carId);
    expect(loadedCar, isNotNull);

    // Verify ID and createdAt remain unchanged
    expect(loadedCar!.id, equals(carId));
    expect(loadedCar.createdAt, equals(originalCreatedTimestamp));

    // Verify all updated fields persisted
    expect(loadedCar.vin, equals('VIN_EDITED'));
    expect(loadedCar.carModel, equals('Updated Car Model 2026'));
    expect(loadedCar.customerName, equals('Updated Customer Name'));
    expect(loadedCar.timeIn, equals(newTimeIn));
    expect(loadedCar.estimatedTimeOut, equals(newTimeOut));
    expect(loadedCar.actualTimeOut, equals(newActualTimeOut));
    expect(loadedCar.complaint, equals('Updated Engine Check Complaint'));
    expect(loadedCar.estimatedCost, equals(450.75));
    expect(loadedCar.status, equals('in_progress'));
    expect(loadedCar.notes, equals('Updated Detailed Notes'));

    await db.close();
  });

  test('VIN uniqueness: allows retaining current VIN, rejects existing VIN of another car',
      () async {
    final dbFile = File('${tempDir.path}/vin_validation_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    // Add Car A
    final carAId = await repo.addCar(
      CarModel(
        id: 0,
        vin: 'CAR_A_VIN',
        customerName: 'Alice',
        timeIn: DateTime.now(),
        estimatedTimeOut: DateTime.now().add(const Duration(days: 1)),
        complaint: 'Oil change',
        status: 'received',
        createdAt: DateTime.now(),
      ),
    );

    // Add Car B
    await repo.addCar(
      CarModel(
        id: 0,
        vin: 'CAR_B_VIN',
        customerName: 'Bob',
        timeIn: DateTime.now(),
        estimatedTimeOut: DateTime.now().add(const Duration(days: 1)),
        complaint: 'Tire rotation',
        status: 'received',
        createdAt: DateTime.now(),
      ),
    );

    // 1. Car A retaining its own VIN should be valid
    final canKeepOwnVin =
        await repo.isVinUnique('CAR_A_VIN', excludeCarId: carAId);
    expect(canKeepOwnVin, isTrue);

    // 2. Completely fresh VIN should be valid
    final freshVinValid =
        await repo.isVinUnique('FRESH_VIN_999', excludeCarId: carAId);
    expect(freshVinValid, isTrue);

    // 3. Attempting to set Car A's VIN to Car B's existing VIN should be rejected
    final duplicateRejected =
        await repo.isVinUnique('CAR_B_VIN', excludeCarId: carAId);
    expect(duplicateRejected, isFalse);

    await db.close();
  });

  test('Editing car information keeps existing photos completely intact',
      () async {
    final dbFile = File('${tempDir.path}/photo_integrity_test.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final img1 = await createDummyImage('photo1');
    final img2 = await createDummyImage('photo2');

    // Add car with 2 photos
    final carId = await repo.addCar(
      CarModel(
        id: 0,
        vin: 'PHOTO_CAR_VIN',
        customerName: 'Customer With Photos',
        timeIn: DateTime.now(),
        estimatedTimeOut: DateTime.now().add(const Duration(days: 2)),
        complaint: 'Body work',
        status: 'received',
        createdAt: DateTime.now(),
      ),
      photoPaths: [img1.path, img2.path],
    );

    final initialPhotos = await repo.getCarPhotos(carId);
    expect(initialPhotos.length, 2);
    final photo1Id = initialPhotos[0].id;
    final photo1Path = initialPhotos[0].filePath;
    final photo2Id = initialPhotos[1].id;
    final photo2Path = initialPhotos[1].filePath;

    expect(File(photo1Path).existsSync(), isTrue);
    expect(File(photo2Path).existsSync(), isTrue);

    // Update car details multiple times
    final car = await repo.getCarById(carId);
    final updatedCar = CarModel(
      id: carId,
      vin: 'PHOTO_CAR_VIN',
      customerName: 'Customer Name Changed',
      timeIn: car!.timeIn,
      estimatedTimeOut: car.estimatedTimeOut,
      complaint: 'Changed Complaint',
      estimatedCost: 999.0,
      status: 'ready',
      createdAt: car.createdAt,
    );

    await repo.updateCar(updatedCar);

    // Verify photos are unchanged
    final photosAfterEdit = await repo.getCarPhotos(carId);
    expect(photosAfterEdit.length, 2);
    expect(photosAfterEdit[0].id, equals(photo1Id));
    expect(photosAfterEdit[0].filePath, equals(photo1Path));
    expect(photosAfterEdit[1].id, equals(photo2Id));
    expect(photosAfterEdit[1].filePath, equals(photo2Path));

    expect(File(photo1Path).existsSync(), isTrue);
    expect(File(photo2Path).existsSync(), isTrue);

    await db.close();
  });
}
