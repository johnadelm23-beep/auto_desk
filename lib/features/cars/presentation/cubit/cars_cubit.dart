import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/car_model.dart';
import '../../data/models/car_photo_model.dart';
import '../../domain/usecases/add_car_photos_usecase.dart';
import '../../domain/usecases/add_car_usecase.dart';
import '../../domain/usecases/check_vin_unique_usecase.dart';
import '../../domain/usecases/delete_car_photo_usecase.dart';
import '../../domain/usecases/delete_car_usecase.dart';
import '../../domain/usecases/get_car_by_id_usecase.dart';
import '../../domain/usecases/get_car_photos_usecase.dart';
import '../../domain/usecases/update_car_status_usecase.dart';
import '../../domain/usecases/update_car_usecase.dart';
import '../../domain/usecases/watch_active_cars_usecase.dart';
import '../../domain/usecases/watch_all_cars_usecase.dart';
import '../../domain/usecases/watch_car_photos_usecase.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  final WatchAllCarsUseCase watchAllCarsUseCase;
  final WatchActiveCarsUseCase watchActiveCarsUseCase;
  final GetCarByIdUseCase getCarByIdUseCase;
  final AddCarUseCase addCarUseCase;
  final UpdateCarUseCase updateCarUseCase;
  final UpdateCarStatusUseCase updateCarStatusUseCase;
  final DeleteCarUseCase deleteCarUseCase;
  final WatchCarPhotosUseCase watchCarPhotosUseCase;
  final GetCarPhotosUseCase getCarPhotosUseCase;
  final AddCarPhotosUseCase addCarPhotosUseCase;
  final DeleteCarPhotoUseCase deleteCarPhotoUseCase;
  final CheckVinUniqueUseCase checkVinUniqueUseCase;

  StreamSubscription? _carsSubscription;

  CarsCubit({
    required this.watchAllCarsUseCase,
    required this.watchActiveCarsUseCase,
    required this.getCarByIdUseCase,
    required this.addCarUseCase,
    required this.updateCarUseCase,
    required this.updateCarStatusUseCase,
    required this.deleteCarUseCase,
    required this.watchCarPhotosUseCase,
    required this.getCarPhotosUseCase,
    required this.addCarPhotosUseCase,
    required this.deleteCarPhotoUseCase,
    required this.checkVinUniqueUseCase,
  }) : super(const CarsState());

  Future<void> watchCars({bool activeOnly = true}) async {
    await _carsSubscription?.cancel();

    emit(state.copyWith(status: CarsStatus.loading));

    try {
      final stream =
          activeOnly ? watchActiveCarsUseCase() : watchAllCarsUseCase();

      _carsSubscription = stream.listen(
        (cars) {
          emit(
            state.copyWith(
              status: CarsStatus.success,
              cars: cars,
            ),
          );
        },
        onError: (error) {
          emit(
            state.copyWith(
              status: CarsStatus.failure,
              errorMessage: error.toString(),
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CarsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<CarModel?> getCarById(int id) {
    return getCarByIdUseCase(id);
  }

  Future<bool> isVinUnique(String vin, {int? excludeCarId}) {
    return checkVinUniqueUseCase(vin, excludeCarId: excludeCarId);
  }

  Future<int> addCar(CarModel car, {List<String> photoPaths = const []}) {
    return addCarUseCase(car, photoPaths: photoPaths);
  }

  Future<bool> updateCar(CarModel car) {
    return updateCarUseCase(car);
  }

  Future<bool> updateCarStatus(int id, String newStatus) {
    return updateCarStatusUseCase(id, newStatus);
  }

  Future<int> deleteCar(int id) {
    return deleteCarUseCase(id);
  }

  Stream<List<CarPhotoModel>> watchCarPhotos(int carId) {
    return watchCarPhotosUseCase(carId);
  }

  Future<List<CarPhotoModel>> getCarPhotos(int carId) {
    return getCarPhotosUseCase(carId);
  }

  Future<List<CarPhotoModel>> addPhotosToCar(
    int carId,
    List<String> sourceFilePaths,
  ) {
    return addCarPhotosUseCase(carId, sourceFilePaths);
  }

  Future<bool> deleteCarPhoto(int photoId) {
    return deleteCarPhotoUseCase(photoId);
  }

  @override
  Future<void> close() async {
    await _carsSubscription?.cancel();
    return super.close();
  }
}
