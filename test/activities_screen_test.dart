import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/activities/screens/activities_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ActivitiesScreen(),
        ),
      ),
    );
  }

  testWidgets('Renders segmented button with Inbox and History tabs', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.textContaining('Inbox (0)'), findsOneWidget);
    expect(find.textContaining('History (0)'), findsOneWidget);

    // Clean unmount before teardown
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Switching to History shows empty state when no workouts assigned', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Tap History tab
    await tester.tap(find.textContaining('History'));
    await tester.pumpAndSettle();

    expect(find.text('No Assigned Workouts'), findsOneWidget);
    expect(find.text('Assigned runs from your Inbox will appear here.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('History displays assigned activities with shoe name and allows reassign', (tester) async {
    // Add 2 shoes
    await db.insertShoe(ShoesCompanion.insert(
      id: 'shoe-1',
      name: 'Pegasus 40',
      currentDistance: const Value(25.0),
    ));
    await db.insertShoe(ShoesCompanion.insert(
      id: 'shoe-2',
      name: 'Vaporfly 3',
      currentDistance: const Value(10.0),
    ));

    // Add an assigned workout
    await db.insertActivity(ActivitiesCompanion.insert(
      id: 'act-1',
      workoutId: 'hk-1',
      workoutType: 'running',
      distance: const Value(5.0),
      duration: const Value(1800.0),
      startDate: DateTime(2026, 10, 15, 8, 0),
      endDate: DateTime(2026, 10, 15, 8, 30),
      shoeId: const Value('shoe-1'),
      source: const Value('Apple Watch'),
    ));

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Verify badges on segmented control
    expect(find.textContaining('Inbox (0)'), findsOneWidget);
    expect(find.textContaining('History (1)'), findsOneWidget);

    // Switch to History
    await tester.tap(find.textContaining('History'));
    await tester.pumpAndSettle();

    // Assigned workout card should display
    expect(find.text('5.00 mi'), findsOneWidget);
    expect(find.text('Pegasus 40'), findsOneWidget);
    expect(find.text('Reassign'), findsOneWidget);

    // Tap Reassign button
    await tester.tap(find.text('Reassign'));
    await tester.pumpAndSettle();

    // Reassign modal bottom sheet should appear
    expect(find.text('Reassign Workout'), findsOneWidget);
    expect(find.text('Vaporfly 3'), findsOneWidget);
    expect(find.text('Move to Inbox (Unassign)'), findsOneWidget);

    // Tap Vaporfly 3 to reassign
    await tester.tap(find.text('Vaporfly 3'));
    await tester.pumpAndSettle();

    // Verify modal is dismissed and card now shows Vaporfly 3
    expect(find.text('Vaporfly 3'), findsOneWidget);

    // Verify distances in database
    final pegasus = await db.getShoeById('shoe-1');
    final vaporfly = await db.getShoeById('shoe-2');
    expect(pegasus?.currentDistance, 20.0); // 25.0 - 5.0
    expect(vaporfly?.currentDistance, 15.0); // 10.0 + 5.0

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Unassigning workout moves it back to Inbox and updates shoe distance', (tester) async {
    // Add shoe
    await db.insertShoe(ShoesCompanion.insert(
      id: 'shoe-1',
      name: 'Ghost 15',
      currentDistance: const Value(50.0),
    ));

    // Add assigned workout
    await db.insertActivity(ActivitiesCompanion.insert(
      id: 'act-2',
      workoutId: 'hk-2',
      workoutType: 'running',
      distance: const Value(10.0),
      duration: const Value(3600.0),
      startDate: DateTime(2026, 10, 14, 7, 0),
      endDate: DateTime(2026, 10, 14, 8, 0),
      shoeId: const Value('shoe-1'),
    ));

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Switch to History tab
    await tester.tap(find.textContaining('History'));
    await tester.pumpAndSettle();

    expect(find.text('Ghost 15'), findsOneWidget);

    // Open Reassign sheet
    await tester.tap(find.text('Reassign'));
    await tester.pumpAndSettle();

    // Tap "Move to Inbox (Unassign)"
    await tester.tap(find.text('Move to Inbox (Unassign)'));
    await tester.pumpAndSettle();

    // History should now be empty
    expect(find.text('No Assigned Workouts'), findsOneWidget);
    expect(find.textContaining('History (0)'), findsOneWidget);
    expect(find.textContaining('Inbox (1)'), findsOneWidget);

    // Switch back to Inbox tab
    await tester.tap(find.text('Inbox (1)'));
    await tester.pumpAndSettle();

    // The workout should appear in Inbox
    expect(find.text('10.00 mi'), findsOneWidget);

    // Shoe distance should be decremented
    final ghost = await db.getShoeById('shoe-1');
    expect(ghost?.currentDistance, 40.0); // 50.0 - 10.0

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
