// import '../../../core/database/app_database.dart';

import 'package:auto_desk/core/database/app_database.dart';

class CarModel {
  final int id;
  final String vin;
  final String? carModel;
  final String customerName;
  final DateTime timeIn;
  final DateTime estimatedTimeOut;
  final DateTime? actualTimeOut;
  final String complaint;
  final double? estimatedCost;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const CarModel({
    required this.id,
    required this.vin,
    this.carModel,
    required this.customerName,
    required this.timeIn,
    required this.estimatedTimeOut,
    this.actualTimeOut,
    required this.complaint,
    this.estimatedCost,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  CarModel copyWith({
    int? id,
    String? vin,
    String? carModel,
    String? customerName,
    DateTime? timeIn,
    DateTime? estimatedTimeOut,
    DateTime? actualTimeOut,
    String? complaint,
    double? estimatedCost,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      carModel: carModel ?? this.carModel,
      customerName: customerName ?? this.customerName,
      timeIn: timeIn ?? this.timeIn,
      estimatedTimeOut: estimatedTimeOut ?? this.estimatedTimeOut,
      actualTimeOut: actualTimeOut ?? this.actualTimeOut,
      complaint: complaint ?? this.complaint,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CarModel.fromEntity(Car car) {
    return CarModel(
      id: car.id,
      vin: car.vin,
      carModel: car.carModel,
      customerName: car.customerName,
      timeIn: car.timeIn,
      estimatedTimeOut: car.estimatedTimeOut,
      actualTimeOut: car.actualTimeOut,
      complaint: car.complaint,
      estimatedCost: car.estimatedCost,
      status: car.status,
      notes: car.notes,
      createdAt: car.createdAt,
    );
  }
}