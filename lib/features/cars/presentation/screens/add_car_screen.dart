import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/photo_picker_helper.dart';
import '../../data/models/car_model.dart';
import '../cubit/cars_cubit.dart';

class AddCarScreen extends StatelessWidget {
  final int? carId;

  const AddCarScreen({super.key, this.carId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CarsCubit>(),
      child: _AddCarForm(carId: carId),
    );
  }
}

class _AddCarForm extends StatefulWidget {
  final int? carId;

  const _AddCarForm({this.carId});

  @override
  State<_AddCarForm> createState() => _AddCarFormState();
}

class _AddCarFormState extends State<_AddCarForm> {
  final _formKey = GlobalKey<FormState>();

  final _vinController = TextEditingController();
  final _carModelController = TextEditingController();
  final _customerController = TextEditingController();
  final _complaintController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _timeIn = DateTime.now();
  DateTime _estimatedTimeOut = DateTime.now().add(const Duration(hours: 2));
  DateTime? _actualTimeOut;
  DateTime? _createdAt;
  String _status = 'received';

  final List<String> _selectedPhotoPaths = [];
  bool _isLoadingData = false;
  bool _isSaving = false;
  String? _loadError;

  bool get isEditing => widget.carId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadCarData();
    }
  }

  Future<void> _loadCarData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    try {
      final car = await context.read<CarsCubit>().getCarById(widget.carId!);
      if (car == null) {
        setState(() {
          _isLoadingData = false;
          _loadError = 'Car not found';
        });
        return;
      }

      if (!mounted) return;

      _vinController.text = car.vin;
      _carModelController.text = car.carModel ?? '';
      _customerController.text = car.customerName;
      _complaintController.text = car.complaint;
      _costController.text =
          car.estimatedCost != null ? car.estimatedCost!.toString() : '';
      _notesController.text = car.notes ?? '';
      _timeIn = car.timeIn;
      _estimatedTimeOut = car.estimatedTimeOut;
      _actualTimeOut = car.actualTimeOut;
      _createdAt = car.createdAt;
      _status = car.status;

      setState(() {
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
        _loadError = 'Failed to load vehicle details';
      });
    }
  }

  @override
  void dispose() {
    _vinController.dispose();
    _carModelController.dispose();
    _customerController.dispose();
    _complaintController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime({required bool isTimeIn}) async {
    final current = isTimeIn ? _timeIn : _estimatedTimeOut;

    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.black,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.black,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isTimeIn) {
        _timeIn = selected;
      } else {
        _estimatedTimeOut = selected;
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<void> _pickPhotos() async {
    final picked = await PhotoPickerHelper.pickPhotos(context);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _selectedPhotoPaths.addAll(picked);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotoPaths.removeAt(index);
    });
  }

  Widget _buildCardGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.sp, color: AppColors.primary),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18.sp, color: AppColors.textMuted)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _formatDateTime(value),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  color: AppColors.textSecondary,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, Duration duration) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.h),
      onPressed: () {
        setState(() {
          _estimatedTimeOut = DateTime.now().add(duration);
        });
      },
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    LucideIcons.camera,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  isEditing ? 'add_photo'.tr() : 'vehicle_photos'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedPhotoPaths.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_selectedPhotoPaths.length}',
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
              onPressed: _pickPhotos,
              icon: Icon(LucideIcons.imagePlus, size: 16.sp),
              label: Text(
                'select_photos'.tr(),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (_selectedPhotoPaths.isEmpty)
          InkWell(
            onTap: _pickPhotos,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.camera,
                    color: AppColors.primary,
                    size: 30.sp,
                  ),
                  SizedBox(height: 8.h),
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
            height: 96.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotoPaths.length + 1,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                if (index == _selectedPhotoPaths.length) {
                  return InkWell(
                    onTap: _pickPhotos,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 90.w,
                      height: 96.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.plus,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'add_photo'.tr(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final path = _selectedPhotoPaths[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90.w,
                      height: 96.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11.r),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppColors.surface,
                            child: Icon(
                              LucideIcons.imageOff,
                              color: AppColors.textMuted,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.x,
                            size: 12.sp,
                            color: Colors.white,
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
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_estimatedTimeOut.isAfter(_timeIn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Estimated time out must be after time in',
          ),
        ),
      );
      return;
    }

    final cubit = context.read<CarsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    final formattedVin = _vinController.text.trim().toUpperCase();
    final carModelText = _carModelController.text.trim();
    final carModelValue = carModelText.isEmpty ? null : carModelText;

    // Validate VIN uniqueness while allowing the current car to retain its own VIN
    final isUnique = await cubit.isVinUnique(
      formattedVin,
      excludeCarId: widget.carId,
    );

    if (!isUnique) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('This VIN already exists')),
        );
      }
      return;
    }

    try {
      if (isEditing) {
        final updatedCar = CarModel(
          id: widget.carId!,
          vin: formattedVin,
          carModel: carModelValue,
          customerName: _customerController.text.trim(),
          timeIn: _timeIn,
          estimatedTimeOut: _estimatedTimeOut,
          actualTimeOut: _actualTimeOut,
          complaint: _complaintController.text.trim(),
          estimatedCost: _costController.text.trim().isEmpty
              ? null
              : double.parse(_costController.text.trim()),
          status: _status,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: _createdAt ?? DateTime.now(),
        );

        await cubit.updateCar(updatedCar);

        if (_selectedPhotoPaths.isNotEmpty) {
          await cubit.addPhotosToCar(widget.carId!, _selectedPhotoPaths);
        }

        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Car updated successfully'),
          ),
        );

        context.pop(true);
      } else {
        final newCar = CarModel(
          id: 0,
          vin: formattedVin,
          carModel: carModelValue,
          customerName: _customerController.text.trim(),
          timeIn: _timeIn,
          estimatedTimeOut: _estimatedTimeOut,
          actualTimeOut: null,
          complaint: _complaintController.text.trim(),
          estimatedCost: _costController.text.trim().isEmpty
              ? null
              : double.parse(_costController.text.trim()),
          status: 'received',
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now(),
        );

        await cubit.addCar(
          newCar,
          photoPaths: _selectedPhotoPaths,
        );

        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Car added successfully'),
          ),
        );

        context.pop(true);
      }
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().toLowerCase().contains('unique')
          ? 'This VIN already exists'
          : 'Failed to save car. Please try again';

      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditing ? 'edit_car'.tr() : 'add_new_car'.tr();
    final buttonLabel = isEditing ? 'edit_car'.tr() : 'save_car'.tr();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.check, size: 22.sp, color: AppColors.primary),
            tooltip: buttonLabel,
            onPressed: _isSaving ? null : _submitForm,
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _loadError != null
              ? Center(
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
                      SizedBox(height: 12.h),
                      Text(
                        _loadError!,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadCarData,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                    children: [
                      // Section 1: Vehicle & Customer Information
                      _buildCardGroup(
                        title: 'vehicle_information'.tr(),
                        icon: LucideIcons.car,
                        children: [
                          _buildField(
                            label: 'vin_chassis'.tr(),
                            controller: _vinController,
                            hint: 'Enter VIN (e.g. 1HGCR2F83HA...)',
                            prefixIcon: LucideIcons.hash,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'VIN is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            label: 'car_model'.tr(),
                            controller: _carModelController,
                            hint: 'enter_car_model'.tr(),
                            prefixIcon: LucideIcons.car,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'car_model_required'.tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            label: 'customer_name'.tr(),
                            controller: _customerController,
                            hint: 'Enter customer name',
                            prefixIcon: LucideIcons.user,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Customer name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            label: 'customer_complaint'.tr(),
                            controller: _complaintController,
                            hint: 'Describe the vehicle problem or requested service...',
                            prefixIcon: LucideIcons.wrench,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Complaint is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 14.h),
                          _buildField(
                            label: 'estimated_cost'.tr(),
                            controller: _costController,
                            hint: 'Enter estimated cost (e.g. 150.00)',
                            prefixIcon: LucideIcons.dollarSign,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              if (double.tryParse(value.trim()) == null ||
                                  double.parse(value.trim()) < 0) {
                                return 'Enter a valid cost';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Section 2: Timing & Schedule
                      _buildCardGroup(
                        title: 'estimated_out'.tr(),
                        icon: LucideIcons.clock,
                        children: [
                          _buildDateField(
                            label: 'time_in'.tr(),
                            value: _timeIn,
                            onTap: () => _selectDateTime(isTimeIn: true),
                          ),
                          SizedBox(height: 14.h),
                          _buildDateField(
                            label: 'estimated_out'.tr(),
                            value: _estimatedTimeOut,
                            onTap: () => _selectDateTime(isTimeIn: false),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: [
                              _buildPresetChip('+2 min', const Duration(minutes: 2)),
                              _buildPresetChip('+15 min', const Duration(minutes: 15)),
                              _buildPresetChip('+2 hrs', const Duration(hours: 2)),
                              _buildPresetChip('+1 day', const Duration(days: 1)),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Section 3: Notes & Photos
                      _buildCardGroup(
                        title: 'additional_notes'.tr(),
                        icon: LucideIcons.fileText,
                        children: [
                          _buildField(
                            label: 'additional_notes'.tr(),
                            controller: _notesController,
                            hint: 'Any additional workshop notes...',
                            maxLines: 3,
                          ),
                          SizedBox(height: 16.h),
                          _buildPhotosSection(),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Submit Button
                      SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submitForm,
                          child: _isSaving
                              ? SizedBox(
                                  height: 22.h,
                                  width: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  buttonLabel,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
