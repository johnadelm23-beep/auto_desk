import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/car_photos_table.dart';

part 'car_photos_dao.g.dart';

@DriftAccessor(tables: [CarPhotos])
class CarPhotosDao extends DatabaseAccessor<AppDatabase>
    with _$CarPhotosDaoMixin {
  CarPhotosDao(super.db);

  Future<List<CarPhoto>> getPhotosByCarId(int carId) {
    return (select(carPhotos)
          ..where((t) => t.carId.equals(carId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<CarPhoto>> watchPhotosByCarId(int carId) {
    return (select(carPhotos)
          ..where((t) => t.carId.equals(carId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<CarPhoto?> getPhotoById(int id) {
    return (select(carPhotos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertPhoto(CarPhotosCompanion photo) {
    return into(carPhotos).insert(photo);
  }

  Future<void> insertPhotos(List<CarPhotosCompanion> entries) async {
    await batch((b) {
      b.insertAll(carPhotos, entries);
    });
  }

  Future<int> deletePhoto(int id) {
    return (delete(carPhotos)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deletePhotosByCarId(int carId) {
    return (delete(carPhotos)..where((t) => t.carId.equals(carId))).go();
  }

  Future<List<CarPhoto>> getAllPhotos() {
    return select(carPhotos).get();
  }
}
