import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class WatchDashboardDataUseCase {
  final DashboardRepository repository;

  WatchDashboardDataUseCase(this.repository);

  Stream<DashboardData> call({DateTime? now}) {
    return repository.watchDashboardData(now: now);
  }
}

