import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/garage/screens/rotation_analytics_screen.dart';
import 'package:shoe_garage/features/garage/screens/shoe_detail_screen.dart';
import 'package:shoe_garage/features/settings/screens/settings_screen.dart';

void main() {
  group('Rotation Analytics & Projections Widget Tests [TEST-ROTATION-UI]', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('Displays empty state when no active shoes exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: const MaterialApp(
            home: RotationAnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rotation Analytics'), findsOneWidget);
      expect(find.text('No Active Shoes in Rotation'), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('Displays rotation summary, mileage share, categories, and retirement projections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      addTearDown(tester.view.resetPhysicalSize);

      final now = DateTime.now();

      // Shoe 1: 370 / 400 mi -> Retiring Soon
      await testDb.insertShoe(ShoesCompanion.insert(
        id: 'shoe-ghost',
        name: 'Ghost 15',
        brand: const Value('Brooks'),
        model: const Value('Ghost 15'),
        category: const Value('road'),
        currentDistance: const Value(370.0),
        targetDistance: const Value(400.0),
      ));

      // Shoe 2: 100 / 400 mi -> Healthy
      await testDb.insertShoe(ShoesCompanion.insert(
        id: 'shoe-speedcross',
        name: 'Speedcross 6',
        brand: const Value('Salomon'),
        model: const Value('Speedcross 6'),
        category: const Value('trail'),
        currentDistance: const Value(100.0),
        targetDistance: const Value(400.0),
      ));

      // Recent workouts: Ghost 15 has 50 miles in last 10 days (~11.6 mi/wk)
      await testDb.insertActivity(ActivitiesCompanion.insert(
        id: 'act-ghost-1',
        workoutId: 'hk-1',
        workoutType: 'running',
        distance: const Value(25.0),
        duration: const Value(7200.0),
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.subtract(const Duration(days: 3)),
        shoeId: const Value('shoe-ghost'),
      ));

      await testDb.insertActivity(ActivitiesCompanion.insert(
        id: 'act-ghost-2',
        workoutId: 'hk-2',
        workoutType: 'running',
        distance: const Value(25.0),
        duration: const Value(7200.0),
        startDate: now.subtract(const Duration(days: 8)),
        endDate: now.subtract(const Duration(days: 8)),
        shoeId: const Value('shoe-ghost'),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: const MaterialApp(
            home: RotationAnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top Header Metrics
      expect(find.text('GARAGE ROTATION SUMMARY'), findsOneWidget);
      // Total 470.0 mi (370 + 100)
      expect(find.text('470.0 mi'), findsOneWidget);
      expect(find.text('2 in rotation'), findsOneWidget);
      // 1 shoe needing attention (Ghost 15 is retiring soon)
      expect(find.textContaining('1 shoe reaching end of target lifespan soon'), findsOneWidget);

      // Mileage Share Section
      expect(find.text('ROTATION MILEAGE SHARE'), findsOneWidget);
      expect(find.textContaining('Workhorse: Ghost 15'), findsOneWidget);
      expect(find.text('Ghost 15'), findsWidgets);
      expect(find.text('Speedcross 6'), findsWidgets);

      // Category Breakdown
      expect(find.text('CATEGORY BREAKDOWN'), findsOneWidget);
      expect(find.text('ROAD'), findsOneWidget);
      expect(find.text('TRAIL'), findsOneWidget);

      // Retirement Projections
      expect(find.text('RETIREMENT PROJECTIONS'), findsOneWidget);
      expect(find.text('RETIRING SOON'), findsOneWidget);
      expect(find.text('IDLE'), findsOneWidget); // Speedcross has no runs in 30d

      // Verify wear rate for Ghost 15: 50 mi / 30 * 7 = 11.7 mi/wk
      expect(find.text('11.7 mi/wk'), findsOneWidget);
      expect(find.text('30.0 mi'), findsOneWidget); // Remaining

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('Settings screen contains Rotation Analytics shortcut and opens screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: const MaterialApp(
            home: SettingsScreen(showAppBar: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify shortcut in Garage Stats card
      expect(find.text('Rotation Analytics & Projections'), findsOneWidget);

      // Tap shortcut
      await tester.tap(find.text('Rotation Analytics & Projections'));
      await tester.pumpAndSettle();

      // RotationAnalyticsScreen should now be open
      expect(find.text('Rotation Analytics'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ShoeDetailScreen displays RETIREMENT PROJECTION card for active shoes', (WidgetTester tester) async {
      final now = DateTime.now();

      await testDb.insertShoe(ShoesCompanion.insert(
        id: 'shoe-detail-proj',
        name: 'Vaporfly 3',
        brand: const Value('Nike'),
        model: const Value('Vaporfly 3'),
        category: const Value('racing'),
        currentDistance: const Value(240.0),
        targetDistance: const Value(300.0), // 80% -> Approaching
      ));

      await testDb.insertActivity(ActivitiesCompanion.insert(
        id: 'act-vf',
        workoutId: 'hk-vf',
        workoutType: 'running',
        distance: const Value(30.0),
        duration: const Value(7000.0),
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 5)),
        shoeId: const Value('shoe-detail-proj'),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: const MaterialApp(
            home: ShoeDetailScreen(shoeId: 'shoe-detail-proj'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RETIREMENT PROJECTION card is displayed
      expect(find.text('RETIREMENT PROJECTION'), findsOneWidget);
      expect(find.text('APPROACHING'), findsOneWidget);
      // 30 mi in 30d -> (30/30)*7 = 7.0 mi/wk
      expect(find.text('7.0 mi/wk'), findsOneWidget);
      expect(find.text('Recent wear rate (30 days)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
