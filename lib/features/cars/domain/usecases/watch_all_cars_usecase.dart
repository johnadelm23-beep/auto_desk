import '../repositories/cars_repository.dart';

import '../../data/models/car_model.dart';
// import '../repositories/cars_repository.dart';

class WatchAllCarsUseCase {
  final CarsRepository repository;

  WatchAllCarsUseCase(this.repository);

  Stream<List<CarModel>> call() {
    return repository.watchAllCars();
  }
}
