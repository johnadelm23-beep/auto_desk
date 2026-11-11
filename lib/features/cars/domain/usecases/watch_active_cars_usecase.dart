import '../../data/models/car_model.dart';
import '../repositories/cars_repository.dart';

class WatchActiveCarsUseCase {
  final CarsRepository repository;

  WatchActiveCarsUseCase(this.repository);

  Stream<List<CarModel>> call() {
    return repository.watchActiveCars();
  }
}

