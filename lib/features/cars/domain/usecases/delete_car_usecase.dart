import '../repositories/cars_repository.dart';

// import '../repositories/cars_repository.dart';

class DeleteCarUseCase {
  final CarsRepository repository;

  DeleteCarUseCase(this.repository);

  Future<int> call(int id) {
    return repository.deleteCar(id);
  }
}
