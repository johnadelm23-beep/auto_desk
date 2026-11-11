import 'package:auto_desk/core/database/app_database.dart';

class CarPhotoModel {
  final int id;
  final int carId;
  final String filePath;
  final DateTime createdAt;

  const CarPhotoModel({
    required this.id,
    required this.carId,
    required this.filePath,
    required this.createdAt,
  });

  factory CarPhotoModel.fromEntity(CarPhoto entity) {
    return CarPhotoModel(
      id: entity.id,
      carId: entity.carId,
      filePath: entity.filePath,
      createdAt: entity.createdAt,
    );
  }
}

