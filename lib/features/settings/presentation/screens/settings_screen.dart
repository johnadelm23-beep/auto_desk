import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.cubit});

  final SettingsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!..loadSettings(),
        child: const _SettingsView(),
      );
    }
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = const Locale('en');
    try {
      currentLocale = context.locale;
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: Text(
          'settings'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) =>
            curr.message != null || curr.errorMessage != null,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!.tr()),
                backgroundColor: AppColors.surface,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 36.h),
            children: [
              // General Settings Card (Material prevents ListTile ink splash assertions)
              Material(
                color: AppColors.card,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        LucideIcons.globe,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'language'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: currentLocale.languageCode,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox(),
                        icon: Icon(
                          LucideIcons.chevronDown,
                          size: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              'english'.tr(),
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(
                              'arabic'.tr(),
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                        ],
                        onChanged: (lang) {
                          if (lang != null) {
                            try {
                              context.setLocale(Locale(lang));
                            } catch (_) {}
                            cubit.changeLanguage(lang);
                          }
                        },
                      ),
                    ),
                    Divider(color: AppColors.borderSubtle, height: 1.h),
                    ListTile(
                      leading: Icon(
                        LucideIcons.moon,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'theme'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        'dark_theme'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Divider(color: AppColors.borderSubtle, height: 1.h),
                    ListTile(
                      leading: Icon(
                        LucideIcons.info,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'version'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Notifications Section Header
              Text(
                'notifications'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),

              // Notifications Settings Card
              Material(
                color: AppColors.card,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Notification Permission Status
                    ListTile(
                      leading: Icon(
                        state.isPermissionGranted
                            ? LucideIcons.bellRing
                            : LucideIcons.bellOff,
                        color: state.isPermissionGranted
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20.sp,
                      ),
                      title: Text(
                        'permission_status'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: !state.isPermissionGranted
                          ? Text(
                              'permission_required_desc'.tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.warning,
                              ),
                            )
                          : null,
                      trailing: state.isPermissionGranted
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'permission_granted'.tr(),
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : OutlinedButton(
                              onPressed: cubit.requestNotificationPermission,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.warning,
                                side:
                                    const BorderSide(color: AppColors.warning),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                              ),
                              child: Text(
                                'request_permission'.tr(),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                    ),

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Exact Timing Status Tile
                    ListTile(
                      leading: Icon(
                        state.canScheduleExact
                            ? LucideIcons.alarmCheck
                            : LucideIcons.alarmClock,
                        color: state.canScheduleExact
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'exact_alarm_status'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        state.canScheduleExact
                            ? 'exact_alarm_granted'.tr()
                            : 'exact_alarm_desc'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: state.canScheduleExact
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: state.canScheduleExact
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          state.canScheduleExact
                              ? 'exact_alarm_granted'.tr()
                              : 'exact_alarm_inexact'.tr(),
                          style: TextStyle(
                            color: state.canScheduleExact
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Enable / Disable Reminders Toggle
                    SwitchListTile(
                      activeThumbColor: AppColors.primary,
                      secondary: Icon(
                        LucideIcons.bell,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'enable_notifications'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'enable_notifications_desc'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: state.settings.notificationsEnabled,
                      onChanged: cubit.toggleNotifications,
                    ),

                    if (state.settings.notificationsEnabled) ...[
                      Divider(color: AppColors.borderSubtle, height: 1.h),

                      // Advance Reminder Toggle
                      SwitchListTile(
                        activeThumbColor: AppColors.primary,
                        secondary: Icon(
                          LucideIcons.timer,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        title: Text(
                          'enable_advance_reminder'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'advance_reminder_desc'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        value: state.settings.advanceReminderEnabled,
                        onChanged: cubit.toggleAdvanceReminder,
                      ),

                      if (state.settings.advanceReminderEnabled) ...[
                        Divider(color: AppColors.borderSubtle, height: 1.h),

                        // Advance Interval (15 or 30 minutes)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'reminder_time'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<int>(
                                  segments: [
                                    ButtonSegment<int>(
                                      value: 15,
                                      label: Text(
                                        'minutes_15'.tr(),
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                    ButtonSegment<int>(
                                      value: 30,
                                      label: Text(
                                        'minutes_30'.tr(),
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                  selected: {
                                    state.settings.advanceReminderMinutes
                                  },
                                  onSelectionChanged: (selected) {
                                    cubit.setAdvanceReminderMinutes(
                                      selected.first,
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return AppColors.primary;
                                        }
                                        return AppColors.surface;
                                      },
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.resolveWith(
                                      (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return AppColors.black;
                                        }
                                        return AppColors.textPrimary;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Test Notification Action Button
                    Padding(
                      padding: EdgeInsets.all(14.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => cubit
                              .sendTestNotification(currentLocale.languageCode),
                          icon: Icon(
                            LucideIcons.bellPlus,
                            size: 16.sp,
                          ),
                          label: Text(
                            'send_test_notification'.tr(),
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Diagnostics Section Header
              Text(
                'diagnostics'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),

              // Diagnostics Card
              Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // POST_NOTIFICATIONS Permission Status
                    ListTile(
                      leading: Icon(
                        state.isPermissionGranted
                            ? LucideIcons.shieldCheck
                            : LucideIcons.shieldAlert,
                        color: state.isPermissionGranted
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20.sp,
                      ),
                      title: Text(
                        'permission_status'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'POST_NOTIFICATIONS',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        state.isPermissionGranted
                            ? 'permission_granted'.tr()
                            : 'permission_denied'.tr(),
                        style: TextStyle(
                          color: state.isPermissionGranted
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Scheduling Mode / Exact Alarm Capability
                    ListTile(
                      leading: Icon(
                        state.canScheduleExact
                            ? LucideIcons.clock
                            : LucideIcons.batteryMedium,
                        color: state.canScheduleExact
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'scheduling_mode'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        state.canScheduleExact
                            ? 'scheduling_mode_exact'.tr()
                            : 'scheduling_mode_inexact'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Pending Scheduled Notification IDs
                    ListTile(
                      leading: Icon(
                        LucideIcons.listOrdered,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      title: Text(
                        'pending_notifications'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        state.pendingNotificationIds.isEmpty
                            ? 'no_pending_notifications'.tr()
                            : 'IDs: [${state.pendingNotificationIds.join(', ')}]',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: state.pendingNotificationIds.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.primary,
                          fontWeight: state.pendingNotificationIds.isEmpty
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          LucideIcons.refreshCw,
                          color: AppColors.textSecondary,
                          size: 18.sp,
                        ),
                        onPressed: cubit.refreshPendingNotifications,
                      ),
                    ),

                    Divider(color: AppColors.borderSubtle, height: 1.h),

                    // Test Action Buttons
                    Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => cubit.sendTestNotification(
                                currentLocale.languageCode,
                              ),
                              icon: Icon(LucideIcons.zap, size: 16.sp),
                              label: Text(
                                'send_immediate_notification'.tr(),
                                style: TextStyle(fontSize: 13.sp),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => cubit.scheduleTestNotification10s(
                                currentLocale.languageCode,
                              ),
                              icon: Icon(LucideIcons.timer, size: 16.sp),
                              label: Text(
                                'schedule_test_10s'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.black,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }
}
