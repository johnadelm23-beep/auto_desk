import '../repositories/cars_repository.dart';
import '../../data/models/car_photo_model.dart';

class WatchCarPhotosUseCase {
  final CarsRepository repository;

  WatchCarPhotosUseCase(this.repository);

  Stream<List<CarPhotoModel>> call(int carId) {
    return repository.watchCarPhotos(carId);
  }
}

