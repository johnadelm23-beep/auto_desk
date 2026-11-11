import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

class PhotoPickerHelper {
  PhotoPickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Prompts the user to select photos from the gallery or take a photo with the camera.
  /// Returns a list of temporary file paths, or empty list if cancelled.
  static Future<List<String>> pickPhotos(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'add_photo'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.image,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'choose_from_gallery'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'select_multiple_photos_desc'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () =>
                    Navigator.pop(bottomSheetContext, ImageSource.gallery),
              ),
              SizedBox(height: 8.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.camera,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'take_a_photo'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'capture_vehicle_desc'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () =>
                    Navigator.pop(bottomSheetContext, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return [];

    try {
      if (source == ImageSource.camera) {
        final XFile? file = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (file != null) return [file.path];
      } else {
        final List<XFile> files = await _picker.pickMultiImage(
          imageQuality: 85,
        );
        return files.map((f) => f.path).toList();
      }
    } catch (_) {
      // Permission denied or operation cancelled
    }

    return [];
  }
}
