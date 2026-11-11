import '../../../cars/data/models/car_model.dart';
import 'dashboard_statistics.dart';

class DashboardData {
  final DashboardStatistics stats;
  final List<CarModel> overdueCars;
  final List<CarModel> upcomingCars;
  final List<CarModel> recentCars;

  const DashboardData({
    this.stats = const DashboardStatistics(),
    this.overdueCars = const [],
    this.upcomingCars = const [],
    this.recentCars = const [],
  });
}

