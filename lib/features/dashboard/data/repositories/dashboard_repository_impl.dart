import '../../../../core/database/daos/cars_dao.dart';
import '../../../cars/data/models/car_model.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/dashboard_statistics.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final CarsDao carsDao;

  DashboardRepositoryImpl(this.carsDao);

  @override
  Future<DashboardData> getDashboardData({DateTime? now}) async {
    final stats = await carsDao.getDashboardStatistics(now: now);
    final overdue = await carsDao.getOverdueCars(now: now);
    final upcoming = await carsDao.getUpcomingDeliveries(now: now);
    final recent = await carsDao.getRecentCars();

    return DashboardData(
      stats: stats,
      overdueCars: overdue.map(CarModel.fromEntity).toList(),
      upcomingCars: upcoming.map(CarModel.fromEntity).toList(),
      recentCars: recent.map(CarModel.fromEntity).toList(),
    );
  }

  @override
  Stream<DashboardData> watchDashboardData({DateTime? now}) {
    return carsDao.watchAllCars().asyncMap((_) => getDashboardData(now: now));
  }

  @override
  Future<DashboardStatistics> getDashboardStatistics({DateTime? now}) {
    return carsDao.getDashboardStatistics(now: now);
  }
}

