import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/watch_dashboard_data_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final WatchDashboardDataUseCase watchDashboardDataUseCase;
  final GetDashboardDataUseCase getDashboardDataUseCase;

  StreamSubscription? _subscription;

  DashboardCubit({
    required this.watchDashboardDataUseCase,
    required this.getDashboardDataUseCase,
  }) : super(const DashboardState());

  Future<void> watchDashboard({DateTime? now}) async {
    await _subscription?.cancel();
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      _subscription = watchDashboardDataUseCase(now: now).listen(
        (data) {
          emit(state.copyWith(
            status: DashboardStatus.success,
            data: data,
          ));
        },
        onError: (error) {
          emit(state.copyWith(
            status: DashboardStatus.failure,
            errorMessage: error.toString(),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh({DateTime? now}) async {
    try {
      final data = await getDashboardDataUseCase(now: now);
      emit(state.copyWith(
        status: DashboardStatus.success,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

