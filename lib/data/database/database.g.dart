// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ShoesTable extends Shoes with TableInfo<$ShoesTable, Shoe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentDistanceMeta = const VerificationMeta(
    'currentDistance',
  );
  @override
  late final GeneratedColumn<double> currentDistance = GeneratedColumn<double>(
    'current_distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _targetDistanceMeta = const VerificationMeta(
    'targetDistance',
  );
  @override
  late final GeneratedColumn<double> targetDistance = GeneratedColumn<double>(
    'target_distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(400.0),
  );
  static const VerificationMeta _isRetiredMeta = const VerificationMeta(
    'isRetired',
  );
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
    'is_retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoUriMeta = const VerificationMeta(
    'photoUri',
  );
  @override
  late final GeneratedColumn<String> photoUri = GeneratedColumn<String>(
    'photo_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _retiredAtMeta = const VerificationMeta(
    'retiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> retiredAt = GeneratedColumn<DateTime>(
    'retired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    brand,
    model,
    currentDistance,
    targetDistance,
    isRetired,
    photoUri,
    category,
    price,
    createdAt,
    retiredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shoe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('current_distance')) {
      context.handle(
        _currentDistanceMeta,
        currentDistance.isAcceptableOrUnknown(
          data['current_distance']!,
          _currentDistanceMeta,
        ),
      );
    }
    if (data.containsKey('target_distance')) {
      context.handle(
        _targetDistanceMeta,
        targetDistance.isAcceptableOrUnknown(
          data['target_distance']!,
          _targetDistanceMeta,
        ),
      );
    }
    if (data.containsKey('is_retired')) {
      context.handle(
        _isRetiredMeta,
        isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta),
      );
    }
    if (data.containsKey('photo_uri')) {
      context.handle(
        _photoUriMeta,
        photoUri.isAcceptableOrUnknown(data['photo_uri']!, _photoUriMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('retired_at')) {
      context.handle(
        _retiredAtMeta,
        retiredAt.isAcceptableOrUnknown(data['retired_at']!, _retiredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shoe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shoe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      currentDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_distance'],
      )!,
      targetDistance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance'],
      )!,
      isRetired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retired'],
      )!,
      photoUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_uri'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_at'],
      ),
    );
  }

  @override
  $ShoesTable createAlias(String alias) {
    return $ShoesTable(attachedDatabase, alias);
  }
}

