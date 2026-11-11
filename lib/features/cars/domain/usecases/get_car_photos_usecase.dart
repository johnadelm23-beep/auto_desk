import '../repositories/cars_repository.dart';
import '../../data/models/car_photo_model.dart';

class GetCarPhotosUseCase {
  final CarsRepository repository;

  GetCarPhotosUseCase(this.repository);

  Future<List<CarPhotoModel>> call(int carId) {
    return repository.getCarPhotos(carId);
  }
}

