// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CarsTable extends Cars with TableInfo<$CarsTable, Car> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _carModelMeta = const VerificationMeta(
    'carModel',
  );
  @override
  late final GeneratedColumn<String> carModel = GeneratedColumn<String>(
    'car_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeInMeta = const VerificationMeta('timeIn');
  @override
  late final GeneratedColumn<DateTime> timeIn = GeneratedColumn<DateTime>(
    'time_in',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedTimeOutMeta = const VerificationMeta(
    'estimatedTimeOut',
  );
  @override
  late final GeneratedColumn<DateTime> estimatedTimeOut =
      GeneratedColumn<DateTime>(
        'estimated_time_out',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actualTimeOutMeta = const VerificationMeta(
    'actualTimeOut',
  );
  @override
  late final GeneratedColumn<DateTime> actualTimeOut =
      GeneratedColumn<DateTime>(
        'actual_time_out',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _complaintMeta = const VerificationMeta(
    'complaint',
  );
  @override
  late final GeneratedColumn<String> complaint = GeneratedColumn<String>(
    'complaint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedCostMeta = const VerificationMeta(
    'estimatedCost',
  );
  @override
  late final GeneratedColumn<double> estimatedCost = GeneratedColumn<double>(
    'estimated_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('received'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vin,
    carModel,
    customerName,
    timeIn,
    estimatedTimeOut,
    actualTimeOut,
    complaint,
    estimatedCost,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cars';
  @override
  VerificationContext validateIntegrity(
    Insertable<Car> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    } else if (isInserting) {
      context.missing(_vinMeta);
    }
    if (data.containsKey('car_model')) {
      context.handle(
        _carModelMeta,
        carModel.isAcceptableOrUnknown(data['car_model']!, _carModelMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('time_in')) {
      context.handle(
        _timeInMeta,
        timeIn.isAcceptableOrUnknown(data['time_in']!, _timeInMeta),
      );
    } else if (isInserting) {
      context.missing(_timeInMeta);
    }
    if (data.containsKey('estimated_time_out')) {
      context.handle(
        _estimatedTimeOutMeta,
        estimatedTimeOut.isAcceptableOrUnknown(
          data['estimated_time_out']!,
          _estimatedTimeOutMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedTimeOutMeta);
    }
    if (data.containsKey('actual_time_out')) {
      context.handle(
        _actualTimeOutMeta,
        actualTimeOut.isAcceptableOrUnknown(
          data['actual_time_out']!,
          _actualTimeOutMeta,
        ),
      );
    }
    if (data.containsKey('complaint')) {
      context.handle(
        _complaintMeta,
        complaint.isAcceptableOrUnknown(data['complaint']!, _complaintMeta),
      );
    } else if (isInserting) {
      context.missing(_complaintMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
        _estimatedCostMeta,
        estimatedCost.isAcceptableOrUnknown(
          data['estimated_cost']!,
          _estimatedCostMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Car map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Car(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      )!,
      carModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}car_model'],
      ),
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      timeIn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time_in'],
      )!,
      estimatedTimeOut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}estimated_time_out'],
      )!,
      actualTimeOut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_time_out'],
      ),
      complaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}complaint'],
      )!,
      estimatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_cost'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CarsTable createAlias(String alias) {
    return $CarsTable(attachedDatabase, alias);
  }
}

class Car extends DataClass implements Insertable<Car> {
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
  const Car({
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vin'] = Variable<String>(vin);
    if (!nullToAbsent || carModel != null) {
      map['car_model'] = Variable<String>(carModel);
    }
    map['customer_name'] = Variable<String>(customerName);
    map['time_in'] = Variable<DateTime>(timeIn);
    map['estimated_time_out'] = Variable<DateTime>(estimatedTimeOut);
    if (!nullToAbsent || actualTimeOut != null) {
      map['actual_time_out'] = Variable<DateTime>(actualTimeOut);
    }
    map['complaint'] = Variable<String>(complaint);
    if (!nullToAbsent || estimatedCost != null) {
      map['estimated_cost'] = Variable<double>(estimatedCost);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CarsCompanion toCompanion(bool nullToAbsent) {
    return CarsCompanion(
      id: Value(id),
      vin: Value(vin),
      carModel: carModel == null && nullToAbsent
          ? const Value.absent()
          : Value(carModel),
      customerName: Value(customerName),
      timeIn: Value(timeIn),
      estimatedTimeOut: Value(estimatedTimeOut),
      actualTimeOut: actualTimeOut == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTimeOut),
      complaint: Value(complaint),
      estimatedCost: estimatedCost == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCost),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Car.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Car(
      id: serializer.fromJson<int>(json['id']),
      vin: serializer.fromJson<String>(json['vin']),
      carModel: serializer.fromJson<String?>(json['carModel']),
      customerName: serializer.fromJson<String>(json['customerName']),
      timeIn: serializer.fromJson<DateTime>(json['timeIn']),
      estimatedTimeOut: serializer.fromJson<DateTime>(json['estimatedTimeOut']),
      actualTimeOut: serializer.fromJson<DateTime?>(json['actualTimeOut']),
      complaint: serializer.fromJson<String>(json['complaint']),
      estimatedCost: serializer.fromJson<double?>(json['estimatedCost']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vin': serializer.toJson<String>(vin),
      'carModel': serializer.toJson<String?>(carModel),
      'customerName': serializer.toJson<String>(customerName),
      'timeIn': serializer.toJson<DateTime>(timeIn),
      'estimatedTimeOut': serializer.toJson<DateTime>(estimatedTimeOut),
      'actualTimeOut': serializer.toJson<DateTime?>(actualTimeOut),
      'complaint': serializer.toJson<String>(complaint),
      'estimatedCost': serializer.toJson<double?>(estimatedCost),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Car copyWith({
    int? id,
    String? vin,
    Value<String?> carModel = const Value.absent(),
    String? customerName,
    DateTime? timeIn,
    DateTime? estimatedTimeOut,
    Value<DateTime?> actualTimeOut = const Value.absent(),
    String? complaint,
    Value<double?> estimatedCost = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Car(
    id: id ?? this.id,
    vin: vin ?? this.vin,
    carModel: carModel.present ? carModel.value : this.carModel,
    customerName: customerName ?? this.customerName,
    timeIn: timeIn ?? this.timeIn,
    estimatedTimeOut: estimatedTimeOut ?? this.estimatedTimeOut,
    actualTimeOut: actualTimeOut.present
        ? actualTimeOut.value
        : this.actualTimeOut,
    complaint: complaint ?? this.complaint,
    estimatedCost: estimatedCost.present
        ? estimatedCost.value
        : this.estimatedCost,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Car copyWithCompanion(CarsCompanion data) {
    return Car(
      id: data.id.present ? data.id.value : this.id,
      vin: data.vin.present ? data.vin.value : this.vin,
      carModel: data.carModel.present ? data.carModel.value : this.carModel,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      timeIn: data.timeIn.present ? data.timeIn.value : this.timeIn,
      estimatedTimeOut: data.estimatedTimeOut.present
          ? data.estimatedTimeOut.value
          : this.estimatedTimeOut,
      actualTimeOut: data.actualTimeOut.present
          ? data.actualTimeOut.value
          : this.actualTimeOut,
      complaint: data.complaint.present ? data.complaint.value : this.complaint,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Car(')
          ..write('id: $id, ')
          ..write('vin: $vin, ')
          ..write('carModel: $carModel, ')
          ..write('customerName: $customerName, ')
          ..write('timeIn: $timeIn, ')
          ..write('estimatedTimeOut: $estimatedTimeOut, ')
          ..write('actualTimeOut: $actualTimeOut, ')
          ..write('complaint: $complaint, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vin,
    carModel,
    customerName,
    timeIn,
    estimatedTimeOut,
    actualTimeOut,
    complaint,
    estimatedCost,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Car &&
          other.id == this.id &&
          other.vin == this.vin &&
          other.carModel == this.carModel &&
          other.customerName == this.customerName &&
          other.timeIn == this.timeIn &&
          other.estimatedTimeOut == this.estimatedTimeOut &&
          other.actualTimeOut == this.actualTimeOut &&
          other.complaint == this.complaint &&
          other.estimatedCost == this.estimatedCost &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class CarsCompanion extends UpdateCompanion<Car> {
  final Value<int> id;
  final Value<String> vin;
  final Value<String?> carModel;
  final Value<String> customerName;
  final Value<DateTime> timeIn;
  final Value<DateTime> estimatedTimeOut;
  final Value<DateTime?> actualTimeOut;
  final Value<String> complaint;
  final Value<double?> estimatedCost;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const CarsCompanion({
    this.id = const Value.absent(),
    this.vin = const Value.absent(),
    this.carModel = const Value.absent(),
    this.customerName = const Value.absent(),
    this.timeIn = const Value.absent(),
    this.estimatedTimeOut = const Value.absent(),
    this.actualTimeOut = const Value.absent(),
    this.complaint = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CarsCompanion.insert({
    this.id = const Value.absent(),
    required String vin,
    this.carModel = const Value.absent(),
    required String customerName,
    required DateTime timeIn,
    required DateTime estimatedTimeOut,
    this.actualTimeOut = const Value.absent(),
    required String complaint,
    this.estimatedCost = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : vin = Value(vin),
       customerName = Value(customerName),
       timeIn = Value(timeIn),
       estimatedTimeOut = Value(estimatedTimeOut),
       complaint = Value(complaint);
  static Insertable<Car> custom({
    Expression<int>? id,
    Expression<String>? vin,
    Expression<String>? carModel,
    Expression<String>? customerName,
    Expression<DateTime>? timeIn,
    Expression<DateTime>? estimatedTimeOut,
    Expression<DateTime>? actualTimeOut,
    Expression<String>? complaint,
    Expression<double>? estimatedCost,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vin != null) 'vin': vin,
      if (carModel != null) 'car_model': carModel,
      if (customerName != null) 'customer_name': customerName,
      if (timeIn != null) 'time_in': timeIn,
      if (estimatedTimeOut != null) 'estimated_time_out': estimatedTimeOut,
      if (actualTimeOut != null) 'actual_time_out': actualTimeOut,
      if (complaint != null) 'complaint': complaint,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CarsCompanion copyWith({
    Value<int>? id,
    Value<String>? vin,
    Value<String?>? carModel,
    Value<String>? customerName,
    Value<DateTime>? timeIn,
    Value<DateTime>? estimatedTimeOut,
    Value<DateTime?>? actualTimeOut,
    Value<String>? complaint,
    Value<double?>? estimatedCost,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return CarsCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (carModel.present) {
      map['car_model'] = Variable<String>(carModel.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (timeIn.present) {
      map['time_in'] = Variable<DateTime>(timeIn.value);
    }
    if (estimatedTimeOut.present) {
      map['estimated_time_out'] = Variable<DateTime>(estimatedTimeOut.value);
    }
    if (actualTimeOut.present) {
      map['actual_time_out'] = Variable<DateTime>(actualTimeOut.value);
    }
    if (complaint.present) {
      map['complaint'] = Variable<String>(complaint.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<double>(estimatedCost.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarsCompanion(')
          ..write('id: $id, ')
          ..write('vin: $vin, ')
          ..write('carModel: $carModel, ')
          ..write('customerName: $customerName, ')
          ..write('timeIn: $timeIn, ')
          ..write('estimatedTimeOut: $estimatedTimeOut, ')
          ..write('actualTimeOut: $actualTimeOut, ')
          ..write('complaint: $complaint, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CarPhotosTable extends CarPhotos
    with TableInfo<$CarPhotosTable, CarPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<int> carId = GeneratedColumn<int>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cars (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, carId, filePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'car_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}car_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CarPhotosTable createAlias(String alias) {
    return $CarPhotosTable(attachedDatabase, alias);
  }
}

class CarPhoto extends DataClass implements Insertable<CarPhoto> {
  final int id;
  final int carId;
  final String filePath;
  final DateTime createdAt;
  const CarPhoto({
    required this.id,
    required this.carId,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['car_id'] = Variable<int>(carId);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CarPhotosCompanion toCompanion(bool nullToAbsent) {
    return CarPhotosCompanion(
      id: Value(id),
      carId: Value(carId),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory CarPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarPhoto(
      id: serializer.fromJson<int>(json['id']),
      carId: serializer.fromJson<int>(json['carId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'carId': serializer.toJson<int>(carId),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CarPhoto copyWith({
    int? id,
    int? carId,
    String? filePath,
    DateTime? createdAt,
  }) => CarPhoto(
    id: id ?? this.id,
    carId: carId ?? this.carId,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  CarPhoto copyWithCompanion(CarPhotosCompanion data) {
    return CarPhoto(
      id: data.id.present ? data.id.value : this.id,
      carId: data.carId.present ? data.carId.value : this.carId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarPhoto(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, carId, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarPhoto &&
          other.id == this.id &&
          other.carId == this.carId &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class CarPhotosCompanion extends UpdateCompanion<CarPhoto> {
  final Value<int> id;
  final Value<int> carId;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  const CarPhotosCompanion({
    this.id = const Value.absent(),
    this.carId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CarPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int carId,
    required String filePath,
    this.createdAt = const Value.absent(),
  }) : carId = Value(carId),
       filePath = Value(filePath);
  static Insertable<CarPhoto> custom({
    Expression<int>? id,
    Expression<int>? carId,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carId != null) 'car_id': carId,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CarPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? carId,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
  }) {
    return CarPhotosCompanion(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<int>(carId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarPhotosCompanion(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CarsTable cars = $CarsTable(this);
  late final $CarPhotosTable carPhotos = $CarPhotosTable(this);
  late final CarsDao carsDao = CarsDao(this as AppDatabase);
  late final CarPhotosDao carPhotosDao = CarPhotosDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cars, carPhotos];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cars',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('car_photos', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CarsTableCreateCompanionBuilder =
    CarsCompanion Function({
      Value<int> id,
      required String vin,
      Value<String?> carModel,
      required String customerName,
      required DateTime timeIn,
      required DateTime estimatedTimeOut,
      Value<DateTime?> actualTimeOut,
      required String complaint,
      Value<double?> estimatedCost,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$CarsTableUpdateCompanionBuilder =
    CarsCompanion Function({
      Value<int> id,
      Value<String> vin,
      Value<String?> carModel,
      Value<String> customerName,
      Value<DateTime> timeIn,
      Value<DateTime> estimatedTimeOut,
      Value<DateTime?> actualTimeOut,
      Value<String> complaint,
      Value<double?> estimatedCost,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$CarsTableReferences
    extends BaseReferences<_$AppDatabase, $CarsTable, Car> {
  $$CarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CarPhotosTable, List<CarPhoto>>
  _carPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.carPhotos,
    aliasName: 'cars__id__car_photos__car_id',
  );

  $$CarPhotosTableProcessedTableManager get carPhotosRefs {
    final manager = $$CarPhotosTableTableManager(
      $_db,
      $_db.carPhotos,
    ).filter((f) => f.carId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_carPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CarsTableFilterComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carModel => $composableBuilder(
    column: $table.carModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timeIn => $composableBuilder(
    column: $table.timeIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get estimatedTimeOut => $composableBuilder(
    column: $table.estimatedTimeOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualTimeOut => $composableBuilder(
    column: $table.actualTimeOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get complaint => $composableBuilder(
    column: $table.complaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> carPhotosRefs(
    Expression<bool> Function($$CarPhotosTableFilterComposer f) f,
  ) {
    final $$CarPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carPhotos,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarPhotosTableFilterComposer(
            $db: $db,
            $table: $db.carPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarsTableOrderingComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carModel => $composableBuilder(
    column: $table.carModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timeIn => $composableBuilder(
    column: $table.timeIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get estimatedTimeOut => $composableBuilder(
    column: $table.estimatedTimeOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualTimeOut => $composableBuilder(
    column: $table.actualTimeOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get complaint => $composableBuilder(
    column: $table.complaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<String> get carModel =>
      $composableBuilder(column: $table.carModel, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timeIn =>
      $composableBuilder(column: $table.timeIn, builder: (column) => column);

  GeneratedColumn<DateTime> get estimatedTimeOut => $composableBuilder(
    column: $table.estimatedTimeOut,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualTimeOut => $composableBuilder(
    column: $table.actualTimeOut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get complaint =>
      $composableBuilder(column: $table.complaint, builder: (column) => column);

  GeneratedColumn<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> carPhotosRefs<T extends Object>(
    Expression<T> Function($$CarPhotosTableAnnotationComposer a) f,
  ) {
    final $$CarPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carPhotos,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.carPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarsTable,
          Car,
          $$CarsTableFilterComposer,
          $$CarsTableOrderingComposer,
          $$CarsTableAnnotationComposer,
          $$CarsTableCreateCompanionBuilder,
          $$CarsTableUpdateCompanionBuilder,
          (Car, $$CarsTableReferences),
          Car,
          PrefetchHooks Function({bool carPhotosRefs})
        > {
  $$CarsTableTableManager(_$AppDatabase db, $CarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vin = const Value.absent(),
                Value<String?> carModel = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<DateTime> timeIn = const Value.absent(),
                Value<DateTime> estimatedTimeOut = const Value.absent(),
                Value<DateTime?> actualTimeOut = const Value.absent(),
                Value<String> complaint = const Value.absent(),
                Value<double?> estimatedCost = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CarsCompanion(
                id: id,
                vin: vin,
                carModel: carModel,
                customerName: customerName,
                timeIn: timeIn,
                estimatedTimeOut: estimatedTimeOut,
                actualTimeOut: actualTimeOut,
                complaint: complaint,
                estimatedCost: estimatedCost,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vin,
                Value<String?> carModel = const Value.absent(),
                required String customerName,
                required DateTime timeIn,
                required DateTime estimatedTimeOut,
                Value<DateTime?> actualTimeOut = const Value.absent(),
                required String complaint,
                Value<double?> estimatedCost = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CarsCompanion.insert(
                id: id,
                vin: vin,
                carModel: carModel,
                customerName: customerName,
                timeIn: timeIn,
                estimatedTimeOut: estimatedTimeOut,
                actualTimeOut: actualTimeOut,
                complaint: complaint,
                estimatedCost: estimatedCost,
                status: status,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CarsTable, Car>(table),
                  $$CarsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({carPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (carPhotosRefs) db.carPhotos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (carPhotosRefs)
                    await $_getPrefetchedDataByColumns<
                      Car,
                      $CarsTable,
                      CarPhoto,
                      $CarPhotosTable
                    >(
                      currentTable: table,
                      referencedTable: $$CarsTableReferences
                          ._carPhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CarsTableReferences(db, table, p0).carPhotosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'car_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarsTable,
      Car,
      $$CarsTableFilterComposer,
      $$CarsTableOrderingComposer,
      $$CarsTableAnnotationComposer,
      $$CarsTableCreateCompanionBuilder,
      $$CarsTableUpdateCompanionBuilder,
      (Car, $$CarsTableReferences),
      Car,
      PrefetchHooks Function({bool carPhotosRefs})
    >;
typedef $$CarPhotosTableCreateCompanionBuilder =
    CarPhotosCompanion Function({
      Value<int> id,
      required int carId,
      required String filePath,
      Value<DateTime> createdAt,
    });
typedef $$CarPhotosTableUpdateCompanionBuilder =
    CarPhotosCompanion Function({
      Value<int> id,
      Value<int> carId,
      Value<String> filePath,
      Value<DateTime> createdAt,
    });

final class $$CarPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $CarPhotosTable, CarPhoto> {
  $$CarPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CarsTable _carIdTable(_$AppDatabase db) =>
      db.cars.createAlias('car_photos__car_id__cars__id');

  $$CarsTableProcessedTableManager get carId {
    final $_column = $_itemColumn<int>('car_id')!;

    final manager = $$CarsTableTableManager(
      $_db,
      $_db.cars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CarPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $CarPhotosTable> {
  $$CarPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CarsTableFilterComposer get carId {
    final $$CarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableFilterComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $CarPhotosTable> {
  $$CarPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CarsTableOrderingComposer get carId {
    final $$CarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableOrderingComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarPhotosTable> {
  $$CarPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CarsTableAnnotationComposer get carId {
    final $$CarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableAnnotationComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarPhotosTable,
          CarPhoto,
          $$CarPhotosTableFilterComposer,
          $$CarPhotosTableOrderingComposer,
          $$CarPhotosTableAnnotationComposer,
          $$CarPhotosTableCreateCompanionBuilder,
          $$CarPhotosTableUpdateCompanionBuilder,
          (CarPhoto, $$CarPhotosTableReferences),
          CarPhoto,
          PrefetchHooks Function({bool carId})
        > {
  $$CarPhotosTableTableManager(_$AppDatabase db, $CarPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> carId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CarPhotosCompanion(
                id: id,
                carId: carId,
                filePath: filePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int carId,
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
              }) => CarPhotosCompanion.insert(
                id: id,
                carId: carId,
                filePath: filePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CarPhotosTable, CarPhoto>(table),
                  $$CarPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({carId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (carId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.carId,
                                referencedTable: $$CarPhotosTableReferences
                                    ._carIdTable(db),
                                referencedColumn: $$CarPhotosTableReferences
                                    ._carIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CarPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarPhotosTable,
      CarPhoto,
      $$CarPhotosTableFilterComposer,
      $$CarPhotosTableOrderingComposer,
      $$CarPhotosTableAnnotationComposer,
      $$CarPhotosTableCreateCompanionBuilder,
      $$CarPhotosTableUpdateCompanionBuilder,
      (CarPhoto, $$CarPhotosTableReferences),
      CarPhoto,
      PrefetchHooks Function({bool carId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CarsTableTableManager get cars => $$CarsTableTableManager(_db, _db.cars);
  $$CarPhotosTableTableManager get carPhotos =>
      $$CarPhotosTableTableManager(_db, _db.carPhotos);
}
