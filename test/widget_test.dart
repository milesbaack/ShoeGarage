import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/main.dart';

void main() {
  testWidgets('ShoeGarageApp loads and displays tabs and empty state', (WidgetTester tester) async {
    final testDb = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
        ],
        child: const ShoeGarageApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Shoe Garage'), findsOneWidget);
    expect(find.text('Your Garage is Empty'), findsOneWidget);
    expect(find.text('Garage'), findsOneWidget);
    expect(find.text('Activities'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify Nursing Home icon in AppBar and tap it
    final nursingHomeFinder = find.byTooltip('Nursing Home');
    expect(nursingHomeFinder, findsOneWidget);
    await tester.tap(nursingHomeFinder);
    await tester.pumpAndSettle();

    // Verify Nursing Home screen opened
    expect(find.text('The Nursing Home is Empty'), findsOneWidget);

    // Pop back to Garage
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Switch to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings screen elements
    expect(find.text('GARAGE STATS'), findsOneWidget);
    expect(find.text('DEFAULT WORKOUT SHOES'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Walking'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Import Last 30 Days'), 100);
    expect(find.text('HEALTHKIT & WORKOUT SYNC'), findsOneWidget);
    expect(find.text('Import Last 30 Days'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('LOCK SCREEN & NOTIFICATIONS'), 100);
    expect(find.text('LOCK SCREEN & NOTIFICATIONS'), findsOneWidget);

    await testDb.close();
  });
}
