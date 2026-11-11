import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_delivered_cars_usecase.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final WatchDeliveredCarsUseCase watchDeliveredCarsUseCase;

  StreamSubscription? _subscription;

  HistoryCubit({
    required this.watchDeliveredCarsUseCase,
  }) : super(const HistoryState());

  Future<void> watchHistory() async {
    await _subscription?.cancel();
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      _subscription = watchDeliveredCarsUseCase(
        searchQuery: state.searchQuery,
        startDate: state.startDate,
        endDate: state.endDate,
        ascending: state.isAscending,
      ).listen(
        (cars) {
          emit(state.copyWith(
            status: HistoryStatus.success,
            cars: cars,
          ));
        },
        onError: (error) {
          emit(state.copyWith(
            status: HistoryStatus.failure,
            errorMessage: error.toString(),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    emit(state.copyWith(searchQuery: query));
    watchHistory();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    emit(state.copyWith(
      startDate: start,
      endDate: end,
      clearDates: start == null && end == null,
    ));
    watchHistory();
  }

  void clearDateFilter() {
    emit(state.copyWith(clearDates: true));
    watchHistory();
  }

  void toggleSort() {
    emit(state.copyWith(isAscending: !state.isAscending));
    watchHistory();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

