import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/providers.dart';
import 'package:shoe_garage/features/garage/screens/shoe_detail_screen.dart';
import 'package:shoe_garage/features/garage/widgets/add_shoe_sheet.dart';
import 'package:shoe_garage/features/garage/widgets/edit_shoe_sheet.dart';
import 'package:shoe_garage/features/garage/widgets/shoe_card_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late File sampleImageFile;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('shoe_photo_widget_test_');
    sampleImageFile = File('${tempDir.path}/sample_shoe.jpg');
    await sampleImageFile.writeAsString('fake_image_content');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('AddShoeSheet displays Add Photo button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: AddShoeSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add Photo'), findsOneWidget);
    expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);

    // Unmount before teardown
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('ShoeCardWidget renders Image.file when shoe has valid photoUri', (tester) async {
    final shoe = Shoe(
      id: 'shoe-photo-1',
      name: 'Saucony Endorphin Pro 4',
      currentDistance: 50.0,
      targetDistance: 400.0,
      isRetired: false,
      photoUri: sampleImageFile.path,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ShoeCardWidget(shoe: shoe),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Saucony Endorphin Pro 4'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('ShoeDetailScreen thumbnail can be tapped to open Photo Action Sheet', (tester) async {
    await db.insertShoe(ShoesCompanion.insert(
      id: 'detail-photo-shoe',
      name: 'Nike Invincible 3',
      currentDistance: const drift.Value(100.0),
      targetDistance: const drift.Value(400.0),
      photoUri: drift.Value(sampleImageFile.path),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: ShoeDetailScreen(shoeId: 'detail-photo-shoe'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);

    // Tap on the thumbnail
    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();

    // Verify Photo Action sheet opened
    expect(find.text('Shoe Photo'), findsOneWidget);
    expect(find.text('View Full Screen'), findsOneWidget);
    expect(find.text('Take New Photo'), findsOneWidget);
    expect(find.text('Choose from Library'), findsOneWidget);
    expect(find.text('Remove Photo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('EditShoeSheet displays existing shoe photo and allows removal', (tester) async {
    final shoe = Shoe(
      id: 'edit-photo-shoe',
      name: 'Asics Novablast 4',
      currentDistance: 75.0,
      targetDistance: 400.0,
      isRetired: false,
      photoUri: sampleImageFile.path,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: EditShoeSheet(shoe: shoe),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.close), findsWidgets); // Close icon on sheet and on photo badge

    // Tap the red close button on photo badge
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();

    // Photo should be removed from preview, replaced with Add Photo button
    expect(find.text('Add Photo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
