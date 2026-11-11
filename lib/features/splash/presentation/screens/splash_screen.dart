import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      context.go(AppRouter.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: .center,
          children: [
            Lottie.asset(
              'assets/lottie/light up (1).json',
              width: 320.w,
              repeat: false,
            ),
            SizedBox(height: 16.h),
            // BrandLogo(
            //   width: 56.w,
            //   height: 56.w,
            //   borderRadius: 12.r,
            //   showBorder: true,
            // ),
            // SizedBox(height: 12.h),
            // Text(
            //   'AutoDesk',
            //   style: TextStyle(
            //     fontSize: 24.sp,
            //     fontWeight: FontWeight.w700,
            //     color: AppColors.textPrimary,
            //     letterSpacing: 0.5,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
