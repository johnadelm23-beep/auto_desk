import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool showBorder;

  const BrandLogo({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.showBorder = false,
  });

  static const String logoAsset = 'assets/images/auto_desk_logo.jpg';

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 8.r;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: AppColors.border, width: 1)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          logoAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

