import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/garage/screens/shoe_detail_screen.dart';

void main() {
  testWidgets('ShoeDetailScreen displays shoe info, progress, cost-per-mile, and workouts', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDatabase(NativeDatabase.memory());

    // Insert shoe with price: $160 and 320 miles -> Cost per mile: $0.50 / mi
    await db.insertShoe(
      ShoesCompanion.insert(
        id: 'detail-shoe-1',
        name: 'Nike Vaporfly 3',
        brand: const drift.Value('Nike'),
        model: const drift.Value('Vaporfly Next% 3'),
        category: const drift.Value('racing'),
        currentDistance: const drift.Value(320.0),
        targetDistance: const drift.Value(400.0),
        price: const drift.Value(160.0),
      ),
    );

    // Insert workout for this shoe
    await db.insertActivity(
      ActivitiesCompanion.insert(
        id: 'act-1',
        workoutId: 'hk-1',
        workoutType: 'running',
        shoeId: const drift.Value('detail-shoe-1'),
        distance: const drift.Value(13.1),
        duration: const drift.Value(5400.0), // 1h 30m
        startDate: DateTime(2026, 10, 10, 8, 0),
        endDate: DateTime(2026, 10, 10, 9, 30),
        source: const drift.Value('Apple Watch'),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: ShoeDetailScreen(shoeId: 'detail-shoe-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Shoe details
    expect(find.text('Nike Vaporfly 3'), findsWidgets);
    expect(find.text('Nike • Vaporfly Next% 3'), findsOneWidget);
    expect(find.text('RACING'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    // Verify progress
    expect(find.text('320.0 / 400 mi'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('80.0 mi remaining'), findsOneWidget);

    // Verify Cost-per-mile calculation ($160 / 320 mi = $0.50 /mi)
    expect(find.text('\$0.50 /mi'), findsOneWidget);
    expect(find.textContaining('\$160.00 purchase price across 320.0 mi logged'), findsOneWidget);

    // Verify Career stats
    await tester.scrollUntilVisible(find.text('Assigned Runs'), 200);
    expect(find.text('Assigned Runs'), findsOneWidget);
    expect(find.text('13.1 mi'), findsOneWidget); // Longest run

    // Verify Workout card
    await tester.scrollUntilVisible(find.text('13.10 mi'), 200);
    expect(find.text('13.10 mi'), findsOneWidget);
    expect(find.textContaining('Apple Watch'), findsOneWidget);

    // Unmount before closing db to prevent timer leak
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await db.close();
  });

  testWidgets('ShoeDetailScreen allows setting purchase price when unpriced', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDatabase(NativeDatabase.memory());

    await db.insertShoe(
      ShoesCompanion.insert(
        id: 'unpriced-shoe',
        name: 'Brooks Ghost 15',
        currentDistance: const drift.Value(100.0),
        targetDistance: const drift.Value(400.0),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: ShoeDetailScreen(shoeId: 'unpriced-shoe'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify unpriced prompt
    expect(find.text('Set Price'), findsOneWidget);
    expect(find.text('Track what you paid for this pair to evaluate wear value over time.'), findsOneWidget);

    // Tap 'Set Price'
    await tester.tap(find.text('Set Price'));
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('Purchase Price for Brooks Ghost 15'), findsOneWidget);

    // Enter 140
    await tester.enterText(find.byType(TextFormField), '140');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    // Verify updated cost-per-mile ($140 / 100 = $1.40 /mi)
    expect(find.text('\$1.40 /mi'), findsOneWidget);

    // Unmount before closing db
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await db.close();
  });
}
