import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.w : 10.w,
        vertical: compact ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: config.foregroundColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            config.labelKey.tr(),
            style: TextStyle(
              fontSize: compact ? 11.sp : 12.sp,
              fontWeight: FontWeight.w700,
              color: config.foregroundColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in-progress':
        return _StatusConfig(
          labelKey: 'in_progress',
          foregroundColor: const Color(0xFF60A5FA),
          backgroundColor: const Color(0xFF1E2A3A),
          borderColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
        );
      case 'ready':
        return _StatusConfig(
          labelKey: 'ready',
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          borderColor: AppColors.primary.withValues(alpha: 0.35),
        );
      case 'delivered':
        return _StatusConfig(
          labelKey: 'delivered',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successBg,
          borderColor: AppColors.success.withValues(alpha: 0.35),
        );
      case 'received':
      default:
        return _StatusConfig(
          labelKey: 'received',
          foregroundColor: const Color(0xFFA78BFA),
          backgroundColor: const Color(0xFF241E38),
          borderColor: const Color(0xFF7C3AED).withValues(alpha: 0.35),
        );
    }
  }
}

class _StatusConfig {
  final String labelKey;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusConfig({
    required this.labelKey,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}

