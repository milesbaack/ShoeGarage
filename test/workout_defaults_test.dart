import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/activities/widgets/activity_card_widget.dart';
import 'package:shoe_garage/features/garage/screens/shoe_detail_screen.dart';
import 'package:shoe_garage/features/garage/widgets/shoe_card_widget.dart';
import 'package:shoe_garage/features/settings/screens/settings_screen.dart';

void main() {
  group('Default Shoe for Workout Types Widget & Integration Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('Settings screen lists workout default tiles and allows setting default shoe', (WidgetTester tester) async {
      await testDb.insertShoe(ShoesCompanion.insert(
        id: 'shoe-clifton',
        name: 'Clifton 9',
        brand: const Value('Hoka'),
        model: const Value('Clifton 9'),
        currentDistance: const Value(120.0),
        targetDistance: const Value(400.0),
      ));

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

      // Verify Default Workout Shoes section is rendered
      expect(find.text('DEFAULT WORKOUT SHOES'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('Hiking / Trail'), findsOneWidget);
      expect(find.text('Other Workouts'), findsOneWidget);

      // Initially Running has 'None (manual selection)'
      expect(find.text('None (manual selection)'), findsNWidgets(4));

      // Tap on 'Running' tile
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();

      // Bottom sheet should open with title and list of active shoes
      expect(find.text('Default Shoe for Running'), findsOneWidget);
      expect(find.text('Clifton 9'), findsOneWidget);
      expect(find.text('None (Manual assignment)'), findsOneWidget);

      // Tap Clifton 9 in bottom sheet
      await tester.tap(find.text('Clifton 9'));
      await tester.pumpAndSettle();

      // Verify in DB that running default is shoe-clifton
      final runningDefault = await testDb.getDefaultForWorkoutType('running');
      expect(runningDefault?.shoeId, 'shoe-clifton');

      // Now Settings screen shows Clifton 9 for Running
      expect(find.text('Clifton 9'), findsOneWidget);

      // Open bottom sheet again and tap 'None (Manual assignment)' to clear
      await tester.tap(find.text('Running'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('None (Manual assignment)'));
      await tester.pumpAndSettle();

      final clearedDefault = await testDb.getDefaultForWorkoutType('running');
      expect(clearedDefault, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ActivityCardWidget displays 1-tap default button when defaultShoeId matches', (WidgetTester tester) async {
      final now = DateTime.now();
      final activity = Activity(
        id: 'act-1',
        workoutId: 'wk-1',
        workoutType: 'running',
        distance: 5.0,
        duration: 1800.0,
        startDate: now,
        endDate: now.add(const Duration(minutes: 30)),
        createdAt: now,
      );

      final clifton = Shoe(
        id: 'shoe-clifton',
        name: 'Clifton 9',
        brand: 'Hoka',
        model: 'Clifton 9',
        category: 'road',
        currentDistance: 100.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: now,
      );

      String? assignedShoeId;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActivityCardWidget(
                  activity: activity,
                  activeShoes: [clifton],
                  defaultShoeId: 'shoe-clifton',
                  onAssignShoe: (shoeId) {
                    assignedShoeId = shoeId;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify prominent 1-tap assign button exists
      final defaultButtonFinder = find.widgetWithText(FilledButton, 'Assign to Default (Clifton 9)');
      expect(defaultButtonFinder, findsOneWidget);

      // Tap 1-tap assign button
      await tester.tap(defaultButtonFinder);
      await tester.pumpAndSettle();

      expect(assignedShoeId, 'shoe-clifton');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ShoeCardWidget displays DEFAULT badge when shoe has mapped defaults', (WidgetTester tester) async {
      final now = DateTime.now();
      final shoe = Shoe(
        id: 'shoe-speed',
        name: 'Endorphin Speed 3',
        brand: 'Saucony',
        model: 'Speed 3',
        category: 'road',
        currentDistance: 150.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShoeCardWidget(
                shoe: shoe,
                defaultForWorkoutTypes: const ['running'],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('DEFAULT (RUNNING)'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ShoeDetailScreen displays default badge and popup menu option to configure defaults', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      await testDb.insertShoe(ShoesCompanion.insert(
        id: 'shoe-mach',
        name: 'Mach 6',
        brand: const Value('Hoka'),
        model: const Value('Mach 6'),
        category: const Value('road'),
        currentDistance: const Value(80.0),
        targetDistance: const Value(350.0),
      ));

      await testDb.setWorkoutDefault(workoutType: 'running', shoeId: 'shoe-mach');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: const MaterialApp(
            home: ShoeDetailScreen(shoeId: 'shoe-mach'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header shows DEFAULT (RUNNING) badge
      expect(find.text('DEFAULT (RUNNING)'), findsOneWidget);

      // Open popup menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Workout Defaults menu option exists
      expect(find.text('Workout Defaults'), findsOneWidget);

      // Tap Workout Defaults
      await tester.tap(find.text('Workout Defaults'));
      await tester.pumpAndSettle();

      // Bottom sheet opened
      expect(find.text('Default for Workouts'), findsOneWidget);
      expect(find.text('Default shoe for Running'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
