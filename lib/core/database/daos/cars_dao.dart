import 'package:drift/drift.dart';

import '../../../features/dashboard/domain/entities/dashboard_statistics.dart';
import '../app_database.dart';
import '../tables/cars_table.dart';

part "cars_dao.g.dart";

@DriftAccessor(tables: [Cars])
class CarsDao extends DatabaseAccessor<AppDatabase>
    with _$CarsDaoMixin {
  CarsDao(super.db);

  Future<List<Car>> getAllCars() {
    return select(cars).get();
  }

  Stream<List<Car>> watchAllCars() {
    return (select(cars)
          ..orderBy([
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<Car>> watchActiveCars() {
    return (select(cars)
          ..where((t) => t.status.equals('delivered').not())
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  Future<List<Car>> getActiveCars() {
    return (select(cars)
          ..where((t) => t.status.equals('delivered').not())
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<Car?> getCarById(int id) {
    return (select(cars)..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Car?> getCarByVin(String vin) {
    return (select(cars)..where((table) => table.vin.equals(vin)))
        .getSingleOrNull();
  }

  Future<int> insertCar(CarsCompanion car) {
    return into(cars).insert(car);
  }

  Future<bool> updateCar(CarsCompanion car) {
    return update(cars).replace(car);
  }

  Future<int> deleteCar(int id) {
    return (delete(cars)..where((table) => table.id.equals(id))).go();
  }

  Future<DashboardStatistics> getDashboardStatistics({DateTime? now}) async {
    final currentTime = (now ?? DateTime.now()).toLocal();
    final startOfToday =
        DateTime(currentTime.year, currentTime.month, currentTime.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final next24Hours = currentTime.add(const Duration(hours: 24));

    final totalExpr = cars.id.count();
    final receivedTodayExpr = cars.id.count(
      filter: cars.timeIn.isBiggerOrEqualValue(startOfToday) &
          cars.timeIn.isSmallerThanValue(endOfToday),
    );
    final inProgressExpr = cars.id.count(
      filter: cars.status.equals('in_progress'),
    );
    final readyExpr = cars.id.count(
      filter: cars.status.equals('ready'),
    );
    final deliveredExpr = cars.id.count(
      filter: cars.status.equals('delivered'),
    );
    final overdueExpr = cars.id.count(
      filter: cars.status.equals('delivered').not() &
          cars.estimatedTimeOut.isSmallerThanValue(currentTime),
    );
    final upcomingExpr = cars.id.count(
      filter: cars.status.equals('delivered').not() &
          cars.estimatedTimeOut.isBiggerOrEqualValue(currentTime) &
          cars.estimatedTimeOut.isSmallerOrEqualValue(next24Hours),
    );

    final query = selectOnly(cars)
      ..addColumns([
        totalExpr,
        receivedTodayExpr,
        inProgressExpr,
        readyExpr,
        deliveredExpr,
        overdueExpr,
        upcomingExpr,
      ]);

    final row = await query.getSingle();

    return DashboardStatistics(
      totalCars: row.read(totalExpr) ?? 0,
      receivedToday: row.read(receivedTodayExpr) ?? 0,
      inProgress: row.read(inProgressExpr) ?? 0,
      ready: row.read(readyExpr) ?? 0,
      delivered: row.read(deliveredExpr) ?? 0,
      overdue: row.read(overdueExpr) ?? 0,
      upcomingDeliveries: row.read(upcomingExpr) ?? 0,
    );
  }

  Future<List<Car>> getOverdueCars({DateTime? now, int limit = 5}) {
    final currentTime = (now ?? DateTime.now()).toLocal();
    return (select(cars)
          ..where((t) =>
              t.status.equals('delivered').not() &
              t.estimatedTimeOut.isSmallerThanValue(currentTime))
          ..orderBy([(t) => OrderingTerm.asc(t.estimatedTimeOut)])
          ..limit(limit))
        .get();
  }

  Future<List<Car>> getUpcomingDeliveries({DateTime? now, int limit = 5}) {
    final currentTime = (now ?? DateTime.now()).toLocal();
    final next24Hours = currentTime.add(const Duration(hours: 24));
    return (select(cars)
          ..where((t) =>
              t.status.equals('delivered').not() &
              t.estimatedTimeOut.isBiggerOrEqualValue(currentTime) &
              t.estimatedTimeOut.isSmallerOrEqualValue(next24Hours))
          ..orderBy([(t) => OrderingTerm.asc(t.estimatedTimeOut)])
          ..limit(limit))
        .get();
  }

  Future<List<Car>> getRecentCars({int limit = 5}) {
    return (select(cars)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  SimpleSelectStatement<$CarsTable, Car> _buildDeliveredCarsQuery({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return select(cars)
      ..where((t) {
        Expression<bool> predicate = t.status.equals('delivered');

        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final term = '%${searchQuery.trim().toUpperCase()}%';
          final rawTerm = '%${searchQuery.trim()}%';
          predicate = predicate &
              (t.vin.like(term) |
                  t.customerName.like(rawTerm) |
                  t.carModel.like(rawTerm));
        }

        if (startDate != null) {
          final start =
              DateTime(startDate.year, startDate.month, startDate.day);
          predicate = predicate & t.actualTimeOut.isBiggerOrEqualValue(start);
        }

        if (endDate != null) {
          final end = DateTime(endDate.year, endDate.month, endDate.day)
              .add(const Duration(days: 1));
          predicate = predicate & t.actualTimeOut.isSmallerThanValue(end);
        }

        return predicate;
      })
      ..orderBy([
        (t) => ascending
            ? OrderingTerm.asc(t.actualTimeOut)
            : OrderingTerm.desc(t.actualTimeOut),
      ]);
  }

  Future<List<Car>> getDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return _buildDeliveredCarsQuery(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
    ).get();
  }

  Stream<List<Car>> watchDeliveredCars({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool ascending = false,
  }) {
    return _buildDeliveredCarsQuery(
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      ascending: ascending,
    ).watch();
  }
}