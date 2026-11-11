import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/car_model.dart';
import '../cubit/cars_cubit.dart';
import '../cubit/cars_state.dart';

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CarsCubit>()..watchCars(),
      child: const _CarsView(),
    );
  }
}

class _CarsView extends StatefulWidget {
  const _CarsView();

  @override
  State<_CarsView> createState() => _CarsViewState();
}

class _CarsViewState extends State<_CarsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CarModel> _applyFilters(List<CarModel> cars) {
    final query = _searchController.text.trim().toLowerCase();
    return cars.where((car) {
      final matchesQuery = query.isEmpty ||
          car.vin.toLowerCase().contains(query) ||
          (car.carModel?.toLowerCase().contains(query) ?? false) ||
          car.customerName.toLowerCase().contains(query) ||
          car.complaint.toLowerCase().contains(query);

      final matchesStatus = _selectedFilter == 'all' ||
          car.status.toLowerCase() == _selectedFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: Text(
          'cars'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addCar),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        elevation: 2,
        icon: Icon(LucideIcons.plus, size: 20.sp),
        label: Text(
          'add_car'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<CarsCubit, CarsState>(
        builder: (context, state) {
          if (state.status == CarsStatus.loading && state.cars.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CarsStatus.failure && state.cars.isEmpty) {
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
                      onPressed: () => context.read<CarsCubit>().watchCars(),
                      icon: Icon(LucideIcons.rotateCw, size: 16.sp),
                      label: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredCars = _applyFilters(state.cars);

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'search_cars'.tr(),
                    prefixIcon: Icon(LucideIcons.search, size: 18.sp),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x, size: 16.sp),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
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
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'filter_all'.tr()),
                    SizedBox(width: 8.w),
                    _buildFilterChip('received', 'filter_received'.tr()),
                    SizedBox(width: 8.w),
                    _buildFilterChip('in_progress', 'filter_in_progress'.tr()),
                    SizedBox(width: 8.w),
                    _buildFilterChip('ready', 'filter_ready'.tr()),
                  ],
                ),
              ),

              // Cars List or Empty States
              Expanded(
                child: state.cars.isEmpty
                    ? EmptyStateView(
                        icon: LucideIcons.car,
                        title: 'no_cars_yet'.tr(),
                        subtitle: 'no_cars_subtitle'.tr(),
                        action: ElevatedButton.icon(
                          onPressed: () => context.push(AppRouter.addCar),
                          icon: Icon(LucideIcons.plus, size: 18.sp),
                          label: Text('add_car'.tr()),
                        ),
                      )
                    : filteredCars.isEmpty
                        ? EmptyStateView(
                            icon: LucideIcons.searchX,
                            title: 'no_search_results'.tr(),
                            action: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedFilter = 'all';
                                });
                              },
                              child: Text('clear_filters'.tr()),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              4.h,
                              16.w,
                              80.h,
                            ),
                            itemCount: filteredCars.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              return _CarCard(car: filteredCars[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filterKey);
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.black : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
    );
  }
}

class _CarCard extends StatelessWidget {
  final CarModel car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy - hh:mm a');

    return InkWell(
      onTap: () {
        context.push('${AppRouter.carDetails}/${car.id}');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Icon(
                    LucideIcons.car,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.vin,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (car.carModel != null && car.carModel!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          car.carModel!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                StatusBadge(status: car.status),
              ],
            ),
            SizedBox(height: 14.h),
            _CarInfoRow(
              icon: LucideIcons.user,
              label: 'customer'.tr(),
              value: car.customerName,
            ),
            SizedBox(height: 8.h),
            _CarInfoRow(
              icon: LucideIcons.clock,
              label: 'due'.tr(),
              value: dateFormat.format(car.estimatedTimeOut),
            ),
            if (car.complaint.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _CarInfoRow(
                icon: LucideIcons.wrench,
                label: 'complaint'.tr(),
                value: car.complaint,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CarInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15.sp,
          color: AppColors.textMuted,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
