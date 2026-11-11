import '../../data/models/notification_settings_model.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState {
  final SettingsStatus status;
  final NotificationSettingsModel settings;
  final bool isPermissionGranted;
  final bool canScheduleExact;
  final List<int> pendingNotificationIds;
  final String? errorMessage;
  final String? message;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const NotificationSettingsModel(),
    this.isPermissionGranted = true,
    this.canScheduleExact = true,
    this.pendingNotificationIds = const [],
    this.errorMessage,
    this.message,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    NotificationSettingsModel? settings,
    bool? isPermissionGranted,
    bool? canScheduleExact,
    List<int>? pendingNotificationIds,
    String? errorMessage,
    String? message,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      canScheduleExact: canScheduleExact ?? this.canScheduleExact,
      pendingNotificationIds:
          pendingNotificationIds ?? this.pendingNotificationIds,
      errorMessage: errorMessage,
      message: message,
    );
  }
}

