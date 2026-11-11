import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/vehicle_reminder_scheduler.dart';
import '../../../cars/domain/repositories/cars_repository.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final NotificationSettingsRepository settingsRepository;
  final NotificationService notificationService;
  final VehicleReminderScheduler reminderScheduler;
  final CarsRepository carsRepository;

  SettingsCubit({
    required this.settingsRepository,
    required this.notificationService,
    required this.reminderScheduler,
    required this.carsRepository,
  }) : super(const SettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final settings = await settingsRepository.getSettings();
      final hasPermission =
          await notificationService.isNotificationPermissionGranted();
      final canExact = await notificationService.canScheduleExactAlarms();
      final pendingIds =
          await notificationService.getActiveScheduledNotificationIds();

      emit(
        state.copyWith(
          status: SettingsStatus.success,
          settings: settings,
          isPermissionGranted: hasPermission,
          canScheduleExact: canExact,
          pendingNotificationIds: pendingIds,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshPendingNotifications() async {
    try {
      final pendingIds =
          await notificationService.getActiveScheduledNotificationIds();
      final canExact = await notificationService.canScheduleExactAlarms();
      final hasPermission =
          await notificationService.isNotificationPermissionGranted();
      emit(state.copyWith(
        pendingNotificationIds: pendingIds,
        canScheduleExact: canExact,
        isPermissionGranted: hasPermission,
      ));
    } catch (_) {}
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.settings.copyWith(notificationsEnabled: enabled);
    await settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    final activeCars = await carsRepository.getActiveCars();
    await reminderScheduler.rescheduleAllActiveVehicles(activeCars);
    await refreshPendingNotifications();
  }

  Future<void> toggleAdvanceReminder(bool enabled) async {
    final updated = state.settings.copyWith(advanceReminderEnabled: enabled);
    await settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    final activeCars = await carsRepository.getActiveCars();
    await reminderScheduler.rescheduleAllActiveVehicles(activeCars);
    await refreshPendingNotifications();
  }

  Future<void> setAdvanceReminderMinutes(int minutes) async {
    final updated = state.settings.copyWith(advanceReminderMinutes: minutes);
    await settingsRepository.saveSettings(updated);
    emit(state.copyWith(settings: updated));

    final activeCars = await carsRepository.getActiveCars();
    await reminderScheduler.rescheduleAllActiveVehicles(activeCars);
    await refreshPendingNotifications();
  }

  Future<void> requestNotificationPermission() async {
    final granted = await notificationService.requestNotificationPermission();
    final canExact = await notificationService.canScheduleExactAlarms();
    final pendingIds =
        await notificationService.getActiveScheduledNotificationIds();
    emit(state.copyWith(
      isPermissionGranted: granted,
      canScheduleExact: canExact,
      pendingNotificationIds: pendingIds,
    ));
  }

  Future<void> changeLanguage(String languageCode) async {
    final activeCars = await carsRepository.getActiveCars();
    await reminderScheduler.rescheduleAllActiveVehicles(activeCars, languageCode);
    await refreshPendingNotifications();
  }

  Future<void> sendTestNotification([String? languageCode]) async {
    try {
      await reminderScheduler.sendTestNotification(languageCode);
      emit(state.copyWith(message: 'test_notification_sent'));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> scheduleTestNotification10s([String? languageCode]) async {
    try {
      await reminderScheduler.scheduleTestNotification10s(languageCode);
      final pendingIds =
          await notificationService.getActiveScheduledNotificationIds();
      emit(state.copyWith(
        message: 'test_notification_scheduled_10s',
        pendingNotificationIds: pendingIds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

