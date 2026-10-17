import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/services/shoe_photo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ShoePhotoService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('shoe_photo_test_');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async {
        return tempDir.path;
      },
    );

    service = ShoePhotoService();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ShoePhotoService Tests', () {
    test('saveShoePhoto copies file to shoe_photos directory with unique name', () async {
      // Create source dummy image
      final sourceFile = File('${tempDir.path}/temp_pick.jpg');
      await sourceFile.writeAsString('fake_image_bytes_123');

      final savedPath = await service.saveShoePhoto(
        sourcePath: sourceFile.path,
        shoeId: 'shoe-123',
      );

      expect(savedPath, contains('shoe-123'));
      expect(savedPath, contains('shoe_photos'));
      expect(savedPath.endsWith('.jpg'), isTrue);

      final savedFile = File(savedPath);
      expect(await savedFile.exists(), isTrue);
      expect(await savedFile.readAsString(), 'fake_image_bytes_123');
    });

    test('deleteShoePhoto deletes file from filesystem', () async {
      final fileToDelete = File('${tempDir.path}/to_delete.jpg');
      await fileToDelete.writeAsString('bytes');
      expect(await fileToDelete.exists(), isTrue);

      await service.deleteShoePhoto(fileToDelete.path);
      expect(await fileToDelete.exists(), isFalse);
    });

    test('deleteShoePhoto handles null or empty safely', () async {
      await expectLater(service.deleteShoePhoto(null), completes);
      await expectLater(service.deleteShoePhoto(''), completes);
      await expectLater(service.deleteShoePhoto('/non/existent/file.jpg'), completes);
    });
  });
}
