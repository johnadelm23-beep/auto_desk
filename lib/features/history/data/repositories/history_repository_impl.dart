import '../../../../core/database/daos/cars_dao.dart';
import '../../../cars/data/models/car_model.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final CarsDao carsDao;

  HistoryRepositoryImpl(this.carsDao);

  @override
  Future<List<CarModel>> getDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) async {
    final cars = await carsDao.getDeliveredCars(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
    );
    return cars.map(CarModel.fromEntity).toList();
  }

  @override
  Stream<List<CarModel>> watchDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return carsDao
        .watchDeliveredCars(
          searchQuery: searchQuery,
          startDate: startDate,
          endDate: endDate,
          ascending: ascending,
        )
        .map((cars) => cars.map(CarModel.fromEntity).toList());
  }
}

