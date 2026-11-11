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
    tempDir = await Directory.systemTemp.createTemp('auto_desk_test_docs_');
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

  CarModel createSampleCar({required String vin}) {
    return CarModel(
      id: 0,
      vin: vin,
      customerName: 'John Doe',
      timeIn: DateTime.now(),
      estimatedTimeOut: DateTime.now().add(const Duration(days: 1)),
      complaint: 'Brake inspection',
      status: 'received',
      createdAt: DateTime.now(),
    );
  }

  Future<File> createDummyImage(String name) async {
    final file = File('${sourcePhotosDir.path}/$name.jpg');
    await file.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46]);
    return file;
  }

  test('CarPhotoStorageService saves files uniquely and deletes them', () async {
    final img1 = await createDummyImage('img1');
    final img2 = await createDummyImage('img2');

    final savedPaths = await storageService.savePhotos(
      sourcePaths: [img1.path, img2.path],
      carId: 101,
    );

    expect(savedPaths.length, 2);
    expect(savedPaths[0], isNot(equals(img1.path)));
    expect(File(savedPaths[0]).existsSync(), isTrue);
    expect(File(savedPaths[1]).existsSync(), isTrue);

    // Verify deletion
    final deleted = await storageService.deletePhotoFile(savedPaths[0]);
    expect(deleted, isTrue);
    expect(File(savedPaths[0]).existsSync(), isFalse);
    expect(File(savedPaths[1]).existsSync(), isTrue);
  });

  test(
      'Complete Vehicle Photo Persistence lifecycle: add, close/reopen, delete photo, delete car',
      () async {
    final dbFile = File('${tempDir.path}/test_db.sqlite');
    AppDatabase openDb() => AppDatabase.forTesting(
          NativeDatabase(dbFile),
        );

    var db = openDb();
    var repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    // 1. Create dummy image files (as if picked from camera / gallery)
    final img1 = await createDummyImage('front');
    final img2 = await createDummyImage('back');

    // 2. Add car with multiple photos
    final carId = await repo.addCar(
      createSampleCar(vin: 'TESTVIN123456789'),
      photoPaths: [img1.path, img2.path],
    );

    expect(carId, greaterThan(0));

    final photosAfterAdd = await repo.getCarPhotos(carId);
    expect(photosAfterAdd.length, 2);
    final photo1Path = photosAfterAdd[0].filePath;
    final photo2Path = photosAfterAdd[1].filePath;

    expect(File(photo1Path).existsSync(), isTrue);
    expect(File(photo2Path).existsSync(), isTrue);

    // 3. Test Persistence across DB closure / app restart
    await db.close();

    // Reopen the database on the exact same sqlite file
    db = openDb();
    repo = CarsRepositoryImpl(
      carsDao: db.carsDao,
      carPhotosDao: db.carPhotosDao,
      photoStorageService: storageService,
    );

    final carAfterReopen = await repo.getCarById(carId);
    expect(carAfterReopen, isNotNull);
    expect(carAfterReopen!.vin, 'TESTVIN123456789');

    final photosAfterReopen = await repo.getCarPhotos(carId);
    expect(photosAfterReopen.length, 2);
    expect(photosAfterReopen[0].filePath, photo1Path);
    expect(File(photo1Path).existsSync(), isTrue);
    expect(File(photo2Path).existsSync(), isTrue);

    // 4. Add more photos to an existing car
    final img3 = await createDummyImage('side');
    await repo.addPhotosToCar(carId, [img3.path]);

    final photosAfterAddMore = await repo.getCarPhotos(carId);
    expect(photosAfterAddMore.length, 3);
    final photo3Path = photosAfterAddMore[2].filePath;
    expect(File(photo3Path).existsSync(), isTrue);

    // 5. Delete individual photo
    final deleteResult =
        await repo.deleteCarPhoto(photosAfterAddMore[0].id);
    expect(deleteResult, isTrue);

    final photosAfterDeleteOne = await repo.getCarPhotos(carId);
    expect(photosAfterDeleteOne.length, 2);
    expect(File(photo1Path).existsSync(), isFalse); // File is physically deleted
    expect(File(photo2Path).existsSync(), isTrue); // Other file still intact

    // 6. Delete car and confirm its remaining photo files and DB records are removed
    await repo.deleteCar(carId);

    final carAfterDelete = await repo.getCarById(carId);
    expect(carAfterDelete, isNull);

    final photosAfterCarDelete = await repo.getCarPhotos(carId);
    expect(photosAfterCarDelete, isEmpty);

    // Confirm physical files for the car are all removed
    expect(File(photo2Path).existsSync(), isFalse);
    expect(File(photo3Path).existsSync(), isFalse);

    await db.close();
  });
}

