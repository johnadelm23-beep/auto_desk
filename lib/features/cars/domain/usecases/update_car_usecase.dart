import '../repositories/cars_repository.dart';

import '../../data/models/car_model.dart';
// import '../repositories/cars_repository.dart';

class UpdateCarUseCase {
  final CarsRepository repository;

  UpdateCarUseCase(this.repository);

  Future<bool> call(CarModel car) {
    return repository.updateCar(car);
  }
}
