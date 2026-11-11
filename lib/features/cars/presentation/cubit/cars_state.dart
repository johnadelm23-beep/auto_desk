import '../../data/models/car_model.dart';

enum CarsStatus {
  initial,
  loading,
  success,
  failure,
}

class CarsState {
  final CarsStatus status;
  final List<CarModel> cars;
  final String? errorMessage;

  const CarsState({
    this.status = CarsStatus.initial,
    this.cars = const [],
    this.errorMessage,
  });

  CarsState copyWith({
    CarsStatus? status,
    List<CarModel>? cars,
    String? errorMessage,
  }) {
    return CarsState(
      status: status ?? this.status,
      cars: cars ?? this.cars,
      errorMessage: errorMessage,
    );
  }
}