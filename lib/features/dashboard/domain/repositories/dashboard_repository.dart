import '../entities/dashboard_data.dart';
import '../entities/dashboard_statistics.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData({DateTime? now});

  Stream<DashboardData> watchDashboardData({DateTime? now});

  Future<DashboardStatistics> getDashboardStatistics({DateTime? now});
}

