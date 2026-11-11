import '../../../cars/data/models/car_model.dart';
import '../repositories/history_repository.dart';

class WatchDeliveredCarsUseCase {
  final HistoryRepository repository;

  WatchDeliveredCarsUseCase(this.repository);

  Stream<List<CarModel>> call({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return repository.watchDeliveredCars(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
    );
  }
}

