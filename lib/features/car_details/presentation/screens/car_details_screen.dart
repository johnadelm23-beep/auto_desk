import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/photo_picker_helper.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../cars/data/models/car_model.dart';
import '../../../cars/data/models/car_photo_model.dart';
import '../../../cars/presentation/cubit/cars_cubit.dart';

class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({
    super.key,
    required this.carId,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  late final CarsCubit _carsCubit;
  late Future<CarModel?> _carFuture;
  late final Stream<List<CarPhotoModel>> _photosStream;

  @override
  void initState() {
    super.initState();
    _carsCubit = sl<CarsCubit>();
    _carFuture = _carsCubit.getCarById(widget.carId);
    _photosStream = _carsCubit.watchCarPhotos(widget.carId);
  }

  @override
  void dispose() {
    _carsCubit.close();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final picked = await PhotoPickerHelper.pickPhotos(context);
    if (picked.isEmpty || !mounted) return;

    try {
      await _carsCubit.addPhotosToCar(widget.carId, picked);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${picked.length} ${'photos_added_successfully'.tr()}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_save_photos'.tr())),
      );
    }
  }

  Future<void> _confirmDeletePhoto(CarPhotoModel photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('delete_photo'.tr()),
        content: Text('delete_photo_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _carsCubit.deleteCarPhoto(photo.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('photo_deleted_successfully'.tr())),
      );
    }
  }

  Future<void> _navigateToEdit() async {
    final updated =
        await context.push<bool>('${AppRouter.editCar}/${widget.carId}');
    if (updated == true && mounted) {
      setState(() {
        _carFuture = _carsCubit.getCarById(widget.carId);
      });
    }
  }

  Future<void> _confirmDeleteCar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('delete_car'.tr()),
        content: Text('delete_car_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _carsCubit.deleteCar(widget.carId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('car_and_photos_deleted'.tr())),
      );
      context.pop();
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    try {
      await _carsCubit.updateCarStatus(widget.carId, newStatus);
      if (!mounted) return;
      setState(() {
        _carFuture = _carsCubit.getCarById(widget.carId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('status_updated'.tr()),
          backgroundColor: AppColors.surface,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('something_went_wrong'.tr()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPhotoViewer(CarPhotoModel photo) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
              title: Text(
                DateFormat('dd MMM yyyy - hh:mm a').format(photo.createdAt),
                style: TextStyle(fontSize: 13.sp, color: Colors.white70),
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.trash2, color: AppColors.error),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _confirmDeletePhoto(photo);
                  },
                ),
              ],
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(photo.filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200.h,
                    color: AppColors.surface,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.imageOff,
                            color: AppColors.textMuted,
                            size: 40.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'image_unavailable'.tr(),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildStatusMenuItem(
    String status,
    String label,
    Color color,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: status,
      child: Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            Icon(LucideIcons.check, size: 16.sp, color: AppColors.primary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('car_details'.tr()),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.pencil, size: 20.sp),
            tooltip: 'edit_car'.tr(),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 20.sp, color: AppColors.error),
            tooltip: 'delete_car'.tr(),
            onPressed: _confirmDeleteCar,
          ),
        ],
      ),
      body: FutureBuilder<CarModel?>(
        future: _carFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('something_went_wrong'.tr()),
            );
          }

          final car = snapshot.data;

          if (car == null) {
            return Center(
              child: Text('no_recent_vehicles'.tr()),
            );
          }

          return _buildDetails(car);
        },
      ),
    );
  }

  Widget _buildDetails(CarModel car) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
      children: [
        // Hero Card with VIN & Status Action
        Container(
          padding: EdgeInsets.all(18.w),
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
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      LucideIcons.car,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.vin,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (car.carModel != null && car.carModel!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            car.carModel!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: car.status),
                  PopupMenuButton<String>(
                    tooltip: 'change_status'.tr(),
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onSelected: _changeStatus,
                    itemBuilder: (context) => [
                      _buildStatusMenuItem(
                        'received',
                        'status_received'.tr(),
                        const Color(0xFFA78BFA),
                        car.status == 'received',
                      ),
                      _buildStatusMenuItem(
                        'in_progress',
                        'status_in_progress'.tr(),
                        const Color(0xFF60A5FA),
                        car.status == 'in_progress',
                      ),
                      _buildStatusMenuItem(
                        'ready',
                        'status_ready'.tr(),
                        AppColors.primary,
                        car.status == 'ready',
                      ),
                      _buildStatusMenuItem(
                        'delivered',
                        'status_delivered'.tr(),
                        AppColors.success,
                        car.status == 'delivered',
                      ),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.arrowLeftRight,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'change_status'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
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

        SizedBox(height: 16.h),

        // Photos Section
        _buildPhotosSection(),

        SizedBox(height: 16.h),

        // Information Card
        Container(
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
                  Icon(
                    LucideIcons.fileText,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'vehicle_information'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildInfo('customer_name'.tr(), car.customerName),
              _buildInfo('vin_chassis'.tr(), car.vin),
              if (car.carModel != null && car.carModel!.isNotEmpty)
                _buildInfo('car_model'.tr(), car.carModel!),
              _buildInfo(
                'time_in'.tr(),
                DateFormat('dd MMM yyyy - hh:mm a').format(car.timeIn),
              ),
              _buildInfo(
                'estimated_out'.tr(),
                DateFormat('dd MMM yyyy - hh:mm a').format(car.estimatedTimeOut),
              ),
              if (car.actualTimeOut != null) ...[
                _buildInfo(
                  'actual_delivery'.tr(),
                  DateFormat('dd MMM yyyy - hh:mm a').format(car.actualTimeOut!),
                ),
                _buildInfo(
                  'delivery_duration'.tr(),
                  DurationFormatter.format(car.timeIn, car.actualTimeOut!),
                ),
              ],
              if (car.estimatedCost != null)
                _buildInfo(
                  'estimated_cost'.tr(),
                  '\$${car.estimatedCost!.toStringAsFixed(2)}',
                ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Customer Complaint Card
        Container(
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
                  Icon(
                    LucideIcons.wrench,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'customer_complaint'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                car.complaint,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        if (car.notes != null && car.notes!.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(
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
                    Icon(
                      LucideIcons.info,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'additional_notes'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  car.notes!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotosSection() {
    return StreamBuilder<List<CarPhotoModel>>(
      stream: _photosStream,
      builder: (context, snapshot) {
        final photos = snapshot.data ?? [];

        return Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.camera,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'vehicle_photos'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (photos.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${photos.length}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _addPhotos,
                    icon: Icon(LucideIcons.imagePlus, size: 16.sp),
                    label: Text(
                      'add_photo'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (photos.isEmpty)
                InkWell(
                  onTap: _addPhotos,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.camera,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'no_photos_attached'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 105.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, _) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final photo = photos[index];

                      return Stack(
                        children: [
                          InkWell(
                            onTap: () => _showPhotoViewer(photo),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: 105.w,
                              height: 105.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11.r),
                                child: Image.file(
                                  File(photo.filePath),
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Container(
                                    color: AppColors.surface,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.imageOff,
                                            color: AppColors.textMuted,
                                            size: 24.sp,
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'image_unavailable'.tr(),
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _confirmDeletePhoto(photo),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.trash2,
                                  size: 13.sp,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfo(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
