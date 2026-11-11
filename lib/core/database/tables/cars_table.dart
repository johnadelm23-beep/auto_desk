import 'package:drift/drift.dart';

class Cars extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get vin => text().unique()();

  TextColumn get carModel => text().nullable()();

  TextColumn get customerName => text()();

  DateTimeColumn get timeIn => dateTime()();

  DateTimeColumn get estimatedTimeOut => dateTime()();

  DateTimeColumn get actualTimeOut => dateTime().nullable()();

  TextColumn get complaint => text()();

  RealColumn get estimatedCost => real().nullable()();

  TextColumn get status => text().withDefault(
        const Constant('received'),
      )();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(
        currentDateAndTime,
      )();
}