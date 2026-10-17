import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory database for testing
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Database Unit Tests [TEST-01]', () {
    test('Can insert and retrieve active shoes', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-1',
        name: 'Hoka Clifton 9',
        brand: const Value('Hoka'),
        model: const Value('Clifton 9'),
        currentDistance: const Value(50.0),
        targetDistance: const Value(400.0),
        category: const Value('road'),
      );

      await db.insertShoe(shoeCompanion);

      final activeShoes = await db.getActiveShoes();
      expect(activeShoes.length, 1);
      expect(activeShoes.first.id, 'shoe-1');
      expect(activeShoes.first.name, 'Hoka Clifton 9');
      expect(activeShoes.first.currentDistance, 50.0);
      expect(activeShoes.first.targetDistance, 400.0);
      expect(activeShoes.first.isRetired, false);
    });

    test('Can retire a shoe and verify target lifespan snaps to current distance', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-2',
        name: 'Nike Pegasus 40',
        currentDistance: const Value(235.4),
        targetDistance: const Value(450.0),
      );

      await db.insertShoe(shoeCompanion);
      await db.retireShoe('shoe-2');

      final retiredShoes = await db.getRetiredShoes();
      expect(retiredShoes.length, 1);
      final retired = retiredShoes.first;
      expect(retired.id, 'shoe-2');
      expect(retired.isRetired, true);
      // Target lifespan should snap to current distance
      expect(retired.targetDistance, 235.4);
      expect(retired.retiredAt, isNotNull);

      final activeShoes = await db.getActiveShoes();
      expect(activeShoes, isEmpty);
    });

    test('Can insert unassigned activity and assign it to a shoe', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-3',
        name: 'Saucony Endorphin Speed',
        currentDistance: const Value(10.0),
        targetDistance: const Value(400.0),
      );
      await db.insertShoe(shoeCompanion);

      final activityCompanion = ActivitiesCompanion.insert(
        id: 'act-1',
        workoutId: 'hk-workout-101',
        workoutType: 'running',
        distance: const Value(5.5),
        duration: const Value(1800.0),
        startDate: DateTime.now().subtract(const Duration(minutes: 30)),
        endDate: DateTime.now(),
        source: const Value('Apple Watch'),
      );
      await db.insertActivity(activityCompanion);

      // Verify unassigned
      final unassigned = await db.getUnassignedActivities();
      expect(unassigned.length, 1);
      expect(unassigned.first.workoutId, 'hk-workout-101');
      expect(unassigned.first.shoeId, isNull);

      // Assign activity to shoe
      await db.assignActivityToShoe(activityId: 'act-1', shoeId: 'shoe-3');

      // Verify no longer unassigned
      final remainingUnassigned = await db.getUnassignedActivities();
      expect(remainingUnassigned, isEmpty);

      // Verify shoe distance incremented by 5.5 (10.0 + 5.5 = 15.5)
      final updatedShoe = await db.getShoeById('shoe-3');
      expect(updatedShoe?.currentDistance, 15.5);
    });

    test('Can unretire a shoe with new target lifespan', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-retire-test',
        name: 'Brooks Ghost 15',
        currentDistance: const Value(350.0),
        targetDistance: const Value(400.0),
      );
      await db.insertShoe(shoeCompanion);
      await db.retireShoe('shoe-retire-test');

      var retired = await db.getShoeById('shoe-retire-test');
      expect(retired?.isRetired, true);
      expect(retired?.targetDistance, 350.0);
      expect(retired?.retiredAt, isNotNull);

      // Unretire with new target lifespan of 450 miles
      await db.unretireShoe(shoeId: 'shoe-retire-test', newTargetDistance: 450.0);

      final unretired = await db.getShoeById('shoe-retire-test');
      expect(unretired?.isRetired, false);
      expect(unretired?.targetDistance, 450.0);
      expect(unretired?.retiredAt, isNull);

      final activeList = await db.getActiveShoes();
      expect(activeList.any((s) => s.id == 'shoe-retire-test'), isTrue);
    });

    test('Can manually add miles to a shoe', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-miles-test',
        name: 'Asics Gel-Nimbus 26',
        currentDistance: const Value(42.5),
        targetDistance: const Value(400.0),
      );
      await db.insertShoe(shoeCompanion);

      await db.addMilesToShoe(shoeId: 'shoe-miles-test', additionalMiles: 5.5);

      final updated = await db.getShoeById('shoe-miles-test');
      expect(updated?.currentDistance, 48.0);
    });

    test('Can update shoe details', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-edit-test',
        name: 'Old Name',
        brand: const Value('Nike'),
        model: const Value('Pegasus'),
        category: const Value('road'),
        currentDistance: const Value(50.0),
        targetDistance: const Value(350.0),
      );
      await db.insertShoe(shoeCompanion);

      await db.updateShoeDetails(
        shoeId: 'shoe-edit-test',
        name: 'New Name',
        brand: 'Nike Running',
        model: 'Pegasus 41',
        category: 'racing',
        targetDistance: 500.0,
        currentDistance: 55.0,
      );

      final updated = await db.getShoeById('shoe-edit-test');
      expect(updated?.name, 'New Name');
      expect(updated?.brand, 'Nike Running');
      expect(updated?.model, 'Pegasus 41');
      expect(updated?.category, 'racing');
      expect(updated?.targetDistance, 500.0);
      expect(updated?.currentDistance, 55.0);
    });

    test('Can delete a shoe and activities become unassigned', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-delete-test',
        name: 'Shoe to Delete',
      );
      await db.insertShoe(shoeCompanion);

      final activityCompanion = ActivitiesCompanion.insert(
        id: 'act-delete-test',
        workoutId: 'hk-delete-1',
        workoutType: 'running',
        shoeId: const Value('shoe-delete-test'),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
      await db.insertActivity(activityCompanion);

      // Verify assigned initially
      final initialAct = await db.getActivityByWorkoutId('hk-delete-1');
      expect(initialAct?.shoeId, 'shoe-delete-test');

      // Delete shoe
      await db.deleteShoe('shoe-delete-test');

      final deletedShoe = await db.getShoeById('shoe-delete-test');
      expect(deletedShoe, isNull);

      // Verify activity shoeId became null (unassigned)
      final unassignedActs = await db.getUnassignedActivities();
      expect(unassignedActs.any((a) => a.id == 'act-delete-test'), isTrue);
    });

    test('Can store and update shoe purchase price for cost-per-mile calculation', () async {
      final shoeCompanion = ShoesCompanion.insert(
        id: 'shoe-price-test',
        name: 'Hoka Mach 6',
        currentDistance: const Value(140.0),
        price: const Value(140.0),
      );
      await db.insertShoe(shoeCompanion);

      var shoe = await db.getShoeById('shoe-price-test');
      expect(shoe?.price, 140.0);

      // Update price to 160.0
      await db.updateShoePrice(shoeId: 'shoe-price-test', price: 160.0);

      shoe = await db.getShoeById('shoe-price-test');
      expect(shoe?.price, 160.0);
    });

    test('Can reassign activity from one shoe to another and adjust distances', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-reassign-1',
        name: 'Shoe A',
        currentDistance: const Value(50.0),
      ));
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-reassign-2',
        name: 'Shoe B',
        currentDistance: const Value(20.0),
      ));

      await db.insertActivity(ActivitiesCompanion.insert(
        id: 'act-reassign-1',
        workoutId: 'wk-reassign-1',
        workoutType: 'running',
        distance: const Value(6.0),
        shoeId: const Value('shoe-reassign-1'),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ));

      // Reassign to Shoe B
      await db.reassignActivityShoe(
        activityId: 'act-reassign-1',
        newShoeId: 'shoe-reassign-2',
      );

      final shoeA = await db.getShoeById('shoe-reassign-1');
      final shoeB = await db.getShoeById('shoe-reassign-2');
      final act = await db.getActivityByWorkoutId('wk-reassign-1');

      expect(shoeA?.currentDistance, 44.0);
      expect(shoeB?.currentDistance, 26.0);
      expect(act?.shoeId, 'shoe-reassign-2');

      final assigned = await db.getAssignedActivities();
      expect(assigned.any((a) => a.id == 'act-reassign-1'), isTrue);
    });

    test('Can unassign an assigned activity back to inbox', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-unassign-1',
        name: 'Shoe C',
        currentDistance: const Value(50.0),
      ));

      await db.insertActivity(ActivitiesCompanion.insert(
        id: 'act-unassign-1',
        workoutId: 'wk-unassign-1',
        workoutType: 'running',
        distance: const Value(5.5),
        shoeId: const Value('shoe-unassign-1'),
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ));

      // Unassign
      await db.unassignActivity('act-unassign-1');

      final shoeC = await db.getShoeById('shoe-unassign-1');
      final act = await db.getActivityByWorkoutId('wk-unassign-1');

      expect(shoeC?.currentDistance, 44.5);
      expect(act?.shoeId, isNull);

      final unassigned = await db.getUnassignedActivities();
      expect(unassigned.any((a) => a.id == 'act-unassign-1'), isTrue);

      final assigned = await db.getAssignedActivities();
      expect(assigned.any((a) => a.id == 'act-unassign-1'), isFalse);
    });

    test('Can set, update, and clear shoe photo URI', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-photo-test',
        name: 'Alphafly 3',
        photoUri: const Value('/path/to/alphafly.jpg'),
      ));

      var shoe = await db.getShoeById('shoe-photo-test');
      expect(shoe?.photoUri, '/path/to/alphafly.jpg');

      // Update photo
      await db.updateShoePhoto(
        shoeId: 'shoe-photo-test',
        photoUri: '/path/to/alphafly_new.jpg',
      );
      shoe = await db.getShoeById('shoe-photo-test');
      expect(shoe?.photoUri, '/path/to/alphafly_new.jpg');

      // Clear photo
      await db.updateShoePhoto(
        shoeId: 'shoe-photo-test',
        photoUri: null,
      );
      shoe = await db.getShoeById('shoe-photo-test');
      expect(shoe?.photoUri, isNull);
    });

    test('Can set, get, update, and clear default shoe for workout types', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-default-1',
        name: 'Clifton 9',
      ));
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-default-2',
        name: 'Speedgoat 5',
      ));

      // Initially no default
      var runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault, isNull);

      // Set running default to shoe-default-1
      await db.setWorkoutDefault(workoutType: 'running', shoeId: 'shoe-default-1');
      runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault?.shoeId, 'shoe-default-1');

      // Set hiking default to shoe-default-2
      await db.setWorkoutDefault(workoutType: 'hiking', shoeId: 'shoe-default-2');
      final hikingDefault = await db.getDefaultForWorkoutType('hiking');
      expect(hikingDefault?.shoeId, 'shoe-default-2');

      // Reassign running default to shoe-default-2
      await db.setWorkoutDefault(workoutType: 'running', shoeId: 'shoe-default-2');
      runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault?.shoeId, 'shoe-default-2');

      // Clear running default by setting shoeId to null
      await db.setWorkoutDefault(workoutType: 'running', shoeId: null);
      runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault, isNull);
    });

    test('Retiring a shoe automatically clears its default workout mappings', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-retire-default',
        name: 'Pegasus 40',
        currentDistance: const Value(300.0),
        targetDistance: const Value(400.0),
      ));

      await db.setWorkoutDefault(workoutType: 'running', shoeId: 'shoe-retire-default');
      var runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault?.shoeId, 'shoe-retire-default');

      // Retire shoe
      await db.retireShoe('shoe-retire-default');

      runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault, isNull);
    });

    test('Deleting a shoe automatically clears its default workout mappings', () async {
      await db.insertShoe(ShoesCompanion.insert(
        id: 'shoe-delete-default',
        name: 'Vaporfly 3',
      ));

      await db.setWorkoutDefault(workoutType: 'running', shoeId: 'shoe-delete-default');
      var runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault?.shoeId, 'shoe-delete-default');

      // Delete shoe
      await db.deleteShoe('shoe-delete-default');

      runningDefault = await db.getDefaultForWorkoutType('running');
      expect(runningDefault, isNull);
    });

    test('Can set, get, and watch AppSettings [TEST-SETTINGS]', () async {
      // Default / empty
      var unitSetting = await db.getSetting('distance_unit');
      expect(unitSetting, isNull);

      // Set setting
      await db.setSetting('distance_unit', 'km');
      unitSetting = await db.getSetting('distance_unit');
      expect(unitSetting, 'km');

      // Update setting (upsert)
      await db.setSetting('distance_unit', 'mi');
      unitSetting = await db.getSetting('distance_unit');
      expect(unitSetting, 'mi');

      // Stream updates
      final streamFuture = db.watchSetting('distance_unit').take(2).toList();
      await db.setSetting('distance_unit', 'km');
      final streamedValues = await streamFuture;
      expect(streamedValues, ['mi', 'km']);
    });
  });
}


