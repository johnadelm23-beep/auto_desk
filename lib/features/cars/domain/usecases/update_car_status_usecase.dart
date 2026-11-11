import '../repositories/cars_repository.dart';

class UpdateCarStatusUseCase {
  final CarsRepository repository;

  UpdateCarStatusUseCase(this.repository);

  Future<bool> call(int id, String newStatus) {
    return repository.updateCarStatus(id, newStatus);
  }
}

