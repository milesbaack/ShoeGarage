import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ShoePhotoService {
  final ImagePicker _picker;

  ShoePhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Picks an image from Camera or Gallery.
  Future<String?> pickImage({required ImageSource source}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return picked?.path;
    } catch (e) {
      return null;
    }
  }

  /// Saves the picked image to the permanent app documents directory.
  Future<String> saveShoePhoto({
    required String sourcePath,
    required String shoeId,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'shoe_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final fileName = '${shoeId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final targetPath = p.join(photosDir.path, fileName);

    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  /// Deletes a shoe photo from the filesystem.
  Future<void> deleteShoePhoto(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
