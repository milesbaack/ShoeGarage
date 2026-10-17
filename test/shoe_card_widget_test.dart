import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/garage/widgets/shoe_card_widget.dart';

void main() {
  group('[STORY-03] ShoeCardWidget & Battery Life UI Tests', () {
    testWidgets('[Scenario 1: Visual Calculation] Shoe with 200 miles and 400-mile target renders 50% completion', (WidgetTester tester) async {
      final shoe = Shoe(
        id: 'shoe-1',
        name: 'Hoka Clifton 9',
        brand: 'Hoka',
        model: 'Clifton 9',
        category: 'road',
        currentDistance: 200.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShoeCardWidget(shoe: shoe),
            ),
          ),
        ),
      );

      // Verify text displaying 200.0 / 400 mi and 50%
      expect(find.text('200.0 / 400 mi'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Hoka Clifton 9'), findsOneWidget);

      // Verify progress bar value is exactly 0.5 (50%)
      final progressFinder = find.byKey(const ValueKey('shoe_progress_bar_shoe-1'));
      expect(progressFinder, findsOneWidget);
      final LinearProgressIndicator progressBar = tester.widget(progressFinder);
      expect(progressBar.value, 0.5);

      // Normal state color (< 75%) should be green
      final AlwaysStoppedAnimation<Color> colorAnimation = progressBar.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnimation.value, const Color(0xFF4CAF50));
    });

    testWidgets('[TEST-01 UI Test] Progress bar color changes to warning red state when >90% complete', (WidgetTester tester) async {
      // 380 / 400 = 95% complete (>90%)
      final shoe = Shoe(
        id: 'shoe-worn',
        name: 'Saucony Endorphin Speed',
        brand: 'Saucony',
        model: 'Speed 3',
        category: 'racing',
        currentDistance: 380.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitPreferenceProvider.overrideWithValue(DistanceUnit.miles),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShoeCardWidget(shoe: shoe),
            ),
          ),
        ),
      );

      expect(find.text('380.0 / 400 mi'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);

      // Verify progress bar value is 0.95
      final progressFinder = find.byKey(const ValueKey('shoe_progress_bar_shoe-worn'));
      expect(progressFinder, findsOneWidget);
      final LinearProgressIndicator progressBar = tester.widget(progressFinder);
      expect(progressBar.value, 0.95);

      // Warning state (>90%) must be Colors.red
      final AlwaysStoppedAnimation<Color> colorAnimation = progressBar.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnimation.value, Colors.red);
    });

    testWidgets('[Scenario 2: Retirement Confirmation Dialog] Tapping Retire Shoe confirms retirement callback', (WidgetTester tester) async {
      bool retireCalled = false;

      final shoe = Shoe(
        id: 'shoe-to-retire',
        name: 'Nike Pegasus 40',
        brand: 'Nike',
        model: 'Pegasus 40',
        category: 'road',
        currentDistance: 312.4,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
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
                onRetire: () {
                  retireCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap overflow menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap 'Retire Shoe' option
      expect(find.text('Retire Shoe'), findsOneWidget);
      await tester.tap(find.text('Retire Shoe'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appeared with details
      expect(find.text('Retire Shoe?'), findsOneWidget);
      expect(find.textContaining('312.4 mi'), findsOneWidget);

      // Tap confirm button in dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Retire Shoe'));
      await tester.pumpAndSettle();

      // Verify retirement callback was triggered
      expect(retireCalled, true);
    });

    testWidgets('Tapping Add Miles opens dialog and calls onAddMiles callback', (WidgetTester tester) async {
      double? addedMiles;

      final shoe = Shoe(
        id: 'shoe-add-miles',
        name: 'Saucony Triumph 20',
        currentDistance: 120.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
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
                onAddMiles: (miles) => addedMiles = miles,
              ),
            ),
          ),
        ),
      );

      // Tap overflow menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap 'Add Miles'
      expect(find.text('Add Miles'), findsOneWidget);
      await tester.tap(find.text('Add Miles'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Add Miles to Saucony Triumph 20'), findsOneWidget);

      // Tap the +5.0 mi chip
      await tester.tap(find.text('+5.0 mi'));
      await tester.pumpAndSettle();

      // Tap 'Add Miles' filled button
      await tester.tap(find.widgetWithText(FilledButton, 'Add Miles'));
      await tester.pumpAndSettle();

      expect(addedMiles, 5.0);
    });

    testWidgets('Tapping Un-retire on retired shoe opens dialog and calls onUnretire callback', (WidgetTester tester) async {
      double? newTarget;

      final shoe = Shoe(
        id: 'shoe-unretire',
        name: 'Asics Novablast 3',
        currentDistance: 320.0,
        targetDistance: 320.0,
        isRetired: true,
        retiredAt: DateTime.now(),
        createdAt: DateTime.now(),
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
                onUnretire: (target) => newTarget = target,
              ),
            ),
          ),
        ),
      );

      // Tap overflow menu on retired shoe
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap 'Un-retire Shoe'
      expect(find.text('Un-retire Shoe'), findsOneWidget);
      await tester.tap(find.text('Un-retire Shoe'));
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.text('Un-retire Asics Novablast 3?'), findsOneWidget);

      // Tap '+100.0 mi (420 mi)' chip
      await tester.tap(find.text('+100.0 mi (420 mi)'));
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.widgetWithText(FilledButton, 'Un-retire Shoe'));
      await tester.pumpAndSettle();

      expect(newTarget, 420.0);
    });

    testWidgets('Tapping Delete Shoe opens dialog and calls onDelete callback', (WidgetTester tester) async {
      bool deleteCalled = false;

      final shoe = Shoe(
        id: 'shoe-del',
        name: 'Old Worn Shoe',
        currentDistance: 50.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
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
                onDelete: () => deleteCalled = true,
              ),
            ),
          ),
        ),
      );

      // Tap overflow menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap 'Delete Shoe'
      expect(find.text('Delete Shoe'), findsOneWidget);
      await tester.tap(find.text('Delete Shoe'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Delete Old Worn Shoe?'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.widgetWithText(FilledButton, 'Delete Shoe'));
      await tester.pumpAndSettle();

      expect(deleteCalled, true);
    });
  });
}
