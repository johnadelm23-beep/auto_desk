import '../../../cars/data/models/car_model.dart';
import '../repositories/history_repository.dart';

class GetDeliveredCarsUseCase {
  final HistoryRepository repository;

  GetDeliveredCarsUseCase(this.repository);

  Future<List<CarModel>> call({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return repository.getDeliveredCars(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
    );
  }
}

