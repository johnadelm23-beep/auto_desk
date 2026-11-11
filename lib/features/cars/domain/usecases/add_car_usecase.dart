import '../repositories/cars_repository.dart';

import '../../data/models/car_model.dart';
// import '../repositories/cars_repository.dart';

class AddCarUseCase {
  final CarsRepository repository;

  AddCarUseCase(this.repository);

  Future<int> call(CarModel car, {List<String> photoPaths = const []}) {
    return repository.addCar(car, photoPaths: photoPaths);
  }
}
