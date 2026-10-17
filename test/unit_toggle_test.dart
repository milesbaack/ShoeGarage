import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/activities/widgets/activity_card_widget.dart';
import 'package:shoe_garage/features/garage/widgets/add_shoe_sheet.dart';
import 'package:shoe_garage/features/garage/widgets/shoe_card_widget.dart';
import 'package:shoe_garage/features/settings/screens/settings_screen.dart';

void main() {
  group('Unit Toggle (mi vs. km) Widget & Integration Tests [TEST-UNIT-TOGGLE]', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('Settings screen shows Unit toggle and switches between Miles and Kilometers', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: const MaterialApp(
            home: SettingsScreen(showAppBar: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify Units & Display section is visible
      expect(find.text('UNITS & DISPLAY'), findsOneWidget);
      expect(find.text('Distance Unit'), findsOneWidget);
      expect(find.text('Miles (mi)'), findsOneWidget);
      expect(find.text('Kilometers (km)'), findsOneWidget);

      // Default unit in database should be null (defaults to miles)
      var unitInDb = await testDb.getSetting('distance_unit');
      expect(unitInDb, isNull);

      // Tap Kilometers (km)
      await tester.tap(find.text('Kilometers (km)'));
      await tester.pumpAndSettle();

      // Database should now have 'km'
      unitInDb = await testDb.getSetting('distance_unit');
      expect(unitInDb, 'km');

      // Tap Miles (mi)
      await tester.tap(find.text('Miles (mi)'));
      await tester.pumpAndSettle();

      unitInDb = await testDb.getSetting('distance_unit');
      expect(unitInDb, 'mi');

      // Unmount before teardown
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ActivityCardWidget displays distance and pace formatted with active unit', (WidgetTester tester) async {
      final now = DateTime.now();
      final workout = Activity(
        id: 'act-1',
        workoutId: 'hk-1',
        workoutType: 'running',
        distance: 5.0, // 5.0 miles canonically = 8.05 km
        duration: 2400.0, // 40 mins -> 8:00 /mi or 4:58 /km
        startDate: now,
        endDate: now.add(const Duration(minutes: 40)),
        shoeId: null,
        createdAt: now,
      );

      // First test with Miles preference
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ActivityCardWidget(
                activity: workout,
                activeShoes: const [],
                onAssignShoe: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5.00 mi'), findsOneWidget);
      expect(find.text('8:00 /mi'), findsOneWidget);

      // Now test with Kilometers preference
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.kilometers),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ActivityCardWidget(
                activity: workout,
                activeShoes: const [],
                onAssignShoe: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('8.05 km'), findsOneWidget);
      expect(find.text('4:58 /km'), findsOneWidget);

      // Unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ShoeCardWidget displays distance and target in user unit', (WidgetTester tester) async {
      final shoe = Shoe(
        id: 'shoe-1',
        name: 'Ghost 15',
        brand: 'Brooks',
        model: 'Ghost 15',
        currentDistance: 100.0, // 100.0 mi = 160.9 km
        targetDistance: 400.0, // 400 mi = 644 km
        isRetired: false,
        price: 140.0,
        retiredAt: null,
        createdAt: DateTime.now(),
        category: 'road',
      );

      // In Miles
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShoeCardWidget(shoe: shoe),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('100.0 / 400 mi'), findsOneWidget);

      // In Kilometers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.kilometers),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShoeCardWidget(shoe: shoe),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('160.9 / 644 km'), findsOneWidget);

      // Unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('AddShoeSheet converts kilometer inputs to canonical miles in database', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.kilometers),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const AddShoeSheet(),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Find shoe name input
      final nameField = find.widgetWithText(TextFormField, 'Shoe Nickname / Title *');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Test Kilometers Shoe');

      // The target lifespan displays km label
      expect(find.text('Target Lifespan (km)'), findsOneWidget);

      // Enter starting mileage in km: e.g. 16.09344 km (~10 canonical miles)
      final startingDistField = find.widgetWithText(TextFormField, 'Starting Kilometers');
      expect(startingDistField, findsOneWidget);
      await tester.enterText(startingDistField, '16.09344');

      // Tap Save
      await tester.tap(find.text('Add to Garage'));
      await tester.pumpAndSettle();

      // Check saved shoe in database
      final shoes = await testDb.getActiveShoes();
      expect(shoes.length, 1);
      final savedShoe = shoes.first;
      expect(savedShoe.name, 'Test Kilometers Shoe');
      // 16.09344 km must be converted to ~10.0 canonical miles in SQLite
      expect(savedShoe.currentDistance, closeTo(10.0, 0.05));

      // Unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
