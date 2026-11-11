import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/history_car_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryCubit>()..watchHistory(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    final currentStart = cubit.state.startDate ?? DateTime.now();
    final currentEnd = cubit.state.endDate ?? DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange:
          cubit.state.startDate != null && cubit.state.endDate != null
              ? DateTimeRange(start: currentStart, end: currentEnd)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      cubit.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: Text(
          'history'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          final cubit = context.read<HistoryCubit>();
          final hasActiveFilter = state.searchQuery.isNotEmpty ||
              state.startDate != null ||
              state.endDate != null;

          return Column(
            children: [
              // Search & Filter Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: cubit.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'search_vin_or_customer'.tr(),
                        prefixIcon: Icon(LucideIcons.search, size: 18.sp),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(LucideIcons.x, size: 16.sp),
                                onPressed: () {
                                  _searchController.clear();
                                  cubit.setSearchQuery('');
                                },
                              )
                            : null,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Date Filter Chip
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDateRange(context),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: state.startDate != null
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: state.startDate != null
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.calendar,
                                    size: 15.sp,
                                    color: state.startDate != null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      state.startDate != null &&
                                              state.endDate != null
                                          ? '${dateFormat.format(state.startDate!)} - ${dateFormat.format(state.endDate!)}'
                                          : 'all_dates'.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: state.startDate != null
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: state.startDate != null
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  if (state.startDate != null)
                                    GestureDetector(
                                      onTap: cubit.clearDateFilter,
                                      child: Icon(
                                        LucideIcons.x,
                                        size: 14.sp,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Sort Toggle Button
                        InkWell(
                          onTap: cubit.toggleSort,
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.arrowUpDown,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  state.isAscending
                                      ? 'oldest_first'.tr()
                                      : 'newest_first'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter summary if active
              if (hasActiveFilter)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.cars.length} ${'delivered_vehicles'.tr()}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          cubit.setSearchQuery('');
                          cubit.clearDateFilter();
                        },
                        icon: Icon(LucideIcons.rotateCcw, size: 12.sp),
                        label: Text(
                          'clear_filters'.tr(),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),

              // Content List
              Expanded(
                child: state.status == HistoryStatus.loading &&
                        state.cars.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.status == HistoryStatus.failure
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.alertOctagon,
                                    size: 40.sp,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'something_went_wrong'.tr(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton(
                                    onPressed: () =>
                                        context.read<HistoryCubit>().watchHistory(),
                                    child: Text('retry'.tr()),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : state.cars.isEmpty
                            ? (hasActiveFilter
                                ? EmptyStateView(
                                    icon: LucideIcons.searchX,
                                    title: 'no_history_match'.tr(),
                                    action: OutlinedButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        cubit.setSearchQuery('');
                                        cubit.clearDateFilter();
                                      },
                                      child: Text('clear_filters'.tr()),
                                    ),
                                  )
                                : EmptyStateView(
                                    icon: LucideIcons.history,
                                    title: 'no_history_yet'.tr(),
                                    subtitle: 'no_history_description'.tr(),
                                  ))
                            : ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  4.h,
                                  16.w,
                                  24.h,
                                ),
                                itemCount: state.cars.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12.h),
                                itemBuilder: (context, index) {
                                  return HistoryCarCard(
                                    car: state.cars[index],
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}
