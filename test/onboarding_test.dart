import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/constants/app_constants.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/onboarding/screens/onboarding_screen.dart';

void main() {
  group('Onboarding Flow Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('Completes 4-slide onboarding tour and persists completion flag', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool completedCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: MaterialApp(
            home: OnboardingScreen(
              onComplete: () => completedCalled = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Slide 1: Shoe Mileage Tracking
      expect(find.text('Track Shoes, Not Runs.'), findsOneWidget);
      expect(find.text('01 / 05 • SHOE MILEAGE'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Slide 2: Zero Servers & Pure Privacy
      expect(find.text('Zero Servers. Pure Privacy.'), findsOneWidget);
      expect(find.text('02 / 05 • ZERO SERVERS'), findsOneWidget);

      // Advance to Slide 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Slide 3: Injury Prevention & Dead Shoes
      expect(find.text('Never Run on Dead Shoes.'), findsOneWidget);
      expect(find.text('03 / 05 • INJURY PREVENTION'), findsOneWidget);

      // Advance to Slide 4
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Slide 4: Origin Story
      expect(find.text('Born from Injury.'), findsOneWidget);
      expect(find.text('04 / 05 • THE ORIGIN STORY'), findsOneWidget);

      // Advance to Slide 5
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Slide 5: Built for Runners & Support
      expect(find.text('Free Forever. No Paywalls.'), findsOneWidget);
      expect(find.text('05 / 05 • BUILT FOR RUNNERS'), findsOneWidget);
      expect(find.text('Leave an App Store Review ★★★★★'), findsOneWidget);
      expect(find.text('Let’s Run • Enter Your Garage'), findsOneWidget);

      // Verify onboarding flag is not yet written
      var flag = await testDb.getSetting(AppConstants.onboardingCompletedKey);
      expect(flag, isNull);

      // Tap final button to complete onboarding
      await tester.tap(find.text('Let’s Run • Enter Your Garage'));
      await tester.pumpAndSettle();

      expect(completedCalled, isTrue);

      // Verify onboarding flag is written to database
      flag = await testDb.getSetting(AppConstants.onboardingCompletedKey);
      expect(flag, 'true');

      // Unmount before teardown
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
