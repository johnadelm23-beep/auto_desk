import 'package:drift/drift.dart';
import 'cars_table.dart';

class CarPhotos extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get carId => integer().references(
        Cars,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get filePath => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(
        currentDateAndTime,
      )();
}
