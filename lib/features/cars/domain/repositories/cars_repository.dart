import '../../data/models/car_model.dart';
import '../../data/models/car_photo_model.dart';

abstract class CarsRepository {
  Future<List<CarModel>> getAllCars();

  Stream<List<CarModel>> watchAllCars();

  Stream<List<CarModel>> watchActiveCars();

  Future<List<CarModel>> getActiveCars();

  Future<CarModel?> getCarById(int id);

  Future<CarModel?> getCarByVin(String vin);

  Future<bool> isVinUnique(String vin, {int? excludeCarId});

  Future<int> addCar(CarModel car, {List<String> photoPaths = const []});

  Future<bool> updateCar(CarModel car);

  Future<bool> updateCarStatus(int id, String newStatus);

  Future<int> deleteCar(int id);

  Future<List<CarPhotoModel>> getCarPhotos(int carId);

  Stream<List<CarPhotoModel>> watchCarPhotos(int carId);

  Future<List<CarPhotoModel>> addPhotosToCar(int carId, List<String> sourceFilePaths);

  Future<bool> deleteCarPhoto(int photoId);
}

