import '../repositories/cars_repository.dart';

class CheckVinUniqueUseCase {
  final CarsRepository repository;

  CheckVinUniqueUseCase(this.repository);

  Future<bool> call(String vin, {int? excludeCarId}) {
    return repository.isVinUnique(vin, excludeCarId: excludeCarId);
  }
}

