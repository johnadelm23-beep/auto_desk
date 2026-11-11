import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/cars_dao.dart';
import 'daos/car_photos_dao.dart';
import 'tables/cars_table.dart';
import 'tables/car_photos_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Cars,
    CarPhotos,
  ],
  daos: [
    CarsDao,
    CarPhotosDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(carPhotos);
          }
          if (from < 3) {
            await m.addColumn(cars, cars.carModel);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'auto_desk_database',
  );
}