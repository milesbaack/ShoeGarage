import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/activities/widgets/unassigned_run_carousel.dart';

void main() {
  group('[STORY-04] UnassignedRunCarousel UI & Integration Tests', () {
    testWidgets('[Scenario 1: Presentation] Unassigned runs are rendered in carousel with metrics', (WidgetTester tester) async {
      final now = DateTime(2026, 10, 16, 8, 30);
      final activity1 = Activity(
        id: 'act-1',
        workoutId: 'hk-1',
        shoeId: null,
        workoutType: 'running',
        distance: 5.25,
        duration: 2430.0, // 40m 30s
        startDate: now,
        endDate: now.add(const Duration(seconds: 2430)),
        source: 'Apple Watch Ultra',
        sourceBundleId: 'com.apple.Health',
        createdAt: now,
      );

      final activeShoe = Shoe(
        id: 'shoe-1',
        name: 'Hoka Clifton 9',
        brand: 'Hoka',
        model: 'Clifton 9',
        category: 'road',
        currentDistance: 50.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                defaultShoeMapProvider.overrideWithValue({}),
                unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
              ],
              child: UnassignedRunCarousel(
                activities: [activity1],
                activeShoes: [activeShoe],
              ),
            ),
          ),
        ),
      );

      // Verify header
      expect(find.text('Unassigned Inbox (1)'), findsOneWidget);
      expect(find.text('Run 1 of 1'), findsOneWidget);

      // Verify workout details
      expect(find.text('RUNNING'), findsOneWidget);
      expect(find.text('5.25 mi'), findsOneWidget);
      expect(find.text('40m 30s'), findsOneWidget);
      expect(find.text('Apple Watch Ultra'), findsOneWidget);

      // Verify active shoe chip is present
      expect(find.widgetWithText(ActionChip, 'Hoka Clifton 9'), findsOneWidget);

      // Clean unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('[Scenario 2: Inline Assignment] Tapping shoe chip calls assignActivityToShoe and increments distance in database', (WidgetTester tester) async {
      final now = DateTime(2026, 10, 16, 9, 0);
      final testDb = AppDatabase(NativeDatabase.memory());

      await testDb.insertShoe(
        ShoesCompanion.insert(
          id: 'shoe-speed',
          name: 'Endorphin Speed 3',
          brand: const Value('Saucony'),
          model: const Value('Speed 3'),
          category: const Value('racing'),
          currentDistance: const Value(100.0),
          targetDistance: const Value(400.0),
        ),
      );

      await testDb.insertActivity(
        ActivitiesCompanion.insert(
          id: 'act-assign-me',
          workoutId: 'hk-workout-assign',
          workoutType: 'running',
          distance: const Value(6.0),
          duration: const Value(2700.0),
          startDate: now,
          endDate: now.add(const Duration(minutes: 45)),
          source: const Value('Apple Watch'),
        ),
      );

      final activeShoe = await testDb.getShoeById('shoe-speed');
      final activity = await testDb.getActivityByWorkoutId('hk-workout-assign');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                databaseProvider.overrideWithValue(testDb),
                unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
              ],
              child: UnassignedRunCarousel(
                activities: [activity!],
                activeShoes: [activeShoe!],
              ),
            ),
          ),
        ),
      );

      // Find and tap the shoe chip
      final chipFinder = find.widgetWithText(ActionChip, 'Endorphin Speed 3');
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Snack bar should show feedback
      expect(find.textContaining('Assigned 6.00 mi to Endorphin Speed 3!'), findsOneWidget);

      // Verify in database that shoe distance is now 100.0 + 6.0 = 106.0
      final updatedShoe = await testDb.getShoeById('shoe-speed');
      expect(updatedShoe?.currentDistance, 106.0);

      // Verify in database that activity is now assigned to shoe-speed
      final updatedActivity = await testDb.getActivityByWorkoutId('hk-workout-assign');
      expect(updatedActivity?.shoeId, 'shoe-speed');

      // Clean unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await testDb.close();
    });

    testWidgets('[Scenario 3: Empty State] Displays congratulatory empty state when no unassigned runs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                defaultShoeMapProvider.overrideWithValue({}),
                unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
              ],
              child: const UnassignedRunCarousel(
                activities: [],
                activeShoes: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('All Caught Up! 🎉'), findsOneWidget);
      expect(find.textContaining('All your runs have been assigned to shoes in your Garage'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);

      // Clean unmount
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