class Shoe extends DataClass implements Insertable<Shoe> {
  final String id;
  final String name;
  final String? brand;
  final String? model;
  final double currentDistance;
  final double targetDistance;
  final bool isRetired;
  final String? photoUri;
  final String? category;
  final double? price;
  final DateTime createdAt;
  final DateTime? retiredAt;
  const Shoe({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    required this.currentDistance,
    required this.targetDistance,
    required this.isRetired,
    this.photoUri,
    this.category,
    this.price,
    required this.createdAt,
    this.retiredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['current_distance'] = Variable<double>(currentDistance);
    map['target_distance'] = Variable<double>(targetDistance);
    map['is_retired'] = Variable<bool>(isRetired);
    if (!nullToAbsent || photoUri != null) {
      map['photo_uri'] = Variable<String>(photoUri);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || retiredAt != null) {
      map['retired_at'] = Variable<DateTime>(retiredAt);
    }
    return map;
  }

  ShoesCompanion toCompanion(bool nullToAbsent) {
    return ShoesCompanion(
      id: Value(id),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      currentDistance: Value(currentDistance),
      targetDistance: Value(targetDistance),
      isRetired: Value(isRetired),
      photoUri: photoUri == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUri),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      createdAt: Value(createdAt),
      retiredAt: retiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredAt),
    );
  }

  factory Shoe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shoe(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      model: serializer.fromJson<String?>(json['model']),
      currentDistance: serializer.fromJson<double>(json['currentDistance']),
      targetDistance: serializer.fromJson<double>(json['targetDistance']),
      isRetired: serializer.fromJson<bool>(json['isRetired']),
      photoUri: serializer.fromJson<String?>(json['photoUri']),
      category: serializer.fromJson<String?>(json['category']),
      price: serializer.fromJson<double?>(json['price']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retiredAt: serializer.fromJson<DateTime?>(json['retiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'model': serializer.toJson<String?>(model),
      'currentDistance': serializer.toJson<double>(currentDistance),
      'targetDistance': serializer.toJson<double>(targetDistance),
      'isRetired': serializer.toJson<bool>(isRetired),
      'photoUri': serializer.toJson<String?>(photoUri),
      'category': serializer.toJson<String?>(category),
      'price': serializer.toJson<double?>(price),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retiredAt': serializer.toJson<DateTime?>(retiredAt),
    };
  }

  Shoe copyWith({
    String? id,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> model = const Value.absent(),
    double? currentDistance,
    double? targetDistance,
    bool? isRetired,
    Value<String?> photoUri = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<double?> price = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> retiredAt = const Value.absent(),
  }) => Shoe(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    model: model.present ? model.value : this.model,
    currentDistance: currentDistance ?? this.currentDistance,
    targetDistance: targetDistance ?? this.targetDistance,
    isRetired: isRetired ?? this.isRetired,
    photoUri: photoUri.present ? photoUri.value : this.photoUri,
    category: category.present ? category.value : this.category,
    price: price.present ? price.value : this.price,
    createdAt: createdAt ?? this.createdAt,
    retiredAt: retiredAt.present ? retiredAt.value : this.retiredAt,
  );
  Shoe copyWithCompanion(ShoesCompanion data) {
    return Shoe(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      currentDistance: data.currentDistance.present
          ? data.currentDistance.value
          : this.currentDistance,
      targetDistance: data.targetDistance.present
          ? data.targetDistance.value
          : this.targetDistance,
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
      photoUri: data.photoUri.present ? data.photoUri.value : this.photoUri,
      category: data.category.present ? data.category.value : this.category,
      price: data.price.present ? data.price.value : this.price,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retiredAt: data.retiredAt.present ? data.retiredAt.value : this.retiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shoe(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('currentDistance: $currentDistance, ')
          ..write('targetDistance: $targetDistance, ')
          ..write('isRetired: $isRetired, ')
          ..write('photoUri: $photoUri, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt, ')
          ..write('retiredAt: $retiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    brand,
    model,
    currentDistance,
    targetDistance,
    isRetired,
    photoUri,
    category,
    price,
    createdAt,
    retiredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shoe &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.currentDistance == this.currentDistance &&
          other.targetDistance == this.targetDistance &&
          other.isRetired == this.isRetired &&
          other.photoUri == this.photoUri &&
          other.category == this.category &&
          other.price == this.price &&
          other.createdAt == this.createdAt &&
          other.retiredAt == this.retiredAt);
}

class ShoesCompanion extends UpdateCompanion<Shoe> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> model;
  final Value<double> currentDistance;
  final Value<double> targetDistance;
  final Value<bool> isRetired;
  final Value<String?> photoUri;
  final Value<String?> category;
  final Value<double?> price;
  final Value<DateTime> createdAt;
  final Value<DateTime?> retiredAt;
  final Value<int> rowid;
  const ShoesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.currentDistance = const Value.absent(),
    this.targetDistance = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.category = const Value.absent(),
    this.price = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoesCompanion.insert({
    required String id,
    required String name,
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.currentDistance = const Value.absent(),
    this.targetDistance = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.category = const Value.absent(),
    this.price = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Shoe> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<double>? currentDistance,
    Expression<double>? targetDistance,
    Expression<bool>? isRetired,
    Expression<String>? photoUri,
    Expression<String>? category,
    Expression<double>? price,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? retiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (currentDistance != null) 'current_distance': currentDistance,
      if (targetDistance != null) 'target_distance': targetDistance,
      if (isRetired != null) 'is_retired': isRetired,
      if (photoUri != null) 'photo_uri': photoUri,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? model,
    Value<double>? currentDistance,
    Value<double>? targetDistance,
    Value<bool>? isRetired,
    Value<String?>? photoUri,
    Value<String?>? category,
    Value<double?>? price,
    Value<DateTime>? createdAt,
    Value<DateTime?>? retiredAt,
    Value<int>? rowid,
  }) {
    return ShoesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      currentDistance: currentDistance ?? this.currentDistance,
      targetDistance: targetDistance ?? this.targetDistance,
      isRetired: isRetired ?? this.isRetired,
      photoUri: photoUri ?? this.photoUri,
      category: category ?? this.category,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      retiredAt: retiredAt ?? this.retiredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (currentDistance.present) {
      map['current_distance'] = Variable<double>(currentDistance.value);
    }
    if (targetDistance.present) {
      map['target_distance'] = Variable<double>(targetDistance.value);
    }
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
    }
    if (photoUri.present) {
      map['photo_uri'] = Variable<String>(photoUri.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<DateTime>(retiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('currentDistance: $currentDistance, ')
          ..write('targetDistance: $targetDistance, ')
          ..write('isRetired: $isRetired, ')
          ..write('photoUri: $photoUri, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('createdAt: $createdAt, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  @override
  late final GeneratedColumn<String> workoutId = GeneratedColumn<String>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _shoeIdMeta = const VerificationMeta('shoeId');
  @override
  late final GeneratedColumn<String> shoeId = GeneratedColumn<String>(
    'shoe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shoes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _workoutTypeMeta = const VerificationMeta(
    'workoutType',
  );
  @override
  late final GeneratedColumn<String> workoutType = GeneratedColumn<String>(
    'workout_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceBundleIdMeta = const VerificationMeta(
    'sourceBundleId',
  );
  @override
  late final GeneratedColumn<String> sourceBundleId = GeneratedColumn<String>(
    'source_bundle_id',
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
    workoutId,
    shoeId,
    workoutType,
    distance,
    duration,
    startDate,
    endDate,
    source,
    sourceBundleId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('shoe_id')) {
      context.handle(
        _shoeIdMeta,
        shoeId.isAcceptableOrUnknown(data['shoe_id']!, _shoeIdMeta),
      );
    }
    if (data.containsKey('workout_type')) {
      context.handle(
        _workoutTypeMeta,
        workoutType.isAcceptableOrUnknown(
          data['workout_type']!,
          _workoutTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_bundle_id')) {
      context.handle(
        _sourceBundleIdMeta,
        sourceBundleId.isAcceptableOrUnknown(
          data['source_bundle_id']!,
          _sourceBundleIdMeta,
        ),
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
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_id'],
      )!,
      shoeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shoe_id'],
      ),
      workoutType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type'],
      )!,
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      sourceBundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_bundle_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String workoutId;
  final String? shoeId;
  final String workoutType;
  final double distance;
  final double duration;
  final DateTime startDate;
  final DateTime endDate;
  final String? source;
  final String? sourceBundleId;
  final DateTime createdAt;
  const Activity({
    required this.id,
    required this.workoutId,
    this.shoeId,
    required this.workoutType,
    required this.distance,
    required this.duration,
    required this.startDate,
    required this.endDate,
    this.source,
    this.sourceBundleId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workout_id'] = Variable<String>(workoutId);
    if (!nullToAbsent || shoeId != null) {
      map['shoe_id'] = Variable<String>(shoeId);
    }
    map['workout_type'] = Variable<String>(workoutType);
    map['distance'] = Variable<double>(distance);
    map['duration'] = Variable<double>(duration);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sourceBundleId != null) {
      map['source_bundle_id'] = Variable<String>(sourceBundleId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      shoeId: shoeId == null && nullToAbsent
          ? const Value.absent()
          : Value(shoeId),
      workoutType: Value(workoutType),
      distance: Value(distance),
      duration: Value(duration),
      startDate: Value(startDate),
      endDate: Value(endDate),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      sourceBundleId: sourceBundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceBundleId),
      createdAt: Value(createdAt),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      workoutId: serializer.fromJson<String>(json['workoutId']),
      shoeId: serializer.fromJson<String?>(json['shoeId']),
      workoutType: serializer.fromJson<String>(json['workoutType']),
      distance: serializer.fromJson<double>(json['distance']),
      duration: serializer.fromJson<double>(json['duration']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      source: serializer.fromJson<String?>(json['source']),
      sourceBundleId: serializer.fromJson<String?>(json['sourceBundleId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workoutId': serializer.toJson<String>(workoutId),
      'shoeId': serializer.toJson<String?>(shoeId),
      'workoutType': serializer.toJson<String>(workoutType),
      'distance': serializer.toJson<double>(distance),
      'duration': serializer.toJson<double>(duration),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'source': serializer.toJson<String?>(source),
      'sourceBundleId': serializer.toJson<String?>(sourceBundleId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Activity copyWith({
    String? id,
    String? workoutId,
    Value<String?> shoeId = const Value.absent(),
    String? workoutType,
    double? distance,
    double? duration,
    DateTime? startDate,
    DateTime? endDate,
    Value<String?> source = const Value.absent(),
    Value<String?> sourceBundleId = const Value.absent(),
    DateTime? createdAt,
  }) => Activity(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    shoeId: shoeId.present ? shoeId.value : this.shoeId,
    workoutType: workoutType ?? this.workoutType,
    distance: distance ?? this.distance,
    duration: duration ?? this.duration,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    source: source.present ? source.value : this.source,
    sourceBundleId: sourceBundleId.present
        ? sourceBundleId.value
        : this.sourceBundleId,
    createdAt: createdAt ?? this.createdAt,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      shoeId: data.shoeId.present ? data.shoeId.value : this.shoeId,
      workoutType: data.workoutType.present
          ? data.workoutType.value
          : this.workoutType,
      distance: data.distance.present ? data.distance.value : this.distance,
      duration: data.duration.present ? data.duration.value : this.duration,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      source: data.source.present ? data.source.value : this.source,
      sourceBundleId: data.sourceBundleId.present
          ? data.sourceBundleId.value
          : this.sourceBundleId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('shoeId: $shoeId, ')
          ..write('workoutType: $workoutType, ')
          ..write('distance: $distance, ')
          ..write('duration: $duration, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('source: $source, ')
          ..write('sourceBundleId: $sourceBundleId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    shoeId,
    workoutType,
    distance,
    duration,
    startDate,
    endDate,
    source,
    sourceBundleId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.shoeId == this.shoeId &&
          other.workoutType == this.workoutType &&
          other.distance == this.distance &&
          other.duration == this.duration &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.source == this.source &&
          other.sourceBundleId == this.sourceBundleId &&
          other.createdAt == this.createdAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> workoutId;
  final Value<String?> shoeId;
  final Value<String> workoutType;
  final Value<double> distance;
  final Value<double> duration;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String?> source;
  final Value<String?> sourceBundleId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.workoutType = const Value.absent(),
    this.distance = const Value.absent(),
    this.duration = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceBundleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String workoutId,
    this.shoeId = const Value.absent(),
    required String workoutType,
    this.distance = const Value.absent(),
    this.duration = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    this.source = const Value.absent(),
    this.sourceBundleId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workoutId = Value(workoutId),
       workoutType = Value(workoutType),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? workoutId,
    Expression<String>? shoeId,
    Expression<String>? workoutType,
    Expression<double>? distance,
    Expression<double>? duration,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? source,
    Expression<String>? sourceBundleId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (shoeId != null) 'shoe_id': shoeId,
      if (workoutType != null) 'workout_type': workoutType,
      if (distance != null) 'distance': distance,
      if (duration != null) 'duration': duration,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (source != null) 'source': source,
      if (sourceBundleId != null) 'source_bundle_id': sourceBundleId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? workoutId,
    Value<String?>? shoeId,
    Value<String>? workoutType,
    Value<double>? distance,
    Value<double>? duration,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String?>? source,
    Value<String?>? sourceBundleId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      shoeId: shoeId ?? this.shoeId,
      workoutType: workoutType ?? this.workoutType,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      source: source ?? this.source,
      sourceBundleId: sourceBundleId ?? this.sourceBundleId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<String>(workoutId.value);
    }
    if (shoeId.present) {
      map['shoe_id'] = Variable<String>(shoeId.value);
    }
    if (workoutType.present) {
      map['workout_type'] = Variable<String>(workoutType.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (duration.present) {
      map['duration'] = Variable<double>(duration.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceBundleId.present) {
      map['source_bundle_id'] = Variable<String>(sourceBundleId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('shoeId: $shoeId, ')
          ..write('workoutType: $workoutType, ')
          ..write('distance: $distance, ')
          ..write('duration: $duration, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('source: $source, ')
          ..write('sourceBundleId: $sourceBundleId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutDefaultsTable extends WorkoutDefaults
    with TableInfo<$WorkoutDefaultsTable, WorkoutDefault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutDefaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workoutTypeMeta = const VerificationMeta(
    'workoutType',
  );
  @override
  late final GeneratedColumn<String> workoutType = GeneratedColumn<String>(
    'workout_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shoeIdMeta = const VerificationMeta('shoeId');
  @override
  late final GeneratedColumn<String> shoeId = GeneratedColumn<String>(
    'shoe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shoes (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [workoutType, shoeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_defaults';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutDefault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workout_type')) {
      context.handle(
        _workoutTypeMeta,
        workoutType.isAcceptableOrUnknown(
          data['workout_type']!,
          _workoutTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutTypeMeta);
    }
    if (data.containsKey('shoe_id')) {
      context.handle(
        _shoeIdMeta,
        shoeId.isAcceptableOrUnknown(data['shoe_id']!, _shoeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shoeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workoutType};
  @override
  WorkoutDefault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutDefault(
      workoutType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_type'],
      )!,
      shoeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shoe_id'],
      )!,
    );
  }

  @override
  $WorkoutDefaultsTable createAlias(String alias) {
    return $WorkoutDefaultsTable(attachedDatabase, alias);
  }
}

class WorkoutDefault extends DataClass implements Insertable<WorkoutDefault> {
  final String workoutType;
  final String shoeId;
  const WorkoutDefault({required this.workoutType, required this.shoeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workout_type'] = Variable<String>(workoutType);
    map['shoe_id'] = Variable<String>(shoeId);
    return map;
  }

  WorkoutDefaultsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutDefaultsCompanion(
      workoutType: Value(workoutType),
      shoeId: Value(shoeId),
    );
  }

  factory WorkoutDefault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutDefault(
      workoutType: serializer.fromJson<String>(json['workoutType']),
      shoeId: serializer.fromJson<String>(json['shoeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workoutType': serializer.toJson<String>(workoutType),
      'shoeId': serializer.toJson<String>(shoeId),
    };
  }

  WorkoutDefault copyWith({String? workoutType, String? shoeId}) =>
      WorkoutDefault(
        workoutType: workoutType ?? this.workoutType,
        shoeId: shoeId ?? this.shoeId,
      );
  WorkoutDefault copyWithCompanion(WorkoutDefaultsCompanion data) {
    return WorkoutDefault(
      workoutType: data.workoutType.present
          ? data.workoutType.value
          : this.workoutType,
      shoeId: data.shoeId.present ? data.shoeId.value : this.shoeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDefault(')
          ..write('workoutType: $workoutType, ')
          ..write('shoeId: $shoeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workoutType, shoeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutDefault &&
          other.workoutType == this.workoutType &&
          other.shoeId == this.shoeId);
}

class WorkoutDefaultsCompanion extends UpdateCompanion<WorkoutDefault> {
  final Value<String> workoutType;
  final Value<String> shoeId;
  final Value<int> rowid;
  const WorkoutDefaultsCompanion({
    this.workoutType = const Value.absent(),
    this.shoeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutDefaultsCompanion.insert({
    required String workoutType,
    required String shoeId,
    this.rowid = const Value.absent(),
  }) : workoutType = Value(workoutType),
       shoeId = Value(shoeId);
  static Insertable<WorkoutDefault> custom({
    Expression<String>? workoutType,
    Expression<String>? shoeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workoutType != null) 'workout_type': workoutType,
      if (shoeId != null) 'shoe_id': shoeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutDefaultsCompanion copyWith({
    Value<String>? workoutType,
    Value<String>? shoeId,
    Value<int>? rowid,
  }) {
    return WorkoutDefaultsCompanion(
      workoutType: workoutType ?? this.workoutType,
      shoeId: shoeId ?? this.shoeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workoutType.present) {
      map['workout_type'] = Variable<String>(workoutType.value);
    }
    if (shoeId.present) {
      map['shoe_id'] = Variable<String>(shoeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutDefaultsCompanion(')
          ..write('workoutType: $workoutType, ')
          ..write('shoeId: $shoeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ShoesTable shoes = $ShoesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $WorkoutDefaultsTable workoutDefaults = $WorkoutDefaultsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    shoes,
    activities,
    workoutDefaults,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shoes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shoes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_defaults', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ShoesTableCreateCompanionBuilder =
    ShoesCompanion Function({
      required String id,
      required String name,
      Value<String?> brand,
      Value<String?> model,
      Value<double> currentDistance,
      Value<double> targetDistance,
      Value<bool> isRetired,
      Value<String?> photoUri,
      Value<String?> category,
      Value<double?> price,
      Value<DateTime> createdAt,
      Value<DateTime?> retiredAt,
      Value<int> rowid,
    });
typedef $$ShoesTableUpdateCompanionBuilder =
    ShoesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> brand,
      Value<String?> model,
      Value<double> currentDistance,
      Value<double> targetDistance,
      Value<bool> isRetired,
      Value<String?> photoUri,
      Value<String?> category,
      Value<double?> price,
      Value<DateTime> createdAt,
      Value<DateTime?> retiredAt,
      Value<int> rowid,
    });

final class $$ShoesTableReferences
    extends BaseReferences<_$AppDatabase, $ShoesTable, Shoe> {
  $$ShoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'shoes__id__activities__shoe_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.shoeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutDefaultsTable, List<WorkoutDefault>>
  _workoutDefaultsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutDefaults,
    aliasName: 'shoes__id__workout_defaults__shoe_id',
  );

  $$WorkoutDefaultsTableProcessedTableManager get workoutDefaultsRefs {
    final manager = $$WorkoutDefaultsTableTableManager(
      $_db,
      $_db.workoutDefaults,
    ).filter((f) => f.shoeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutDefaultsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShoesTableFilterComposer extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentDistance => $composableBuilder(
    column: $table.currentDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistance => $composableBuilder(
    column: $table.targetDistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUri => $composableBuilder(
    column: $table.photoUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.shoeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutDefaultsRefs(
    Expression<bool> Function($$WorkoutDefaultsTableFilterComposer f) f,
  ) {
    final $$WorkoutDefaultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDefaults,
      getReferencedColumn: (t) => t.shoeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDefaultsTableFilterComposer(
            $db: $db,
            $table: $db.workoutDefaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShoesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentDistance => $composableBuilder(
    column: $table.currentDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistance => $composableBuilder(
    column: $table.targetDistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUri => $composableBuilder(
    column: $table.photoUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoesTable> {
  $$ShoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<double> get currentDistance => $composableBuilder(
    column: $table.currentDistance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistance => $composableBuilder(
    column: $table.targetDistance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRetired =>
      $composableBuilder(column: $table.isRetired, builder: (column) => column);

  GeneratedColumn<String> get photoUri =>
      $composableBuilder(column: $table.photoUri, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.shoeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutDefaultsRefs<T extends Object>(
    Expression<T> Function($$WorkoutDefaultsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutDefaultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutDefaults,
      getReferencedColumn: (t) => t.shoeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutDefaultsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutDefaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoesTable,
          Shoe,
          $$ShoesTableFilterComposer,
          $$ShoesTableOrderingComposer,
          $$ShoesTableAnnotationComposer,
          $$ShoesTableCreateCompanionBuilder,
          $$ShoesTableUpdateCompanionBuilder,
          (Shoe, $$ShoesTableReferences),
          Shoe,
          PrefetchHooks Function({
            bool activitiesRefs,
            bool workoutDefaultsRefs,
          })
        > {
  $$ShoesTableTableManager(_$AppDatabase db, $ShoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<double> currentDistance = const Value.absent(),
                Value<double> targetDistance = const Value.absent(),
                Value<bool> isRetired = const Value.absent(),
                Value<String?> photoUri = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoesCompanion(
                id: id,
                name: name,
                brand: brand,
                model: model,
                currentDistance: currentDistance,
                targetDistance: targetDistance,
                isRetired: isRetired,
                photoUri: photoUri,
                category: category,
                price: price,
                createdAt: createdAt,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<double> currentDistance = const Value.absent(),
                Value<double> targetDistance = const Value.absent(),
                Value<bool> isRetired = const Value.absent(),
                Value<String?> photoUri = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoesCompanion.insert(
                id: id,
                name: name,
                brand: brand,
                model: model,
                currentDistance: currentDistance,
                targetDistance: targetDistance,
                isRetired: isRetired,
                photoUri: photoUri,
                category: category,
                price: price,
                createdAt: createdAt,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoesTable, Shoe>(table),
                  $$ShoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activitiesRefs = false, workoutDefaultsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activitiesRefs) db.activities,
                    if (workoutDefaultsRefs) db.workoutDefaults,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activitiesRefs)
                        await $_getPrefetchedData<Shoe, $ShoesTable, Activity>(
                          currentTable: table,
                          referencedTable: $$ShoesTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShoesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shoeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutDefaultsRefs)
                        await $_getPrefetchedData<
                          Shoe,
                          $ShoesTable,
                          WorkoutDefault
                        >(
                          currentTable: table,
                          referencedTable: $$ShoesTableReferences
                              ._workoutDefaultsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShoesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutDefaultsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shoeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoesTable,
      Shoe,
      $$ShoesTableFilterComposer,
      $$ShoesTableOrderingComposer,
      $$ShoesTableAnnotationComposer,
      $$ShoesTableCreateCompanionBuilder,
      $$ShoesTableUpdateCompanionBuilder,
      (Shoe, $$ShoesTableReferences),
      Shoe,
      PrefetchHooks Function({bool activitiesRefs, bool workoutDefaultsRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String workoutId,
      Value<String?> shoeId,
      required String workoutType,
      Value<double> distance,
      Value<double> duration,
      required DateTime startDate,
      required DateTime endDate,
      Value<String?> source,
      Value<String?> sourceBundleId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> workoutId,
      Value<String?> shoeId,
      Value<String> workoutType,
      Value<double> distance,
      Value<double> duration,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String?> source,
      Value<String?> sourceBundleId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShoesTable _shoeIdTable(_$AppDatabase db) =>
      db.shoes.createAlias('activities__shoe_id__shoes__id');

  $$ShoesTableProcessedTableManager? get shoeId {
    final $_column = $_itemColumn<String>('shoe_id');
    if ($_column == null) return null;
    final manager = $$ShoesTableTableManager(
      $_db,
      $_db.shoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shoeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceBundleId => $composableBuilder(
    column: $table.sourceBundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ShoesTableFilterComposer get shoeId {
    final $$ShoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableFilterComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutId => $composableBuilder(
    column: $table.workoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceBundleId => $composableBuilder(
    column: $table.sourceBundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShoesTableOrderingComposer get shoeId {
    final $$ShoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableOrderingComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workoutId =>
      $composableBuilder(column: $table.workoutId, builder: (column) => column);

  GeneratedColumn<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<double> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceBundleId => $composableBuilder(
    column: $table.sourceBundleId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ShoesTableAnnotationComposer get shoeId {
    final $$ShoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableAnnotationComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool shoeId})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workoutId = const Value.absent(),
                Value<String?> shoeId = const Value.absent(),
                Value<String> workoutType = const Value.absent(),
                Value<double> distance = const Value.absent(),
                Value<double> duration = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> sourceBundleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                workoutId: workoutId,
                shoeId: shoeId,
                workoutType: workoutType,
                distance: distance,
                duration: duration,
                startDate: startDate,
                endDate: endDate,
                source: source,
                sourceBundleId: sourceBundleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workoutId,
                Value<String?> shoeId = const Value.absent(),
                required String workoutType,
                Value<double> distance = const Value.absent(),
                Value<double> duration = const Value.absent(),
                required DateTime startDate,
                required DateTime endDate,
                Value<String?> source = const Value.absent(),
                Value<String?> sourceBundleId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                workoutId: workoutId,
                shoeId: shoeId,
                workoutType: workoutType,
                distance: distance,
                duration: duration,
                startDate: startDate,
                endDate: endDate,
                source: source,
                sourceBundleId: sourceBundleId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, Activity>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shoeId = false}) {
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
                    if (shoeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shoeId,
                                referencedTable: $$ActivitiesTableReferences
                                    ._shoeIdTable(db),
                                referencedColumn: $$ActivitiesTableReferences
                                    ._shoeIdTable(db)
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

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool shoeId})
    >;
typedef $$WorkoutDefaultsTableCreateCompanionBuilder =
    WorkoutDefaultsCompanion Function({
      required String workoutType,
      required String shoeId,
      Value<int> rowid,
    });
typedef $$WorkoutDefaultsTableUpdateCompanionBuilder =
    WorkoutDefaultsCompanion Function({
      Value<String> workoutType,
      Value<String> shoeId,
      Value<int> rowid,
    });

final class $$WorkoutDefaultsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutDefaultsTable, WorkoutDefault> {
  $$WorkoutDefaultsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ShoesTable _shoeIdTable(_$AppDatabase db) =>
      db.shoes.createAlias('workout_defaults__shoe_id__shoes__id');

  $$ShoesTableProcessedTableManager get shoeId {
    final $_column = $_itemColumn<String>('shoe_id')!;

    final manager = $$ShoesTableTableManager(
      $_db,
      $_db.shoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shoeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutDefaultsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutDefaultsTable> {
  $$WorkoutDefaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnFilters(column),
  );

  $$ShoesTableFilterComposer get shoeId {
    final $$ShoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableFilterComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutDefaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutDefaultsTable> {
  $$WorkoutDefaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShoesTableOrderingComposer get shoeId {
    final $$ShoesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableOrderingComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutDefaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutDefaultsTable> {
  $$WorkoutDefaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workoutType => $composableBuilder(
    column: $table.workoutType,
    builder: (column) => column,
  );

  $$ShoesTableAnnotationComposer get shoeId {
    final $$ShoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shoeId,
      referencedTable: $db.shoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoesTableAnnotationComposer(
            $db: $db,
            $table: $db.shoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutDefaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutDefaultsTable,
          WorkoutDefault,
          $$WorkoutDefaultsTableFilterComposer,
          $$WorkoutDefaultsTableOrderingComposer,
          $$WorkoutDefaultsTableAnnotationComposer,
          $$WorkoutDefaultsTableCreateCompanionBuilder,
          $$WorkoutDefaultsTableUpdateCompanionBuilder,
          (WorkoutDefault, $$WorkoutDefaultsTableReferences),
          WorkoutDefault,
          PrefetchHooks Function({bool shoeId})
        > {
  $$WorkoutDefaultsTableTableManager(
    _$AppDatabase db,
    $WorkoutDefaultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutDefaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutDefaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutDefaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workoutType = const Value.absent(),
                Value<String> shoeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutDefaultsCompanion(
                workoutType: workoutType,
                shoeId: shoeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workoutType,
                required String shoeId,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutDefaultsCompanion.insert(
                workoutType: workoutType,
                shoeId: shoeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutDefaultsTable, WorkoutDefault>(table),
                  $$WorkoutDefaultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shoeId = false}) {
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
                    if (shoeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shoeId,
                                referencedTable:
                                    $$WorkoutDefaultsTableReferences
                                        ._shoeIdTable(db),
                                referencedColumn:
                                    $$WorkoutDefaultsTableReferences
                                        ._shoeIdTable(db)
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

typedef $$WorkoutDefaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutDefaultsTable,
      WorkoutDefault,
      $$WorkoutDefaultsTableFilterComposer,
      $$WorkoutDefaultsTableOrderingComposer,
      $$WorkoutDefaultsTableAnnotationComposer,
      $$WorkoutDefaultsTableCreateCompanionBuilder,
      $$WorkoutDefaultsTableUpdateCompanionBuilder,
      (WorkoutDefault, $$WorkoutDefaultsTableReferences),
      WorkoutDefault,
      PrefetchHooks Function({bool shoeId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ShoesTableTableManager get shoes =>
      $$ShoesTableTableManager(_db, _db.shoes);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$WorkoutDefaultsTableTableManager get workoutDefaults =>
      $$WorkoutDefaultsTableTableManager(_db, _db.workoutDefaults);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
