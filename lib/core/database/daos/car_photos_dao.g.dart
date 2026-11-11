// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_photos_dao.dart';

// ignore_for_file: type=lint
mixin _$CarPhotosDaoMixin on DatabaseAccessor<AppDatabase> {
  $CarsTable get cars => attachedDatabase.cars;
  $CarPhotosTable get carPhotos => attachedDatabase.carPhotos;
  CarPhotosDaoManager get managers => CarPhotosDaoManager(this);
}

class CarPhotosDaoManager {
  final _$CarPhotosDaoMixin _db;
  CarPhotosDaoManager(this._db);
  $$CarsTableTableManager get cars =>
      $$CarsTableTableManager(_db.attachedDatabase, _db.cars);
  $$CarPhotosTableTableManager get carPhotos =>
      $$CarPhotosTableTableManager(_db.attachedDatabase, _db.carPhotos);
}
