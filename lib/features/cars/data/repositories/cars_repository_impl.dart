import 'package:auto_desk/core/database/app_database.dart';
import 'package:auto_desk/features/cars/domain/repositories/cars_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/daos/cars_dao.dart';
import '../../../../core/database/daos/car_photos_dao.dart';
import '../../../../core/services/car_photo_storage_service.dart';
import '../../../../core/services/vehicle_reminder_scheduler.dart';
import '../models/car_model.dart';
import '../models/car_photo_model.dart';

class CarsRepositoryImpl implements CarsRepository {
  final CarsDao carsDao;
  final CarPhotosDao carPhotosDao;
  final CarPhotoStorageService photoStorageService;
  final VehicleReminderScheduler? reminderScheduler;

  CarsRepositoryImpl({
    required this.carsDao,
    required this.carPhotosDao,
    required this.photoStorageService,
    this.reminderScheduler,
  });

  @override
  Future<List<CarModel>> getAllCars() async {
    final cars = await carsDao.getAllCars();
    return cars.map(CarModel.fromEntity).toList();
  }

  @override
  Stream<List<CarModel>> watchAllCars() {
    return carsDao.watchAllCars().map(
          (cars) => cars.map(CarModel.fromEntity).toList(),
        );
  }

  @override
  Stream<List<CarModel>> watchActiveCars() {
    return carsDao.watchActiveCars().map(
          (cars) => cars.map(CarModel.fromEntity).toList(),
        );
  }

  @override
  Future<List<CarModel>> getActiveCars() async {
    final cars = await carsDao.getActiveCars();
    return cars.map(CarModel.fromEntity).toList();
  }

  @override
  Future<CarModel?> getCarById(int id) async {
    final car = await carsDao.getCarById(id);
    if (car == null) return null;
    return CarModel.fromEntity(car);
  }

  @override
  Future<CarModel?> getCarByVin(String vin) async {
    final car = await carsDao.getCarByVin(vin);
    if (car == null) return null;
    return CarModel.fromEntity(car);
  }

  @override
  Future<bool> isVinUnique(String vin, {int? excludeCarId}) async {
    final existingCar = await carsDao.getCarByVin(vin);
    if (existingCar == null) return true;
    if (excludeCarId != null && existingCar.id == excludeCarId) return true;
    return false;
  }

  @override
  Future<int> addCar(CarModel car, {List<String> photoPaths = const []}) async {
    final estimatedTimeOutBeforeInsert = car.estimatedTimeOut;

    final carId = await carsDao.insertCar(
      CarsCompanion.insert(
        vin: car.vin,
        carModel: Value(car.carModel),
        customerName: car.customerName,
        timeIn: car.timeIn,
        estimatedTimeOut: car.estimatedTimeOut,
        complaint: car.complaint,
        actualTimeOut: Value(car.actualTimeOut),
        estimatedCost: Value(car.estimatedCost),
        status: Value(car.status),
        notes: Value(car.notes),
      ),
    );

    // Fetch the actual saved vehicle from Drift
    final insertedCar = carId > 0 ? await carsDao.getCarById(carId) : null;
    final estimatedTimeOutAfterInsert = insertedCar?.estimatedTimeOut;

    debugPrint(
      '[AutoDesk VehicleScheduler] Vehicle DB Insert:\n'
      '  - Vehicle ID: $carId\n'
      '  - VIN: ${car.vin}\n'
      '  - Customer: ${car.customerName}\n'
      '  - Status: ${car.status}\n'
      '  - estimatedTimeOut before DB insert: $estimatedTimeOutBeforeInsert (isUtc: ${estimatedTimeOutBeforeInsert.isUtc})\n'
      '  - estimatedTimeOut after DB insert: $estimatedTimeOutAfterInsert (isUtc: ${estimatedTimeOutAfterInsert?.isUtc})\n',
    );

    if (photoPaths.isNotEmpty && carId > 0) {
      List<String> savedPaths = [];
      try {
        savedPaths = await photoStorageService.savePhotos(
          sourcePaths: photoPaths,
          carId: carId,
        );

        final companions = savedPaths
            .map((path) => CarPhotosCompanion.insert(
                  carId: carId,
                  filePath: path,
                ))
            .toList();

        await carPhotosDao.insertPhotos(companions);
      } catch (e) {
        // If database insertion fails, clean up the newly saved files
        await photoStorageService.deleteMultipleFiles(savedPaths);
        rethrow;
      }
    }

    if (carId > 0 && reminderScheduler != null) {
      final vehicleToSchedule = CarModel(
        id: carId,
        vin: car.vin,
        carModel: car.carModel,
        customerName: car.customerName,
        timeIn: car.timeIn,
        estimatedTimeOut: car.estimatedTimeOut,
        actualTimeOut: car.actualTimeOut,
        complaint: car.complaint,
        estimatedCost: car.estimatedCost,
        status: car.status,
        notes: car.notes,
        createdAt: insertedCar?.createdAt ?? car.createdAt,
      );

      await reminderScheduler!.scheduleVehicleReminders(vehicleToSchedule);
    }

    return carId;
  }

