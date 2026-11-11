import '../repositories/cars_repository.dart';

class DeleteCarPhotoUseCase {
  final CarsRepository repository;

  DeleteCarPhotoUseCase(this.repository);

  Future<bool> call(int photoId) {
    return repository.deleteCarPhoto(photoId);
  }
}

