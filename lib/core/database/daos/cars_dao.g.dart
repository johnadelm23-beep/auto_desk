// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cars_dao.dart';

// ignore_for_file: type=lint
mixin _$CarsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CarsTable get cars => attachedDatabase.cars;
  CarsDaoManager get managers => CarsDaoManager(this);
}

class CarsDaoManager {
  final _$CarsDaoMixin _db;
  CarsDaoManager(this._db);
  $$CarsTableTableManager get cars =>
      $$CarsTableTableManager(_db.attachedDatabase, _db.cars);
}
