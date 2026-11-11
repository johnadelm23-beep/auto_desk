import '../repositories/cars_repository.dart';

import '../../data/models/car_model.dart';
// import '../repositories/cars_repository.dart';

class GetAllCarsUseCase {
  final CarsRepository repository;

  GetAllCarsUseCase(this.repository);

  Future<List<CarModel>> call() {
    return repository.getAllCars();
  }
}
