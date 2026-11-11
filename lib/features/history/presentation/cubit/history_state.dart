import '../../../cars/data/models/car_model.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState {
  final HistoryStatus status;
  final List<CarModel> cars;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAscending;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.cars = const [],
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.isAscending = false,
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<CarModel>? cars,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAscending,
    String? errorMessage,
    bool clearDates = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      cars: cars ?? this.cars,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      isAscending: isAscending ?? this.isAscending,
      errorMessage: errorMessage,
    );
  }
}

