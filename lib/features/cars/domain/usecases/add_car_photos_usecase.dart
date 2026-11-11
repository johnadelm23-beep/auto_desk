import '../repositories/cars_repository.dart';
import '../../data/models/car_photo_model.dart';

class AddCarPhotosUseCase {
  final CarsRepository repository;

  AddCarPhotosUseCase(this.repository);

  Future<List<CarPhotoModel>> call(int carId, List<String> sourceFilePaths) {
    return repository.addPhotosToCar(carId, sourceFilePaths);
  }
}

