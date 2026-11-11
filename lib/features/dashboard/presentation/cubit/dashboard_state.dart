import '../../domain/entities/dashboard_data.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState {
  final DashboardStatus status;
  final DashboardData data;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data = const DashboardData(),
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

