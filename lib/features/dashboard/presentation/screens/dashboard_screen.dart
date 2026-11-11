import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_vehicle_card.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..watchDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: Row(
          children: [
            BrandLogo(
              width: 38.w,
              height: 38.w,
              borderRadius: 10.r,
              showBorder: true,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'owner_name'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height:1.h ,),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: IconButton.filledTonal(
              icon: Icon(
                LucideIcons.plus,
                size: 20.sp,
                color: AppColors.black,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.all(8.r),
              ),
              tooltip: 'add_car'.tr(),
              onPressed: () => context.push(AppRouter.addCar),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading &&
              state.data.stats.totalCars == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.failure &&
              state.data.stats.totalCars == 0) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: const BoxDecoration(
                        color: AppColors.errorBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.alertOctagon,
                        size: 36.sp,
                        color: AppColors.error,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'something_went_wrong'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 18.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DashboardCubit>().watchDashboard();
                      },
                      icon: Icon(LucideIcons.rotateCw, size: 16.sp),
                      label: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = state.data;
          final stats = data.stats;

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().refresh(),
            color: AppColors.primary,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              children: [
                _buildStatsGrid(context, stats),
                SizedBox(height: 24.h),
                DashboardSection(
                  title: 'overdue_vehicles'.tr(),
                  icon: LucideIcons.alertTriangle,
                  iconColor: AppColors.error,
                  count: stats.overdue,
                  onViewAll: () => context.go(AppRouter.cars),
                  content: data.overdueCars.isEmpty
                      ? _buildEmptyState(
                          icon: LucideIcons.checkCircle2,
                          message: 'no_overdue_vehicles'.tr(),
                          color: AppColors.success,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.overdueCars.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) => DashboardVehicleCard(
                            car: data.overdueCars[index],
                            isOverdueHighlight: true,
                          ),
                        ),
                ),
                SizedBox(height: 24.h),
                DashboardSection(
                  title: 'upcoming_deliveries'.tr(),
                  icon: LucideIcons.alarmClock,
                  iconColor: const Color(0xFF38BDF8),
                  count: stats.upcomingDeliveries,
                  onViewAll: () => context.go(AppRouter.cars),
                  content: data.upcomingCars.isEmpty
                      ? _buildEmptyState(
                          icon: LucideIcons.calendar,
                          message: 'no_upcoming_deliveries'.tr(),
                          color: AppColors.textMuted,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.upcomingCars.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) => DashboardVehicleCard(
                            car: data.upcomingCars[index],
                          ),
                        ),
                ),
                SizedBox(height: 24.h),
                DashboardSection(
                  title: 'recent_vehicles'.tr(),
                  icon: LucideIcons.car,
                  iconColor: AppColors.primary,
                  count: stats.totalCars,
                  onViewAll: () => context.go(AppRouter.cars),
                  content: data.recentCars.isEmpty
                      ? _buildEmptyState(
                          icon: LucideIcons.car,
                          message: 'no_recent_vehicles'.tr(),
                          color: AppColors.textMuted,
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.recentCars.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) => DashboardVehicleCard(
                            car: data.recentCars[index],
                          ),
                        ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'total_cars'.tr(),
                value: stats.totalCars,
                icon: LucideIcons.car,
                color: AppColors.primary,
                onTap: () => context.go(AppRouter.cars),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: StatCard(
                title: 'received_today'.tr(),
                value: stats.receivedToday,
                icon: LucideIcons.calendarCheck,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'in_progress'.tr(),
                value: stats.inProgress,
                icon: LucideIcons.wrench,
                color: const Color(0xFFFBBF24),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: StatCard(
                title: 'ready'.tr(),
                value: stats.ready,
                icon: LucideIcons.checkCircle2,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'overdue'.tr(),
                value: stats.overdue,
                icon: LucideIcons.alertTriangle,
                color: AppColors.error,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: StatCard(
                title: 'upcoming_24h'.tr(),
                value: stats.upcomingDeliveries,
                icon: LucideIcons.alarmClock,
                color: const Color(0xFF38BDF8),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        StatCard(
          title: 'delivered'.tr(),
          value: stats.delivered,
          icon: LucideIcons.checkCheck,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
