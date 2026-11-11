import '../../../cars/data/models/car_model.dart';

abstract class HistoryRepository {
  Future<List<CarModel>> getDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  });

  Stream<List<CarModel>> watchDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  });
}