  @override
  Future<bool> updateCar(CarModel car) async {
    final existingCar = await carsDao.getCarById(car.id);

    DateTime? actualTimeOut;
    if (car.status == 'delivered') {
      if (existingCar?.status == 'delivered') {
        // Ordinary edit of delivered car: preserve existing actualTimeOut
        actualTimeOut =
            car.actualTimeOut ?? existingCar?.actualTimeOut ?? DateTime.now().toLocal();
      } else {
        // Transition to delivered: automatically set current local time
        actualTimeOut = car.actualTimeOut ?? DateTime.now().toLocal();
      }
    } else if (existingCar?.status == 'delivered') {
      // Changed back from delivered to active status: clear actualTimeOut
      actualTimeOut = null;
    } else {
      // Both existing and new status are active
      actualTimeOut = car.actualTimeOut;
    }

    final success = await carsDao.updateCar(
      CarsCompanion(
        id: Value(car.id),
        vin: Value(car.vin),
        carModel: Value(car.carModel),
        customerName: Value(car.customerName),
        timeIn: Value(car.timeIn),
        estimatedTimeOut: Value(car.estimatedTimeOut),
        actualTimeOut: Value(actualTimeOut),
        complaint: Value(car.complaint),
        estimatedCost: Value(car.estimatedCost),
        status: Value(car.status),
        notes: Value(car.notes),
        createdAt: Value(car.createdAt),
      ),
    );

    if (success && reminderScheduler != null) {
      if (car.status == 'delivered') {
        await reminderScheduler!.cancelVehicleReminders(car.id);
      } else {
        await reminderScheduler!.scheduleVehicleReminders(car);
      }
    }

    return success;
  }

  @override
  Future<bool> updateCarStatus(int id, String newStatus) async {
    final car = await getCarById(id);
    if (car == null) return false;

    final updatedCar = CarModel(
      id: car.id,
      vin: car.vin,
      carModel: car.carModel,
      customerName: car.customerName,
      timeIn: car.timeIn,
      estimatedTimeOut: car.estimatedTimeOut,
      actualTimeOut: newStatus == 'delivered' ? car.actualTimeOut : null,
      complaint: car.complaint,
      estimatedCost: car.estimatedCost,
      status: newStatus,
      notes: car.notes,
      createdAt: car.createdAt,
    );

    return updateCar(updatedCar);
  }

  @override
  Future<int> deleteCar(int id) async {
    // 1. Fetch all photos associated with this car before deletion
    final photos = await carPhotosDao.getPhotosByCarId(id);

    // 2. Delete car in database (triggers cascade delete on CarPhotos rows in SQLite)
    final result = await carsDao.deleteCar(id);

    // 3. Cancel any scheduled reminders for this car
    if (reminderScheduler != null) {
      await reminderScheduler!.cancelVehicleReminders(id);
    }

    // 3. Remove all associated physical photo files from device storage
    for (final photo in photos) {
      await photoStorageService.deletePhotoFile(photo.filePath);
    }

    return result;
  }

  @override
  Future<List<CarPhotoModel>> getCarPhotos(int carId) async {
    final photos = await carPhotosDao.getPhotosByCarId(carId);
    return photos.map(CarPhotoModel.fromEntity).toList();
  }

  @override
  Stream<List<CarPhotoModel>> watchCarPhotos(int carId) {
    return carPhotosDao
        .watchPhotosByCarId(carId)
        .map((photos) => photos.map(CarPhotoModel.fromEntity).toList());
  }

  @override
  Future<List<CarPhotoModel>> addPhotosToCar(
    int carId,
    List<String> sourceFilePaths,
  ) async {
    if (sourceFilePaths.isEmpty) return [];

    List<String> savedPaths = [];
    try {
      savedPaths = await photoStorageService.savePhotos(
        sourcePaths: sourceFilePaths,
        carId: carId,
      );

      final companions = savedPaths
          .map((path) => CarPhotosCompanion.insert(
                carId: carId,
                filePath: path,
              ))
          .toList();

      await carPhotosDao.insertPhotos(companions);

      final photos = await carPhotosDao.getPhotosByCarId(carId);
      return photos.map(CarPhotoModel.fromEntity).toList();
    } catch (e) {
      await photoStorageService.deleteMultipleFiles(savedPaths);
      rethrow;
    }
  }

  @override
  Future<bool> deleteCarPhoto(int photoId) async {
    final photo = await carPhotosDao.getPhotoById(photoId);
    if (photo == null) return false;

    await carPhotosDao.deletePhoto(photoId);
    await photoStorageService.deletePhotoFile(photo.filePath);
    return true;
  }
}

