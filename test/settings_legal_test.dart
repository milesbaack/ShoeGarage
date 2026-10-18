import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/constants/app_constants.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/settings/screens/settings_screen.dart';
import 'package:shoe_garage/features/settings/widgets/tip_jar_sheet.dart';

void main() {
  group('Settings Screen About & Legal Section Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    test('AppConstants contains expected website, legal, and tip product IDs', () {
      expect(AppConstants.websiteUrl, 'https://milesbaack.github.io/ShoeGarage/');
      expect(AppConstants.privacyPolicyUrl, 'https://milesbaack.github.io/ShoeGarage/privacy.html');
      expect(AppConstants.termsUrl, 'https://milesbaack.github.io/ShoeGarage/terms.html');
      expect(AppConstants.supportUrl, 'https://milesbaack.github.io/ShoeGarage/#support');
      expect(AppConstants.supportEmail, 'support@shoegarage.app');
      expect(AppConstants.tipSmallId, 'com.shoegarage.tip.small');
      expect(AppConstants.tipMediumId, 'com.shoegarage.tip.medium');
      expect(AppConstants.tipLargeId, 'com.shoegarage.tip.large');
      expect(AppConstants.tipProductIds.length, 3);
    });

    testWidgets('Settings screen renders ABOUT & LEGAL section with legal links', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      expect(find.text('ABOUT & LEGAL'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('milesbaack.github.io/ShoeGarage'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Support & Feedback'), findsOneWidget);
      expect(find.text('App Tour & Privacy Guide'), findsOneWidget);

      // Unmount before teardown to gracefully close stream subscriptions
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('TipJarSheet renders ready-to-enable tier options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TipJarSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Tip Jar Sheet contents
      expect(find.text('Indie Tip Jar'), findsOneWidget);
      expect(find.text('Espresso Tip'), findsOneWidget);
      expect(find.text('Running Socks Tip'), findsOneWidget);
      expect(find.text('Energy Gel Pack Tip'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
