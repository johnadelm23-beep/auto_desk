import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../cars/data/models/car_model.dart';

class DashboardVehicleCard extends StatelessWidget {
  final CarModel car;
  final bool isOverdueHighlight;

  const DashboardVehicleCard({
    super.key,
    required this.car,
    this.isOverdueHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy - hh:mm a');

    return InkWell(
      onTap: () {
        context.push('${AppRouter.carDetails}/${car.id}');
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isOverdueHighlight
              ? AppColors.errorBg.withValues(alpha: 0.35)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isOverdueHighlight
                ? AppColors.error.withValues(alpha: 0.45)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Icon(
                          LucideIcons.car,
                          size: 14.sp,
                          color: isOverdueHighlight
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.vin,
                              style: TextStyle(
                                fontSize: 14.sp,
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
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                StatusBadge(status: car.status, compact: true),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  LucideIcons.user,
                  size: 14.sp,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    car.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14.sp,
                  color: isOverdueHighlight
                      ? AppColors.error
                      : AppColors.textMuted,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '${'due'.tr()}: ${dateFormat.format(car.estimatedTimeOut)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isOverdueHighlight
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isOverdueHighlight
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
