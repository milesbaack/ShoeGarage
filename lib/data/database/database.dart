import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Shoes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  RealColumn get currentDistance => real().withDefault(const Constant(0.0))();
  RealColumn get targetDistance => real().withDefault(const Constant(400.0))();
  BoolColumn get isRetired => boolean().withDefault(const Constant(false))();
  TextColumn get photoUri => text().nullable()();
  TextColumn get category => text().nullable()(); // e.g. 'road', 'trail', 'racing'
  RealColumn get price => real().nullable()(); // original purchase price in dollars
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get retiredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get workoutId => text().unique()();
  TextColumn get shoeId => text().nullable().references(Shoes, #id, onDelete: KeyAction.setNull)();
  TextColumn get workoutType => text()(); // e.g. 'running', 'walking', 'hiking'
  RealColumn get distance => real().withDefault(const Constant(0.0))(); // in miles
  RealColumn get duration => real().withDefault(const Constant(0.0))(); // in seconds
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get source => text().nullable()(); // e.g. 'Apple Watch', 'Garmin', 'Strava'
  TextColumn get sourceBundleId => text().nullable()(); // e.g. 'com.apple.Health'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutDefaults extends Table {
  TextColumn get workoutType => text()(); // e.g. 'running', 'walking', 'hiking', 'other'
  TextColumn get shoeId => text().references(Shoes, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {workoutType};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Shoes, Activities, WorkoutDefaults, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.addColumn(shoes, shoes.price);
          }
          if (from <= 2) {
            await m.createTable(workoutDefaults);
          }
          if (from <= 3) {
            await m.createTable(appSettings);
          }
        },
      );

  // Active Shoes Queries
  Stream<List<Shoe>> watchActiveShoes() {
    return (select(shoes)..where((tbl) => tbl.isRetired.equals(false))).watch();
  }

  Future<List<Shoe>> getActiveShoes() {
    return (select(shoes)..where((tbl) => tbl.isRetired.equals(false))).get();
  }

  // Retired Shoes Queries
  Stream<List<Shoe>> watchRetiredShoes() {
    return (select(shoes)..where((tbl) => tbl.isRetired.equals(true))).watch();
  }

  Future<List<Shoe>> getRetiredShoes() {
    return (select(shoes)..where((tbl) => tbl.isRetired.equals(true))).get();
  }

  // Single Shoe Queries
  Future<Shoe?> getShoeById(String id) {
    return (select(shoes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<Shoe?> watchShoeById(String id) {
    return (select(shoes)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<int> insertShoe(ShoesCompanion entry) {
    return into(shoes).insert(entry);
  }

  Future<bool> updateShoe(Shoe entry) {
    return update(shoes).replace(entry);
  }

  Future<void> updateShoePrice({
    required String shoeId,
    required double? price,
  }) async {
    await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
      ShoesCompanion(
        price: Value(price),
      ),
    );
  }

  Future<void> retireShoe(String shoeId) async {
    await transaction(() async {
      final shoe = await getShoeById(shoeId);
      if (shoe == null) return;
      
      // As per HandOffFile: target lifespan snaps to current distance upon retirement
      await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
        ShoesCompanion(
          isRetired: const Value(true),
          targetDistance: Value(shoe.currentDistance),
          retiredAt: Value(DateTime.now()),
        ),
      );
      await removeWorkoutDefaultForShoe(shoeId);
    });
  }

  Future<void> unretireShoe({
    required String shoeId,
    required double newTargetDistance,
  }) async {
    await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
      ShoesCompanion(
        isRetired: const Value(false),
        targetDistance: Value(newTargetDistance),
        retiredAt: const Value(null),
      ),
    );
  }

  Future<void> addMilesToShoe({
    required String shoeId,
    required double additionalMiles,
  }) async {
    final shoe = await getShoeById(shoeId);
    if (shoe == null) return;
    final newDistance = (shoe.currentDistance + additionalMiles).clamp(0.0, double.infinity);
    await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
      ShoesCompanion(
        currentDistance: Value(newDistance),
      ),
    );
  }

  Future<void> updateShoeDetails({
    required String shoeId,
    required String name,
    String? brand,
    String? model,
    String? category,
    required double targetDistance,
    double? currentDistance,
    Value<String?> photoUri = const Value.absent(),
    double? price,
  }) async {
    await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
      ShoesCompanion(
        name: Value(name),
        brand: Value(brand),
        model: Value(model),
        category: Value(category),
        targetDistance: Value(targetDistance),
        currentDistance: currentDistance != null ? Value(currentDistance) : const Value.absent(),
        photoUri: photoUri,
        price: price != null ? Value(price) : const Value.absent(),
      ),
    );
  }

  Future<void> updateShoePhoto({
    required String shoeId,
    required String? photoUri,
  }) async {
    await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
      ShoesCompanion(
        photoUri: Value(photoUri),
      ),
    );
  }

  Future<int> deleteShoe(String shoeId) async {
    return await transaction(() async {
      await removeWorkoutDefaultForShoe(shoeId);
      await (update(activities)..where((tbl) => tbl.shoeId.equals(shoeId))).write(
        const ActivitiesCompanion(shoeId: Value(null)),
      );
      return (delete(shoes)..where((tbl) => tbl.id.equals(shoeId))).go();
    });
  }

  // Workout Defaults Queries
  Stream<List<WorkoutDefault>> watchWorkoutDefaults() {
    return select(workoutDefaults).watch();
  }

  Future<List<WorkoutDefault>> getWorkoutDefaults() {
    return select(workoutDefaults).get();
  }

  Future<WorkoutDefault?> getDefaultForWorkoutType(String workoutType) {
    return (select(workoutDefaults)..where((tbl) => tbl.workoutType.equals(workoutType))).getSingleOrNull();
  }

  Future<void> setWorkoutDefault({
    required String workoutType,
    required String? shoeId,
  }) async {
    if (shoeId == null) {
      await (delete(workoutDefaults)..where((tbl) => tbl.workoutType.equals(workoutType))).go();
    } else {
      await into(workoutDefaults).insertOnConflictUpdate(
        WorkoutDefaultsCompanion.insert(
          workoutType: workoutType,
          shoeId: shoeId,
        ),
      );
    }
  }

  Future<void> removeWorkoutDefaultForShoe(String shoeId) async {
    await (delete(workoutDefaults)..where((tbl) => tbl.shoeId.equals(shoeId))).go();
  }

  // AppSettings Queries
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((tbl) => tbl.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  // Activities Queries
  Stream<List<Activity>> watchUnassignedActivities() {
    return (select(activities)
          ..where((tbl) => tbl.shoeId.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .watch();
  }

  Future<List<Activity>> getUnassignedActivities() {
    return (select(activities)
          ..where((tbl) => tbl.shoeId.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .get();
  }

  Stream<List<Activity>> watchActivitiesForShoe(String shoeId) {
    return (select(activities)
          ..where((tbl) => tbl.shoeId.equals(shoeId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .watch();
  }

  Future<Activity?> getActivityByWorkoutId(String workoutId) {
    return (select(activities)..where((tbl) => tbl.workoutId.equals(workoutId))).getSingleOrNull();
  }

  Future<List<Activity>> getAllActivities() {
    return select(activities).get();
  }

  Future<int> deleteActivity(String id) {
    return (delete(activities)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> insertActivity(ActivitiesCompanion entry) {
    return into(activities).insert(entry);
  }

  Future<void> assignActivityToShoe({
    required String activityId,
    required String shoeId,
  }) async {
    await transaction(() async {
      final activity = await (select(activities)..where((tbl) => tbl.id.equals(activityId))).getSingleOrNull();
      if (activity == null) return;

      // Update activity
      await (update(activities)..where((tbl) => tbl.id.equals(activityId))).write(
        ActivitiesCompanion(
          shoeId: Value(shoeId),
        ),
      );

      // Increment shoe mileage
      final shoe = await getShoeById(shoeId);
      if (shoe != null) {
        await (update(shoes)..where((tbl) => tbl.id.equals(shoeId))).write(
          ShoesCompanion(
            currentDistance: Value(shoe.currentDistance + activity.distance),
          ),
        );
      }
    });
  }

  // Assigned Activities Queries
  Stream<List<Activity>> watchAssignedActivities() {
    return (select(activities)
          ..where((tbl) => tbl.shoeId.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .watch();
  }

  Future<List<Activity>> getAssignedActivities() {
    return (select(activities)
          ..where((tbl) => tbl.shoeId.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .get();
  }

  Future<void> reassignActivityShoe({
    required String activityId,
    required String newShoeId,
  }) async {
    await transaction(() async {
      final activity = await (select(activities)..where((tbl) => tbl.id.equals(activityId))).getSingleOrNull();
      if (activity == null || activity.shoeId == newShoeId) return;

      final oldShoeId = activity.shoeId;

      // Update activity to point to new shoe
      await (update(activities)..where((tbl) => tbl.id.equals(activityId))).write(
        ActivitiesCompanion(
          shoeId: Value(newShoeId),
        ),
      );

      // Decrement old shoe mileage
      if (oldShoeId != null) {
        final oldShoe = await getShoeById(oldShoeId);
        if (oldShoe != null) {
          final newDist = (oldShoe.currentDistance - activity.distance).clamp(0.0, double.infinity);
          await (update(shoes)..where((tbl) => tbl.id.equals(oldShoeId))).write(
            ShoesCompanion(currentDistance: Value(newDist)),
          );
        }
      }

      // Increment new shoe mileage
      final newShoe = await getShoeById(newShoeId);
      if (newShoe != null) {
        await (update(shoes)..where((tbl) => tbl.id.equals(newShoeId))).write(
          ShoesCompanion(currentDistance: Value(newShoe.currentDistance + activity.distance)),
        );
      }
    });
  }

  Future<void> unassignActivity(String activityId) async {
    await transaction(() async {
      final activity = await (select(activities)..where((tbl) => tbl.id.equals(activityId))).getSingleOrNull();
      if (activity == null || activity.shoeId == null) return;

      final oldShoeId = activity.shoeId!;
      final oldShoe = await getShoeById(oldShoeId);

      // Update activity to set shoeId = null
      await (update(activities)..where((tbl) => tbl.id.equals(activityId))).write(
        const ActivitiesCompanion(shoeId: Value(null)),
      );

      // Decrement old shoe mileage
      if (oldShoe != null) {
        final newDist = (oldShoe.currentDistance - activity.distance).clamp(0.0, double.infinity);
        await (update(shoes)..where((tbl) => tbl.id.equals(oldShoeId))).write(
          ShoesCompanion(currentDistance: Value(newDist)),
        );
      }
    });
  }
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'shoe_garage.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
