import '../repositories/cars_repository.dart';

import '../../data/models/car_model.dart';
// import '../repositories/cars_repository.dart';

class GetCarByIdUseCase {
  final CarsRepository repository;

  GetCarByIdUseCase(this.repository);

  Future<CarModel?> call(int id) {
    return repository.getCarById(id);
  }
}
