import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.16),
            height: 64.h,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            elevation: 0,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  LucideIcons.layoutDashboard,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                selectedIcon: Icon(
                  LucideIcons.layoutDashboard,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
                label: 'dashboard'.tr(),
              ),
              NavigationDestination(
                icon: Icon(
                  LucideIcons.car,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                selectedIcon: Icon(
                  LucideIcons.car,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
                label: 'cars'.tr(),
              ),
              NavigationDestination(
                icon: Icon(
                  LucideIcons.history,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                selectedIcon: Icon(
                  LucideIcons.history,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
                label: 'history'.tr(),
              ),
              NavigationDestination(
                icon: Icon(
                  LucideIcons.settings,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                selectedIcon: Icon(
                  LucideIcons.settings,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
                label: 'settings'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
